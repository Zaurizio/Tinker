package Tinker.demo.service;

import Tinker.demo.dto.simulado.ConcluirSimuladoDTO;
import Tinker.demo.dto.simulado.ConclusaoSimuladoDTO;
import Tinker.demo.dto.simulado.RespostaConclusaoDTO;
import Tinker.demo.dto.simulado.SimuladoResumoDTO;
import Tinker.demo.exception.AcessoNegadoException;
import Tinker.demo.exception.DadosInvalidosException;
import Tinker.demo.exception.RecursoNaoEncontradoException;
import Tinker.demo.mapper.QuestaoMapper;
import Tinker.demo.model.Questao;
import Tinker.demo.model.Relatorio;
import Tinker.demo.model.RelatorioSimulado;
import Tinker.demo.model.Simulado;
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

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class SimuladoConclusaoServiceTest {

    private static final String EMAIL_ALUNO = "aluno@tinker.com";
    private static final Integer SIMULADO_ID = 15;

    private SimuladoRepository simuladoRepository;
    private QuestaoSimuRepository questaoSimuRepository;
    private QuestaoRepository questaoRepository;
    private RelatorioRepository relatorioRepository;
    private RelatorioSimuladoRepository resultadoRepository;
    private SimuladoService service;

    @BeforeEach
    void configurar() {
        simuladoRepository = mock(SimuladoRepository.class);
        questaoSimuRepository = mock(QuestaoSimuRepository.class);
        questaoRepository = mock(QuestaoRepository.class);
        relatorioRepository = mock(RelatorioRepository.class);
        resultadoRepository = mock(RelatorioSimuladoRepository.class);
        service = new SimuladoService(
                simuladoRepository,
                questaoSimuRepository,
                resultadoRepository,
                mock(TurmaSimuladoRepository.class),
                questaoRepository,
                new QuestaoMapper(),
                relatorioRepository);
    }

    @Test
    void alunoConcluiSimuladoProprioComTodasAsRespostasECalculaTotais() {
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
    void conclusaoAtualizaDesempenhoDeCadaQuestao() {
        prepararConclusaoValida();
        Relatorio existente = new Relatorio(10, EMAIL_ALUNO, "ALUNO", 0);
        when(relatorioRepository.findByCodQuestAndEmailAndTipoUsu(10, EMAIL_ALUNO, "ALUNO"))
                .thenReturn(Optional.of(existente));

        concluir(dados(resposta(10, "A"), resposta(11, "C")));

        var captor = org.mockito.ArgumentCaptor.forClass(Relatorio.class);
        verify(relatorioRepository, times(2)).save(captor.capture());
        assertEquals(List.of(10, 11), captor.getAllValues().stream()
                .map(Relatorio::getCodQuest).toList());
        assertEquals(List.of(1, 0), captor.getAllValues().stream()
                .map(Relatorio::getAcertouErrou).toList());
        assertTrue(captor.getAllValues().stream()
                .allMatch(relatorio -> EMAIL_ALUNO.equals(relatorio.getEmail())
                        && "ALUNO".equals(relatorio.getTipoUsu())));
    }

    @Test
    void administradorRecebe403() {
        assertThrows(AcessoNegadoException.class,
                () -> service.concluir(
                        usuario("adm@tinker.com", TipoUsuario.ADMINISTRADOR),
                        SIMULADO_ID,
                        dados(resposta(10, "A"))));
        verify(simuladoRepository, never()).findById(any());
        verify(resultadoRepository, never()).save(any());
    }

    @Test
    void professorConcluiSimuladoPessoalProprio() {
        String emailProfessor = "professor@tinker.com";
        when(simuladoRepository.findById(SIMULADO_ID))
                .thenReturn(Optional.of(simuladoProfessor(emailProfessor)));
        when(questaoSimuRepository.findCodQuestoesByCodSimulado(SIMULADO_ID))
                .thenReturn(List.of(10));
        when(questaoRepository.findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(List.of(10), 1))
                .thenReturn(List.of(questao(10, "A")));

        ConclusaoSimuladoDTO resposta = service.concluir(
                usuario(emailProfessor, TipoUsuario.PROFESSOR),
                SIMULADO_ID,
                dados(resposta(10, "A")));

        assertEquals(1, resposta.acertos());
        assertEquals(emailProfessor, resultadoSalvo().getEmailAluno());
    }

    @Test
    void usuarioNaoConcluiSimuladoDeOutraConta() {
        when(simuladoRepository.findById(SIMULADO_ID))
                .thenReturn(Optional.of(simuladoAluno("outro@tinker.com")));

        assertThrows(RecursoNaoEncontradoException.class,
                () -> concluir(dados(resposta(10, "A"))));
        verify(resultadoRepository, never()).save(any());
    }

    @Test
    void simuladoInexistenteRecebe404() {
        when(simuladoRepository.findById(SIMULADO_ID)).thenReturn(Optional.empty());

        assertThrows(RecursoNaoEncontradoException.class,
                () -> concluir(dados(resposta(10, "A"))));
        verify(questaoSimuRepository, never()).findCodQuestoesByCodSimulado(any());
    }

    @Test
    void simuladoSemQuestoesAtivasNaoPodeSerConcluido() {
        prepararSimulado();
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

        assertThrows(DadosInvalidosException.class, () -> concluir(new ConcluirSimuladoDTO()));
        assertThrows(DadosInvalidosException.class, () -> concluir(dados()));
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
                () -> concluir(dados(resposta(10, "A"), resposta(11, "B"), resposta(12, "A"))));
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
    void abandonoNaoApagaResultadoAnterior() {
        prepararConclusaoValida();
        RelatorioSimulado existente = new RelatorioSimulado();
        existente.setCodSimulado(SIMULADO_ID);
        existente.setEmailAluno(EMAIL_ALUNO);
        existente.setAcertos(2);
        existente.setErros(0);
        when(resultadoRepository.findByCodSimuladoAndEmailAluno(SIMULADO_ID, EMAIL_ALUNO))
                .thenReturn(Optional.of(existente));

        assertThrows(DadosInvalidosException.class, () -> concluir(dados(resposta(10, "A"))));

        assertEquals(2, existente.getAcertos());
        assertEquals(0, existente.getErros());
        verify(resultadoRepository, never()).save(any());
    }

    @Test
    void listagemExpoeStatusDeConclusaoPorSimulado() {
        Simulado concluido = simuladoAluno(EMAIL_ALUNO);
        concluido.setCodSimulado(10);
        Simulado pendente = simuladoAluno(EMAIL_ALUNO);
        pendente.setCodSimulado(11);
        when(simuladoRepository.findByEmailAlunoAndTipoUsuOrderByCodSimuladoAsc(
                EMAIL_ALUNO, Simulado.TIPO_USUARIO_ALUNO))
                .thenReturn(List.of(concluido, pendente));
        RelatorioSimulado resultado = new RelatorioSimulado();
        resultado.setCodSimulado(10);
        resultado.setEmailAluno(EMAIL_ALUNO);
        resultado.setAcertos(7);
        resultado.setErros(3);
        when(resultadoRepository.findByEmailAlunoAndCodSimuladoIn(EMAIL_ALUNO, List.of(10, 11)))
                .thenReturn(List.of(resultado));

        List<SimuladoResumoDTO> resumo = service.listar(usuario(EMAIL_ALUNO, TipoUsuario.ALUNO));

        SimuladoResumoDTO itemConcluido = resumo.stream()
                .filter(item -> item.id() == 10).findFirst().orElseThrow();
        SimuladoResumoDTO itemPendente = resumo.stream()
                .filter(item -> item.id() == 11).findFirst().orElseThrow();
        assertTrue(itemConcluido.concluido());
        assertEquals(7, itemConcluido.acertos());
        assertTrue(!itemPendente.concluido());
        assertEquals(null, itemPendente.acertos());
    }

    private void prepararConclusaoValida() {
        prepararSimulado();
        when(questaoSimuRepository.findCodQuestoesByCodSimulado(SIMULADO_ID))
                .thenReturn(List.of(10, 11));
        when(questaoRepository.findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(
                List.of(10, 11), 1)).thenReturn(List.of(questao(10, "A"), questao(11, "B")));
        when(resultadoRepository.findByCodSimuladoAndEmailAluno(SIMULADO_ID, EMAIL_ALUNO))
                .thenReturn(Optional.empty());
    }

    private void prepararSimulado() {
        when(simuladoRepository.findById(SIMULADO_ID)).thenReturn(Optional.of(simuladoAluno(EMAIL_ALUNO)));
    }

    private ConclusaoSimuladoDTO concluir(ConcluirSimuladoDTO dados) {
        return service.concluir(usuario(EMAIL_ALUNO, TipoUsuario.ALUNO), SIMULADO_ID, dados);
    }

    private RelatorioSimulado resultadoSalvo() {
        var captor = org.mockito.ArgumentCaptor.forClass(RelatorioSimulado.class);
        verify(resultadoRepository).save(captor.capture());
        return captor.getValue();
    }

    private ConcluirSimuladoDTO dados(RespostaConclusaoDTO... respostas) {
        ConcluirSimuladoDTO dados = new ConcluirSimuladoDTO();
        dados.setRespostas(List.of(respostas));
        return dados;
    }

    private RespostaConclusaoDTO resposta(int questaoId, String alternativa) {
        RespostaConclusaoDTO resposta = new RespostaConclusaoDTO();
        resposta.setQuestaoId(questaoId);
        resposta.setAlternativa(alternativa);
        return resposta;
    }

    private UsuarioAutenticado usuario(String email, TipoUsuario tipo) {
        return new UsuarioAutenticado(email, tipo);
    }

    private Simulado simuladoAluno(String email) {
        Simulado simulado = new Simulado();
        simulado.setCodSimulado(SIMULADO_ID);
        simulado.setEmailAluno(email);
        simulado.setEmailProf(null);
        simulado.setTipoUsu(Simulado.TIPO_USUARIO_ALUNO);
        simulado.setConclusao(0);
        return simulado;
    }

    private Simulado simuladoProfessor(String email) {
        Simulado simulado = new Simulado();
        simulado.setCodSimulado(SIMULADO_ID);
        simulado.setEmailAluno(null);
        simulado.setEmailProf(email);
        simulado.setTipoUsu(Simulado.TIPO_USUARIO_PROFESSOR);
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
