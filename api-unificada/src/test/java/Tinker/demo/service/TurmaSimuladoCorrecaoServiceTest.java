package Tinker.demo.service;

import Tinker.demo.dto.simulado.CorrecaoQuestaoSimuladoDTO;
import Tinker.demo.dto.turma.CorrigirQuestaoPublicadaDTO;
import Tinker.demo.exception.AcessoNegadoException;
import Tinker.demo.exception.DadosInvalidosException;
import Tinker.demo.exception.RecursoNaoEncontradoException;
import Tinker.demo.mapper.QuestaoMapper;
import Tinker.demo.model.Questao;
import Tinker.demo.model.QuestaoSimuid;
import Tinker.demo.model.Relatorio;
import Tinker.demo.model.Simulado;
import Tinker.demo.model.Turma;
import Tinker.demo.model.TurmaSimulado;
import Tinker.demo.repository.QuestaoRepository;
import Tinker.demo.repository.QuestaoSimuRepository;
import Tinker.demo.repository.RelatorioRepository;
import Tinker.demo.repository.SimuladoRepository;
import Tinker.demo.repository.TurmaSimuladoRepository;
import Tinker.demo.security.TipoUsuario;
import Tinker.demo.security.UsuarioAutenticado;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Arrays;
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

class TurmaSimuladoCorrecaoServiceTest {

    private static final String CODIGO = "00123456";
    private static final String PUBLICACAO = "publicacao";
    private static final String EMAIL_ALUNO = "aluno@tinker.com";
    private static final Integer SIMULADO_ID = 15;
    private static final Integer QUESTAO_ID = 10;

    private TurmaService turmaService;
    private TurmaSimuladoRepository publicacaoRepository;
    private SimuladoRepository simuladoRepository;
    private QuestaoSimuRepository questaoSimuRepository;
    private QuestaoRepository questaoRepository;
    private RelatorioRepository relatorioRepository;
    private TurmaSimuladoService service;

    @BeforeEach
    void configurar() {
        turmaService = mock(TurmaService.class);
        publicacaoRepository = mock(TurmaSimuladoRepository.class);
        simuladoRepository = mock(SimuladoRepository.class);
        questaoSimuRepository = mock(QuestaoSimuRepository.class);
        questaoRepository = mock(QuestaoRepository.class);
        relatorioRepository = mock(RelatorioRepository.class);
        service = new TurmaSimuladoService(
                turmaService,
                publicacaoRepository,
                simuladoRepository,
                questaoSimuRepository,
                questaoRepository,
                new QuestaoMapper(),
                relatorioRepository,
                mock(Tinker.demo.repository.RelatorioSimuladoRepository.class));
        when(turmaService.buscarAtiva(CODIGO)).thenReturn(turma());
    }

    @Test
    void alunoMembroAtivoRespondeCorretamenteECriaRelatorio() {
        prepararCorrecao(questao("A", 1));

        CorrecaoQuestaoSimuladoDTO resposta = corrigir("A");

        assertTrue(resposta.acertou());
        assertEquals(null, resposta.alternativaCorreta());
        Relatorio salvo = relatorioSalvo();
        assertEquals(QUESTAO_ID, salvo.getCodQuest());
        assertEquals(EMAIL_ALUNO, salvo.getEmail());
        assertEquals(1, salvo.getAcertouErrou());
        assertEquals("ALUNO", salvo.getTipoUsu());
    }

    @Test
    void respostaErradaRetornaFalseETambemCriaRelatorio() {
        prepararCorrecao(questao("A", 1));

        CorrecaoQuestaoSimuladoDTO resposta = corrigir("B");

        assertFalse(resposta.acertou());
        assertEquals("A", resposta.alternativaCorreta());
        assertEquals(0, relatorioSalvo().getAcertouErrou());
    }

    @Test
    void novaRespostaSubstituiResultadoAnteriorSemDuplicar() {
        prepararCorrecao(questao("A", 1));
        Relatorio existente = new Relatorio(QUESTAO_ID, EMAIL_ALUNO, "ALUNO", 0);
        when(relatorioRepository.findByCodQuestAndEmailAndTipoUsu(
                QUESTAO_ID, EMAIL_ALUNO, "ALUNO"))
                .thenReturn(Optional.of(existente));

        CorrecaoQuestaoSimuladoDTO resposta = corrigir("A");

        assertTrue(resposta.acertou());
        assertEquals(1, existente.getAcertouErrou());
        verify(relatorioRepository, times(1)).save(existente);
    }

    @Test
    void alternativaEhNormalizada() {
        prepararCorrecao(questao("B", 1));

        assertTrue(corrigir("  b  ").acertou());
    }

    @Test
    void alternativaInvalidaEhRejeitadaSemPersistir() {
        prepararCorrecao(questao("A", 1));

        DadosInvalidosException erro = assertThrows(
                DadosInvalidosException.class,
                () -> corrigir("F"));

        assertEquals("ALTERNATIVA_INVALIDA", erro.getCodigo());
        verify(relatorioRepository, never()).save(any());
    }

    @Test
    void alternativaInexistenteNaQuestaoEhRejeitada() {
        Questao questao = questao("E", 1);
        questao.setAlternativaE(null);
        prepararCorrecao(questao);

        DadosInvalidosException erro = assertThrows(
                DadosInvalidosException.class,
                () -> corrigir("E"));

        assertEquals("ALTERNATIVA_INEXISTENTE", erro.getCodigo());
        verify(relatorioRepository, never()).save(any());
    }

    @Test
    void alunoNaoMembroEMembershipInativoRecebem404() {
        negarAcessoTurma();

        assertThrows(RecursoNaoEncontradoException.class, () -> corrigir("A"));
        assertThrows(RecursoNaoEncontradoException.class, () -> corrigir("A"));
        verify(publicacaoRepository, never()).findById(any());
        verify(relatorioRepository, never()).save(any());
    }

    @Test
    void professorEAdministradorRecebem403() {
        assertThrows(AcessoNegadoException.class,
                () -> service.corrigirQuestao(
                        usuario("prof@tinker.com", TipoUsuario.PROFESSOR),
                        CODIGO, PUBLICACAO, QUESTAO_ID, dados("A")));
        assertThrows(AcessoNegadoException.class,
                () -> service.corrigirQuestao(
                        usuario("adm@tinker.com", TipoUsuario.ADMINISTRADOR),
                        CODIGO, PUBLICACAO, QUESTAO_ID, dados("A")));
        verify(turmaService, never()).buscarAtiva(any());
        verify(relatorioRepository, never()).save(any());
    }

    @Test
    void turmaInativaRecebe404() {
        when(turmaService.buscarAtiva(CODIGO)).thenThrow(
                new RecursoNaoEncontradoException("TURMA_NAO_ENCONTRADA", "nao"));

        assertThrows(RecursoNaoEncontradoException.class, () -> corrigir("A"));
        verify(publicacaoRepository, never()).findById(any());
    }

    @Test
    void publicacaoInativaOuDeOutraTurmaRecebe404() {
        when(publicacaoRepository.findByIdPublicacaoAndCodTurmaAndAtivo(
                PUBLICACAO, CODIGO, 1)).thenReturn(Optional.empty());

        assertThrows(RecursoNaoEncontradoException.class, () -> corrigir("A"));
        verify(simuladoRepository, never()).findById(any());
        verify(relatorioRepository, never()).save(any());
    }

    @Test
    void simuladoInexistenteRecebe404() {
        prepararPublicacao();
        when(simuladoRepository.findById(SIMULADO_ID)).thenReturn(Optional.empty());

        assertThrows(RecursoNaoEncontradoException.class, () -> corrigir("A"));
        verify(questaoRepository, never()).findById(any());
    }

    @Test
    void questaoNaoAssociadaRecebe404() {
        prepararPublicacaoESimulado();
        when(questaoRepository.findById(QUESTAO_ID)).thenReturn(Optional.of(questao("A", 1)));
        when(questaoSimuRepository.existsById(new QuestaoSimuid(SIMULADO_ID, QUESTAO_ID)))
                .thenReturn(false);

        assertThrows(RecursoNaoEncontradoException.class, () -> corrigir("A"));
        verify(relatorioRepository, never()).save(any());
    }

    @Test
    void questaoInexistenteOuInativaRecebe404() {
        prepararPublicacaoESimulado();
        when(questaoRepository.findById(QUESTAO_ID))
                .thenReturn(Optional.empty(), Optional.of(questao("A", 0)));

        assertThrows(RecursoNaoEncontradoException.class, () -> corrigir("A"));
        assertThrows(RecursoNaoEncontradoException.class, () -> corrigir("A"));
        verify(relatorioRepository, never()).save(any());
    }

    @Test
    void respostaNaoExpoeTextoDoGabarito() {
        Questao questao = questao("GABARITO_SECRETO", 1);
        prepararCorrecao(questao);

        CorrecaoQuestaoSimuladoDTO resposta = corrigir("A");
        assertEquals(
                Arrays.asList("questaoId", "acertou", "alternativaCorreta"),
                Arrays.stream(CorrecaoQuestaoSimuladoDTO.class.getRecordComponents())
                        .map(componente -> componente.getName()).toList());
        assertEquals("C", resposta.alternativaCorreta());
        assertFalse(resposta.toString().contains("GABARITO_SECRETO"));
    }

    @Test
    void naoAlteraSimuladoAssociacoesPublicacaoOuCriaProgresso() {
        prepararCorrecao(questao("A", 1));
        Simulado simulado = simuladoRepository.findById(SIMULADO_ID).orElseThrow();

        corrigir("A");

        assertEquals(0, simulado.getConclusao());
        verify(simuladoRepository, never()).save(any());
        verify(simuladoRepository, never()).delete(any());
        verify(publicacaoRepository, never()).save(any());
        verify(publicacaoRepository, never()).delete(any());
        verify(questaoRepository, never()).save(any());
        verify(questaoSimuRepository, never()).save(any());
        verify(questaoSimuRepository, never()).delete(any());
    }

    private void prepararCorrecao(Questao questao) {
        prepararPublicacaoESimulado();
        when(questaoRepository.findById(QUESTAO_ID)).thenReturn(Optional.of(questao));
        when(questaoSimuRepository.existsById(new QuestaoSimuid(SIMULADO_ID, QUESTAO_ID)))
                .thenReturn(true);
        when(relatorioRepository.findByCodQuestAndEmailAndTipoUsu(
                QUESTAO_ID, EMAIL_ALUNO, "ALUNO"))
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

    private CorrecaoQuestaoSimuladoDTO corrigir(String alternativa) {
        return service.corrigirQuestao(
                aluno(), CODIGO, PUBLICACAO, QUESTAO_ID, dados(alternativa));
    }

    private Relatorio relatorioSalvo() {
        var captor = org.mockito.ArgumentCaptor.forClass(Relatorio.class);
        verify(relatorioRepository).save(captor.capture());
        return captor.getValue();
    }

    private CorrigirQuestaoPublicadaDTO dados(String alternativa) {
        CorrigirQuestaoPublicadaDTO dados = new CorrigirQuestaoPublicadaDTO();
        dados.setAlternativa(alternativa);
        return dados;
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

    private Questao questao(String resposta, int ativo) {
        Questao questao = new Questao();
        questao.setCodQuestao(QUESTAO_ID);
        questao.setAlternativaA("Texto A");
        questao.setAlternativaB("Texto B");
        questao.setAlternativaC("GABARITO_SECRETO");
        questao.setAlternativaD("Texto D");
        questao.setAlternativaE("Texto E");
        questao.setResposta(resposta);
        questao.setAtivo(ativo);
        return questao;
    }
}
