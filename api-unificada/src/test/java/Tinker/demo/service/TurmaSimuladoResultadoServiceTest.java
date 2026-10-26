package Tinker.demo.service;

import Tinker.demo.dto.turma.ResultadoIndividualSimuladoDTO;
import Tinker.demo.exception.AcessoNegadoException;
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
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class TurmaSimuladoResultadoServiceTest {

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
                turmaService, publicacaoRepository, simuladoRepository,
                questaoSimuRepository, questaoRepository, new QuestaoMapper(),
                relatorioRepository, resultadoRepository);
        when(turmaService.buscarAtiva(CODIGO)).thenReturn(turma());
    }

    @Test
    void alunoMembroConsultaResultadoCompletoComTotaisCorretos() {
        prepararConsultaValida(Optional.of(resultado(7, 3)));

        ResultadoIndividualSimuladoDTO resposta = consultar();

        assertEquals(SIMULADO_ID, resposta.simuladoId());
        assertEquals(10, resposta.quantidadeQuestoes());
        assertTrue(resposta.completo());
        assertEquals(7, resposta.acertos());
        assertEquals(3, resposta.erros());
    }

    @Test
    void alunoSemResultadoRecebeIncompletoComTotaisNulos() {
        prepararConsultaValida(Optional.empty());

        ResultadoIndividualSimuladoDTO resposta = consultar();

        assertFalse(resposta.completo());
        assertEquals(2, resposta.quantidadeQuestoes());
        assertNull(resposta.acertos());
        assertNull(resposta.erros());
    }

    @Test
    void quantidadeConsideraSomenteQuestoesAtivasExistentes() {
        prepararPublicacaoESimulado();
        when(questaoSimuRepository.findCodQuestoesByCodSimulado(SIMULADO_ID))
                .thenReturn(List.of(10, 11, 12));
        when(questaoRepository.findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(
                List.of(10, 11, 12), 1)).thenReturn(List.of(questao(10), questao(12)));
        when(resultadoRepository.findByCodSimuladoAndEmailAluno(SIMULADO_ID, EMAIL_ALUNO))
                .thenReturn(Optional.empty());

        assertEquals(2, consultar().quantidadeQuestoes());
    }

    @Test
    void quantidadeAtualDiferenteNaoModificaResultadoConcluido() {
        prepararConsultaValida(Optional.of(resultado(7, 3)));

        ResultadoIndividualSimuladoDTO resposta = consultar();

        assertEquals(10, resposta.quantidadeQuestoes());
        assertEquals(7, resposta.acertos());
        assertEquals(3, resposta.erros());
        verify(questaoSimuRepository, never()).findCodQuestoesByCodSimulado(any());
        verify(questaoRepository, never())
                .findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(any(), any());
    }

    @Test
    void acertosOuErrosNulosSaoTratadosComoResultadoIncompleto() {
        prepararConsultaValida(Optional.of(resultado(null, 3)));

        ResultadoIndividualSimuladoDTO semAcertos = consultar();

        assertFalse(semAcertos.completo());
        assertEquals(2, semAcertos.quantidadeQuestoes());
        assertNull(semAcertos.acertos());
        assertNull(semAcertos.erros());

        when(resultadoRepository.findByCodSimuladoAndEmailAluno(SIMULADO_ID, EMAIL_ALUNO))
                .thenReturn(Optional.of(resultado(7, null)));

        ResultadoIndividualSimuladoDTO semErros = consultar();

        assertFalse(semErros.completo());
        assertEquals(2, semErros.quantidadeQuestoes());
        assertNull(semErros.acertos());
        assertNull(semErros.erros());
    }

    @Test
    void professorEAdministradorRecebem403() {
        assertThrows(AcessoNegadoException.class, () -> service.consultarResultado(
                usuario("prof@tinker.com", TipoUsuario.PROFESSOR), CODIGO, PUBLICACAO));
        assertThrows(AcessoNegadoException.class, () -> service.consultarResultado(
                usuario("adm@tinker.com", TipoUsuario.ADMINISTRADOR), CODIGO, PUBLICACAO));

        verify(turmaService, never()).buscarAtiva(any());
        verify(resultadoRepository, never()).findByCodSimuladoAndEmailAluno(any(), any());
    }

    @Test
    void alunoNaoMembroOuMembershipInativoRecebe404() {
        doThrow(new RecursoNaoEncontradoException("TURMA_NAO_ENCONTRADA", "nao"))
                .when(turmaService).exigirAcesso(any(), any());

        assertThrows(RecursoNaoEncontradoException.class, this::consultar);
        assertThrows(RecursoNaoEncontradoException.class, this::consultar);
        verify(publicacaoRepository, never())
                .findByIdPublicacaoAndCodTurmaAndAtivo(any(), any(), any());
    }

    @Test
    void turmaInativaRecebe404() {
        when(turmaService.buscarAtiva(CODIGO)).thenThrow(
                new RecursoNaoEncontradoException("TURMA_NAO_ENCONTRADA", "nao"));

        assertThrows(RecursoNaoEncontradoException.class, this::consultar);
        verify(publicacaoRepository, never())
                .findByIdPublicacaoAndCodTurmaAndAtivo(any(), any(), any());
    }

    @Test
    void publicacaoInexistenteInativaOuDeOutraTurmaRecebe404() {
        when(publicacaoRepository.findByIdPublicacaoAndCodTurmaAndAtivo(
                PUBLICACAO, CODIGO, 1)).thenReturn(Optional.empty());

        for (int tentativa = 0; tentativa < 3; tentativa++) {
            assertThrows(RecursoNaoEncontradoException.class, this::consultar);
        }
        verify(simuladoRepository, never()).findById(any());
    }

    @Test
    void simuladoInexistenteRecebe404() {
        prepararPublicacao();
        when(simuladoRepository.findById(SIMULADO_ID)).thenReturn(Optional.empty());

        assertThrows(RecursoNaoEncontradoException.class, this::consultar);
        verify(questaoSimuRepository, never()).findCodQuestoesByCodSimulado(any());
    }

    @Test
    void respostaNaoExpoeEmailGabaritoOuEntidade() {
        prepararConsultaValida(Optional.of(resultado(1, 1)));

        ResultadoIndividualSimuladoDTO resposta = consultar();

        assertEquals(Arrays.asList("simuladoId", "quantidadeQuestoes", "completo", "acertos", "erros"),
                Arrays.stream(ResultadoIndividualSimuladoDTO.class.getRecordComponents())
                        .map(componente -> componente.getName()).toList());
        assertFalse(resposta.toString().contains(EMAIL_ALUNO));
        assertFalse(resposta.toString().contains("GABARITO"));
    }

    @Test
    void consultaNaoExecutaEscritasNemAlteraRelatorioQuestaoOuConclusao() {
        prepararConsultaValida(Optional.of(resultado(1, 1)));
        Simulado simulado = simuladoRepository.findById(SIMULADO_ID).orElseThrow();

        consultar();

        assertEquals(0, simulado.getConclusao());
        verify(resultadoRepository, never()).save(any());
        verify(resultadoRepository, never()).delete(any());
        verify(relatorioRepository, never()).findById(any());
        verify(relatorioRepository, never()).save(any());
        verify(relatorioRepository, never()).delete(any());
        verify(simuladoRepository, never()).save(any());
        verify(publicacaoRepository, never()).save(any());
        verify(questaoRepository, never()).save(any());
        verify(questaoSimuRepository, never()).save(any());
    }

    private ResultadoIndividualSimuladoDTO consultar() {
        return service.consultarResultado(aluno(), CODIGO, PUBLICACAO);
    }

    private void prepararConsultaValida(Optional<RelatorioSimulado> resultado) {
        prepararPublicacaoESimulado();
        when(questaoSimuRepository.findCodQuestoesByCodSimulado(SIMULADO_ID))
                .thenReturn(List.of(10, 11, 12));
        when(questaoRepository.findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(
                List.of(10, 11, 12), 1)).thenReturn(List.of(questao(10), questao(11)));
        when(resultadoRepository.findByCodSimuladoAndEmailAluno(SIMULADO_ID, EMAIL_ALUNO))
                .thenReturn(resultado);
    }

    private void prepararPublicacaoESimulado() {
        prepararPublicacao();
        when(simuladoRepository.findById(SIMULADO_ID)).thenReturn(Optional.of(simulado()));
    }

    private void prepararPublicacao() {
        when(publicacaoRepository.findByIdPublicacaoAndCodTurmaAndAtivo(
                PUBLICACAO, CODIGO, 1)).thenReturn(Optional.of(publicacao()));
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

    private Questao questao(int id) {
        Questao questao = new Questao();
        questao.setCodQuestao(id);
        questao.setAtivo(1);
        questao.setResposta("GABARITO");
        return questao;
    }

    private RelatorioSimulado resultado(Integer acertos, Integer erros) {
        RelatorioSimulado resultado = new RelatorioSimulado();
        resultado.setCodSimulado(SIMULADO_ID);
        resultado.setEmailAluno(EMAIL_ALUNO);
        resultado.setAcertos(acertos);
        resultado.setErros(erros);
        return resultado;
    }
}
