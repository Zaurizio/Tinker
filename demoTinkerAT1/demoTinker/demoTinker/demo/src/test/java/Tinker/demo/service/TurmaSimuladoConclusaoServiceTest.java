package Tinker.demo.service;

import Tinker.demo.dto.turma.ConcluirSimuladoPublicadoDTO;
import Tinker.demo.dto.turma.ConclusaoSimuladoDTO;
import Tinker.demo.dto.turma.RespostaConclusaoSimuladoDTO;
import Tinker.demo.exception.AcessoNegadoException;
import Tinker.demo.exception.DadosInvalidosException;
import Tinker.demo.exception.RecursoNaoEncontradoException;
import Tinker.demo.mapper.QuestaoMapper;
import Tinker.demo.model.Questao;
import Tinker.demo.model.RelatorioSimulado;
import Tinker.demo.model.Simulado;
import Tinker.demo.model.Turma;
import Tinker.demo.model.TurmaSimulado;
import Tinker.demo.repository.QuestaoRepository;
import Tinker.demo.repository.QuestaoSimuRepository;
import Tinker.demo.repository.RelatorioRepository;
import Tinker.demo.repository.RelatorioSimuladoRepository;
import Tinker.demo.repository.SimuladoRepository;
import Tinker.demo.repository.TurmaSimuladoRepository;
import Tinker.demo.security.TipoUsuario;
import Tinker.demo.security.UsuarioAutenticado;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class TurmaSimuladoConclusaoServiceTest {

    private static final String CODIGO = "00123456";
    private static final String PUBLICACAO = "publicacao";
    private static final String EMAIL_ALUNO = "aluno@tinker.com";
    private static final Integer SIMULADO_ID = 15;

    private TurmaService turmaService;
    private TurmaSimuladoRepository publicacaoRepository;
    private SimuladoRepository simuladoRepository;
    private QuestaoSimuRepository questaoSimuRepository;
    private QuestaoRepository questaoRepository;
    private RelatorioRepository relatorioRepository;
    private RelatorioSimuladoRepository resultadoRepository;
    private TurmaSimuladoService service;

    @BeforeEach
    void configurar() {
        turmaService = mock(TurmaService.class);
        publicacaoRepository = mock(TurmaSimuladoRepository.class);
        simuladoRepository = mock(SimuladoRepository.class);
        questaoSimuRepository = mock(QuestaoSimuRepository.class);
        questaoRepository = mock(QuestaoRepository.class);
        relatorioRepository = mock(RelatorioRepository.class);
        resultadoRepository = mock(RelatorioSimuladoRepository.class);
        service = new TurmaSimuladoService(
                turmaService,
                publicacaoRepository,
                simuladoRepository,
                questaoSimuRepository,
                questaoRepository,
                new QuestaoMapper(),
                relatorioRepository,
                resultadoRepository);
        when(turmaService.buscarAtiva(CODIGO)).thenReturn(turma());
    }

    @Test
    void alunoMembroConcluiComTodasAsRespostasECalculaTotais() {
        prepararConclusaoValida();

        ConclusaoSimuladoDTO resposta = concluir(dados(resposta(10, "A"), resposta(11, "C")));

        assertEquals(SIMULADO_ID, resposta.simuladoId());
        assertEquals(2, resposta.quantidadeQuestoes());
        assertEquals(1, resposta.acertos());
        assertEquals(1, resposta.erros());
        assertTrue(resposta.completo());
        RelatorioSimulado salvo = resultadoSalvo();
        assertEquals(SIMULADO_ID, salvo.getCodSimulado());
        assertEquals(EMAIL_ALUNO, salvo.getEmailAluno());
        assertEquals(1, salvo.getAcertos());
        assertEquals(1, salvo.getErros());
    }

    @Test
    void novaConclusaoSubstituiResultadoAnteriorSemDuplicar() {
        prepararConclusaoValida();
        RelatorioSimulado existente = new RelatorioSimulado();
        existente.setCodSimulado(SIMULADO_ID);
        existente.setEmailAluno(EMAIL_ALUNO);
        existente.setAcertos(0);
        existente.setErros(2);
        when(resultadoRepository.findByCodSimuladoAndEmailAluno(SIMULADO_ID, EMAIL_ALUNO))
                .thenReturn(Optional.of(existente));

        concluir(dados(resposta(10, "A"), resposta(11, "B")));

        assertEquals(2, existente.getAcertos());
        assertEquals(0, existente.getErros());
        verify(resultadoRepository, times(1)).save(existente);
    }

    @Test
    void professorEAdministradorRecebem403() {
        assertThrows(AcessoNegadoException.class,
                () -> service.concluir(
                        usuario("prof@tinker.com", TipoUsuario.PROFESSOR),
                        CODIGO, PUBLICACAO, dados(resposta(10, "A"))));
        assertThrows(AcessoNegadoException.class,
                () -> service.concluir(
                        usuario("adm@tinker.com", TipoUsuario.ADMINISTRADOR),
                        CODIGO, PUBLICACAO, dados(resposta(10, "A"))));
        verify(turmaService, never()).buscarAtiva(any());
        verify(resultadoRepository, never()).save(any());
    }

    @Test
    void alunoNaoMembroOuMembershipInativoRecebe404() {
        negarAcessoTurma();

        assertThrows(RecursoNaoEncontradoException.class,
                () -> concluir(dados(resposta(10, "A"))));
        assertThrows(RecursoNaoEncontradoException.class,
                () -> concluir(dados(resposta(10, "A"))));
        verify(publicacaoRepository, never()).findById(any());
        verify(resultadoRepository, never()).save(any());
    }

    @Test
    void turmaInativaRecebe404() {
        when(turmaService.buscarAtiva(CODIGO)).thenThrow(
                new RecursoNaoEncontradoException("TURMA_NAO_ENCONTRADA", "nao"));

        assertThrows(RecursoNaoEncontradoException.class,
                () -> concluir(dados(resposta(10, "A"))));
        verify(publicacaoRepository, never()).findById(any());
    }

    @Test
    void publicacaoInexistenteInativaOuDeOutraTurmaRecebe404() {
        when(publicacaoRepository.findByIdPublicacaoAndCodTurmaAndAtivo(
                PUBLICACAO, CODIGO, 1)).thenReturn(Optional.empty());

        for (int tentativa = 0; tentativa < 3; tentativa++) {
            assertThrows(RecursoNaoEncontradoException.class,
                    () -> concluir(dados(resposta(10, "A"))));
        }
        verify(simuladoRepository, never()).findById(any());
        verify(resultadoRepository, never()).save(any());
    }

    @Test
    void simuladoInexistenteRecebe404() {
        prepararPublicacao();
        when(simuladoRepository.findById(SIMULADO_ID)).thenReturn(Optional.empty());

        assertThrows(RecursoNaoEncontradoException.class,
                () -> concluir(dados(resposta(10, "A"))));
        verify(questaoSimuRepository, never()).findCodQuestoesByCodSimulado(any());
    }

    @Test
    void simuladoSemQuestoesAtivasNaoPodeSerConcluido() {
        prepararPublicacaoESimulado();
        when(questaoSimuRepository.findCodQuestoesByCodSimulado(SIMULADO_ID))
                .thenReturn(List.of(10));
        when(questaoRepository.findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(List.of(10), 1))
                .thenReturn(List.of());

        DadosInvalidosException erro = assertThrows(DadosInvalidosException.class,
                () -> concluir(dados(resposta(10, "A"))));
        assertEquals("SIMULADO_SEM_QUESTOES_ATIVAS", erro.getCodigo());
        verify(resultadoRepository, never()).save(any());
    }

    @Test
    void listaNulaOuVaziaEhRejeitada() {
        prepararConclusaoValida();
        ConcluirSimuladoPublicadoDTO nula = new ConcluirSimuladoPublicadoDTO();
        ConcluirSimuladoPublicadoDTO vazia = dados();

        assertThrows(DadosInvalidosException.class, () -> concluir(nula));
        assertThrows(DadosInvalidosException.class, () -> concluir(vazia));
        verify(resultadoRepository, never()).save(any());
    }

    @Test
    void questaoSemRespostaEhRejeitada() {
        prepararConclusaoValida();

        DadosInvalidosException erro = assertThrows(DadosInvalidosException.class,
                () -> concluir(dados(resposta(10, "A"))));

        assertEquals("RESPOSTAS_INCOMPLETAS", erro.getCodigo());
        verify(resultadoRepository, never()).save(any());
    }

    @Test
    void questaoExtraNaoAssociadaEhRejeitada() {
        prepararConclusaoValida();

        assertThrows(RecursoNaoEncontradoException.class,
                () -> concluir(dados(
                        resposta(10, "A"), resposta(11, "B"), resposta(12, "A"))));
        verify(resultadoRepository, never()).save(any());
    }

    @Test
    void idRepetidoEhRejeitado() {
        prepararConclusaoValida();

        DadosInvalidosException erro = assertThrows(DadosInvalidosException.class,
                () -> concluir(dados(resposta(10, "A"), resposta(10, "B"))));

        assertEquals("QUESTAO_REPETIDA", erro.getCodigo());
        verify(resultadoRepository, never()).save(any());
    }

    @Test
    void questaoInativaAssociadaNaoParticipaESeEnviadaEhExtra() {
        prepararPublicacaoESimulado();
        when(questaoSimuRepository.findCodQuestoesByCodSimulado(SIMULADO_ID))
                .thenReturn(List.of(10, 11, 12));
        when(questaoRepository.findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(
                List.of(10, 11, 12), 1)).thenReturn(List.of(questao(10, "A"), questao(11, "B")));

        DadosInvalidosException erro = assertThrows(DadosInvalidosException.class,
                () -> concluir(dados(
                        resposta(10, "A"), resposta(11, "B"), resposta(12, "A"))));

        assertEquals("QUESTAO_EXTRA", erro.getCodigo());
        verify(resultadoRepository, never()).save(any());
    }

    @Test
    void alternativaInvalidaOuInexistenteEhRejeitada() {
        prepararConclusaoValida();

        assertThrows(DadosInvalidosException.class,
                () -> concluir(dados(resposta(10, "F"), resposta(11, "B"))));
        assertThrows(DadosInvalidosException.class,
                () -> concluir(dados(resposta(10, "E"), resposta(11, "B"))));
        verify(resultadoRepository, never()).save(any());
    }

    @Test
    void respostaEhSeguraENaoAlteraOutrosEstados() {
        prepararConclusaoValida();
        Simulado simulado = simuladoRepository.findById(SIMULADO_ID).orElseThrow();

        ConclusaoSimuladoDTO resposta = concluir(
                dados(resposta(10, " a "), resposta(11, " b ")));

        assertEquals(
                Arrays.asList(
                        "simuladoId", "quantidadeQuestoes", "acertos", "erros", "completo"),
                Arrays.stream(ConclusaoSimuladoDTO.class.getRecordComponents())
                        .map(componente -> componente.getName()).toList());
        assertFalse(resposta.toString().contains("GABARITO"));
        assertEquals(0, simulado.getConclusao());
        verify(simuladoRepository, never()).save(any());
        verify(relatorioRepository, never()).findById(any());
        verify(relatorioRepository, never()).save(any());
        verify(relatorioRepository, never()).delete(any());
        verify(publicacaoRepository, never()).save(any());
        verify(questaoRepository, never()).save(any());
        verify(questaoSimuRepository, never()).save(any());
    }

    private void prepararConclusaoValida() {
        prepararPublicacaoESimulado();
        when(questaoSimuRepository.findCodQuestoesByCodSimulado(SIMULADO_ID))
                .thenReturn(List.of(10, 11));
        when(questaoRepository.findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(
                List.of(10, 11), 1)).thenReturn(List.of(questao(10, "A"), questao(11, "B")));
        when(resultadoRepository.findByCodSimuladoAndEmailAluno(SIMULADO_ID, EMAIL_ALUNO))
                .thenReturn(Optional.empty());
    }

    private void prepararPublicacaoESimulado() {
        prepararPublicacao();
        when(simuladoRepository.findById(SIMULADO_ID)).thenReturn(Optional.of(simulado()));
    }

    private void prepararPublicacao() {
        when(publicacaoRepository.findByIdPublicacaoAndCodTurmaAndAtivo(
                PUBLICACAO, CODIGO, 1)).thenReturn(Optional.of(publicacao()));
    }

    private void negarAcessoTurma() {
        org.mockito.Mockito.doThrow(
                        new RecursoNaoEncontradoException("TURMA_NAO_ENCONTRADA", "nao"))
                .when(turmaService).exigirAcesso(any(), any());
    }

    private ConclusaoSimuladoDTO concluir(ConcluirSimuladoPublicadoDTO dados) {
        return service.concluir(aluno(), CODIGO, PUBLICACAO, dados);
    }

    private RelatorioSimulado resultadoSalvo() {
        var captor = org.mockito.ArgumentCaptor.forClass(RelatorioSimulado.class);
        verify(resultadoRepository).save(captor.capture());
        return captor.getValue();
    }

    private ConcluirSimuladoPublicadoDTO dados(RespostaConclusaoSimuladoDTO... respostas) {
        ConcluirSimuladoPublicadoDTO dados = new ConcluirSimuladoPublicadoDTO();
        dados.setRespostas(List.of(respostas));
        return dados;
    }

    private RespostaConclusaoSimuladoDTO resposta(int questaoId, String alternativa) {
        RespostaConclusaoSimuladoDTO resposta = new RespostaConclusaoSimuladoDTO();
        resposta.setQuestaoId(questaoId);
        resposta.setAlternativa(alternativa);
        return resposta;
    }

    private UsuarioAutenticado aluno() {
        return usuario(EMAIL_ALUNO, TipoUsuario.ALUNO);
    }

    private UsuarioAutenticado usuario(String email, TipoUsuario tipo) {
        return new UsuarioAutenticado(email, tipo);
    }

    private Turma turma() {
        Turma turma = new Turma();
        turma.setCodTurma(CODIGO);
        turma.setAtivo(1);
        turma.setEmailProf("prof@tinker.com");
        return turma;
    }

    private TurmaSimulado publicacao() {
        TurmaSimulado publicacao = new TurmaSimulado();
        publicacao.setIdPublicacao(PUBLICACAO);
        publicacao.setCodTurma(CODIGO);
        publicacao.setCodSimulado(SIMULADO_ID);
        publicacao.setAtivo(1);
        return publicacao;
    }

    private Simulado simulado() {
        Simulado simulado = new Simulado();
        simulado.setCodSimulado(SIMULADO_ID);
        simulado.setConclusao(0);
        return simulado;
    }

    private Questao questao(int id, String gabarito) {
        Questao questao = new Questao();
        questao.setCodQuestao(id);
        questao.setAlternativaA("Texto A");
        questao.setAlternativaB("Texto B");
        questao.setAlternativaC("Texto C");
        questao.setAlternativaD("Texto D");
        questao.setAlternativaE(null);
        questao.setResposta(gabarito);
        questao.setAtivo(1);
        return questao;
    }
}
