package Tinker.demo.service;

import Tinker.demo.dto.simulado.CorrecaoQuestaoSimuladoDTO;
import Tinker.demo.dto.simulado.CorrigirQuestaoSimuladoDTO;
import Tinker.demo.exception.DadosInvalidosException;
import Tinker.demo.exception.AcessoNegadoException;
import Tinker.demo.exception.RecursoNaoEncontradoException;
import Tinker.demo.mapper.QuestaoMapper;
import Tinker.demo.model.Questao;
import Tinker.demo.model.QuestaoSimuid;
import Tinker.demo.model.Simulado;
import Tinker.demo.repository.QuestaoRepository;
import Tinker.demo.repository.QuestaoSimuRepository;
import Tinker.demo.repository.RelatorioSimuladoRepository;
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
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@SuppressWarnings("unchecked")
class SimuladoCorrecaoServiceTest {

    private SimuladoRepository simuladoRepository;
    private QuestaoSimuRepository questaoSimuRepository;
    private QuestaoRepository questaoRepository;
    private SimuladoService service;

    @BeforeEach
    void configurar() {
        simuladoRepository = mock(SimuladoRepository.class);
        questaoSimuRepository = mock(QuestaoSimuRepository.class);
        questaoRepository = mock(QuestaoRepository.class);
        service = new SimuladoService(
                simuladoRepository,
                questaoSimuRepository,
                mock(RelatorioSimuladoRepository.class),
                mock(TurmaSimuladoRepository.class),
                questaoRepository,
                new QuestaoMapper());
    }

    @Test
    void alunoNaoCorrigeSimuladoAntesDasPublicacoes() {
        AcessoNegadoException erro = assertThrows(AcessoNegadoException.class,
                () -> service.corrigirQuestao(
                        usuario("aluno@tinker.com", TipoUsuario.ALUNO), 10, dados("B")));

        assertEquals(403, erro.getStatus().value());
        verify(simuladoRepository, never()).findById(any());
    }

    @Test
    void professorDonoConsegueCorrigirAlternativaErrada() {
        preparar(null, "prof@tinker.com", questao("A", 1));

        CorrecaoQuestaoSimuladoDTO resposta = service.corrigirQuestao(
                usuario("prof@tinker.com", TipoUsuario.PROFESSOR), 10, dados("B"));

        assertFalse(resposta.acertou());
    }

    @Test
    void outroUsuarioNaoConsegueCorrigir() {
        preparar(null, "dono@tinker.com", questao("A", 1));

        assertThrows(RecursoNaoEncontradoException.class, () -> service.corrigirQuestao(
                usuario("outro@tinker.com", TipoUsuario.PROFESSOR), 10, dados("A")));

        verify(questaoSimuRepository, never()).existsById(any());
        verify(questaoRepository, never()).findById(any());
    }

    @Test
    void administradorEhRejeitado() {
        AcessoNegadoException erro = assertThrows(AcessoNegadoException.class,
                () -> service.corrigirQuestao(
                        usuario("adm@tinker.com", TipoUsuario.ADMINISTRADOR), 10, dados("A")));

        assertEquals(403, erro.getStatus().value());
        verify(simuladoRepository, never()).findById(any());
    }

    @Test
    void questaoNaoAssociadaRetorna404() {
        prepararSimulado(null, "prof@tinker.com");
        when(questaoSimuRepository.existsById(new QuestaoSimuid(10, 5))).thenReturn(false);

        RecursoNaoEncontradoException erro = assertThrows(RecursoNaoEncontradoException.class,
                () -> service.corrigirQuestao(
                        usuario("prof@tinker.com", TipoUsuario.PROFESSOR), 10, dados("A")));

        assertEquals(404, erro.getStatus().value());
        assertEquals("QUESTAO_NAO_PERTENCE_AO_SIMULADO", erro.getCodigo());
        verify(questaoRepository, never()).findById(any());
    }

    @Test
    void questaoInexistenteOuInativaEhRejeitada() {
        prepararSimulado(null, "prof@tinker.com");
        when(questaoSimuRepository.existsById(new QuestaoSimuid(10, 5))).thenReturn(true);
        when(questaoRepository.findById(5)).thenReturn(Optional.empty(), Optional.of(questao("A", 0)));

        for (int tentativa = 0; tentativa < 2; tentativa++) {
            RecursoNaoEncontradoException erro = assertThrows(RecursoNaoEncontradoException.class,
                    () -> service.corrigirQuestao(
                            usuario("prof@tinker.com", TipoUsuario.PROFESSOR), 10, dados("A")));
            assertEquals("QUESTAO_NAO_ENCONTRADA", erro.getCodigo());
        }
    }

    @Test
    void letraMinusculaComEspacosEhNormalizada() {
        preparar(null, "prof@tinker.com", questao("B", 1));

        assertTrue(service.corrigirQuestao(
                usuario("prof@tinker.com", TipoUsuario.PROFESSOR), 10, dados(" b ")).acertou());
    }

    @Test
    void identificadorInvalidoRetorna400() {
        preparar(null, "prof@tinker.com", questao("A", 1));

        DadosInvalidosException erro = assertThrows(DadosInvalidosException.class,
                () -> service.corrigirQuestao(
                        usuario("prof@tinker.com", TipoUsuario.PROFESSOR), 10, dados("F")));

        assertEquals(400, erro.getStatus().value());
        assertEquals("ALTERNATIVA_INVALIDA", erro.getCodigo());
    }

    @Test
    void alternativaEVaziaEhRejeitada() {
        Questao questao = questao("E", 1);
        questao.setAlternativaE("  ");
        preparar(null, "prof@tinker.com", questao);

        DadosInvalidosException erro = assertThrows(DadosInvalidosException.class,
                () -> service.corrigirQuestao(
                        usuario("prof@tinker.com", TipoUsuario.PROFESSOR), 10, dados("E")));

        assertEquals("ALTERNATIVA_INEXISTENTE", erro.getCodigo());
    }

    @Test
    void respostaLegadaComTextoDaAlternativaEhInterpretada() {
        preparar(null, "prof@tinker.com", questao("Texto correto", 1));

        assertTrue(service.corrigirQuestao(
                usuario("prof@tinker.com", TipoUsuario.PROFESSOR), 10, dados("C")).acertou());
    }

    @Test
    void respostaNaoExpoeGabaritoENadaEhPersistido() {
        preparar(null, "prof@tinker.com", questao("GABARITO_SECRETO", 1));

        CorrecaoQuestaoSimuladoDTO resposta = service.corrigirQuestao(
                usuario("prof@tinker.com", TipoUsuario.PROFESSOR), 10, dados("A"));

        assertEquals(
                Arrays.asList("questaoId", "acertou"),
                Arrays.stream(CorrecaoQuestaoSimuladoDTO.class.getRecordComponents())
                        .map(componente -> componente.getName()).toList());
        assertFalse(resposta.toString().contains("GABARITO_SECRETO"));
        verify(simuladoRepository, never()).save(any());
        verify(simuladoRepository, never()).delete(any());
        verify(questaoRepository, never()).save(any());
        verify(questaoRepository, never()).delete(any(Questao.class));
        verify(questaoSimuRepository, never()).save(any());
        verify(questaoSimuRepository, never()).delete(any());
        verify(questaoSimuRepository, never()).deleteById(any());
    }

    private void preparar(String emailAluno, String emailProfessor, Questao questao) {
        prepararSimulado(emailAluno, emailProfessor);
        when(questaoSimuRepository.existsById(new QuestaoSimuid(10, 5))).thenReturn(true);
        when(questaoRepository.findById(5)).thenReturn(Optional.of(questao));
    }

    private void prepararSimulado(String emailAluno, String emailProfessor) {
        Simulado simulado = new Simulado();
        simulado.setCodSimulado(10);
        simulado.setEmailAluno(emailAluno);
        simulado.setEmailProf(emailProfessor);
        simulado.setTipoUsu(Simulado.TIPO_USUARIO_PROFESSOR);
        simulado.setConclusao(0);
        when(simuladoRepository.findById(10)).thenReturn(Optional.of(simulado));
    }

    private Questao questao(String resposta, int ativo) {
        Questao questao = new Questao();
        questao.setCodQuestao(5);
        questao.setAlternativaA("Texto A");
        questao.setAlternativaB("Texto B");
        questao.setAlternativaC("Texto correto");
        questao.setAlternativaD("Texto D");
        questao.setAlternativaE(null);
        questao.setResposta(resposta);
        questao.setAtivo(ativo);
        return questao;
    }

    private CorrigirQuestaoSimuladoDTO dados(String alternativa) {
        CorrigirQuestaoSimuladoDTO dados = new CorrigirQuestaoSimuladoDTO();
        dados.setQuestaoId(5);
        dados.setAlternativaSelecionadaId(alternativa);
        return dados;
    }

    private UsuarioAutenticado usuario(String email, TipoUsuario tipo) {
        return new UsuarioAutenticado(email, tipo);
    }
}
