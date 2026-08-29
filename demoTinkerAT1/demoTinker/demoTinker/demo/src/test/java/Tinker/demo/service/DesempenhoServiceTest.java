package Tinker.demo.service;

import Tinker.demo.dto.desempenho.DesempenhoDTO;
import Tinker.demo.dto.desempenho.DesempenhoDisciplinaDTO;
import Tinker.demo.exception.AcessoNegadoException;
import Tinker.demo.model.Questao;
import Tinker.demo.model.Relatorio;
import Tinker.demo.repository.QuestaoRepository;
import Tinker.demo.repository.RelatorioRepository;
import Tinker.demo.security.TipoUsuario;
import Tinker.demo.security.UsuarioAutenticado;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class DesempenhoServiceTest {

    private static final String EMAIL = "aluno@tinker.com";

    private RelatorioRepository relatorioRepository;
    private QuestaoRepository questaoRepository;
    private DesempenhoService service;

    @BeforeEach
    void configurar() {
        relatorioRepository = mock(RelatorioRepository.class);
        questaoRepository = mock(QuestaoRepository.class);
        service = new DesempenhoService(relatorioRepository, questaoRepository);
    }

    @Test
    void calculaTotaisPercentuaisEDestaquesPorDisciplina() {
        prepararRelatoriosValidos();

        DesempenhoDTO desempenho = service.consultar(aluno());

        assertEquals(5, desempenho.questoesRespondidas());
        assertEquals(3, desempenho.totalAcertos());
        assertEquals(60, desempenho.percentualGeral());
        assertEquals(disciplina("Matematica", 100, 2, 2), desempenho.maiorDesempenho());
        assertEquals(disciplina("Portugues", 33, 1, 3), desempenho.menorDesempenho());
    }

    @Test
    void percentualGeralEhPonderadoENaoMediaSimples() {
        prepararRelatoriosValidos();

        DesempenhoDTO desempenho = service.consultar(aluno());

        assertEquals(60, desempenho.percentualGeral());
        assertFalse(desempenho.percentualGeral() == 67);
    }

    @Test
    void disciplinasSaoOrdenadasAlfabeticamenteESemDisciplinasSemResposta() {
        prepararRelatoriosValidos();

        DesempenhoDTO desempenho = service.consultar(aluno());

        assertEquals(List.of("Matematica", "Portugues"), desempenho.disciplinas().stream()
                .map(DesempenhoDisciplinaDTO::disciplina).toList());
        assertFalse(desempenho.disciplinas().stream()
                .anyMatch(disciplina -> disciplina.disciplina().equals("Biologia")));
    }

    @Test
    void empateDeMaiorEMenorEhResolvidoPorOrdemAlfabetica() {
        when(relatorioRepository.findByEmailAndTipoUsu(EMAIL, "ALUNO"))
                .thenReturn(List.of(
                        relatorio(1, 1), relatorio(2, 0),
                        relatorio(3, 1), relatorio(4, 0)));
        when(questaoRepository.findAllById(List.of(1, 2, 3, 4)))
                .thenReturn(List.of(
                        questao(1, "Matematica"), questao(2, "Matematica"),
                        questao(3, "Historia"), questao(4, "Historia")));

        DesempenhoDTO desempenho = service.consultar(aluno());

        assertEquals("Historia", desempenho.maiorDesempenho().disciplina());
        assertEquals("Historia", desempenho.menorDesempenho().disciplina());
    }

    @Test
    void alunoSemRespostasRecebeEstruturaVazia() {
        when(relatorioRepository.findByEmailAndTipoUsu(EMAIL, "ALUNO")).thenReturn(List.of());

        DesempenhoDTO desempenho = service.consultar(aluno());

        assertEquals(0, desempenho.questoesRespondidas());
        assertEquals(0, desempenho.totalAcertos());
        assertEquals(0, desempenho.percentualGeral());
        assertNull(desempenho.maiorDesempenho());
        assertNull(desempenho.menorDesempenho());
        assertEquals(List.of(), desempenho.disciplinas());
        verify(questaoRepository, never()).findAllById(any());
    }

    @Test
    void ignoraQuestaoInexistenteDisciplinaNulaOuVaziaEResultadoInvalido() {
        List<Relatorio> relatorios = List.of(
                relatorio(1, 2),
                relatorio(2, 1),
                relatorio(3, 1),
                relatorio(4, 0),
                relatorio(5, null));
        when(relatorioRepository.findByEmailAndTipoUsu(EMAIL, "ALUNO")).thenReturn(relatorios);
        when(questaoRepository.findAllById(List.of(1, 2, 3, 4, 5))).thenReturn(List.of(
                questao(1, "Matematica"), questao(3, null),
                questao(4, "   "), questao(5, "Fisica")));

        DesempenhoDTO desempenho = service.consultar(aluno());

        assertEquals(0, desempenho.questoesRespondidas());
        assertEquals(List.of(), desempenho.disciplinas());
        assertNull(desempenho.maiorDesempenho());
        assertNull(desempenho.menorDesempenho());
    }

    @Test
    void professorConsultaSomenteSeuTipoEAdministradorRecebe403() {
        when(relatorioRepository.findByEmailAndTipoUsu(EMAIL, "PROFESSOR"))
                .thenReturn(List.of(relatorio(1, 1, "PROFESSOR")));
        when(questaoRepository.findAllById(List.of(1)))
                .thenReturn(List.of(questao(1, "Matematica")));

        DesempenhoDTO professor = service.consultar(usuario(EMAIL, TipoUsuario.PROFESSOR));

        assertEquals(1, professor.questoesRespondidas());
        verify(relatorioRepository).findByEmailAndTipoUsu(EMAIL, "PROFESSOR");
        assertThrows(AcessoNegadoException.class, () -> service.consultar(
                usuario("adm@tinker.com", TipoUsuario.ADMINISTRADOR)));
    }

    @Test
    void usaSomenteEmailAutenticadoETipoAluno() {
        when(relatorioRepository.findByEmailAndTipoUsu(EMAIL, "ALUNO")).thenReturn(List.of());

        service.consultar(aluno());

        verify(relatorioRepository).findByEmailAndTipoUsu(EMAIL, "ALUNO");
    }

    @Test
    void respostaNaoExpoeEmailGabaritoOuEntidades() {
        prepararRelatoriosValidos();

        DesempenhoDTO desempenho = service.consultar(aluno());

        assertEquals(Arrays.asList(
                        "questoesRespondidas", "totalAcertos", "percentualGeral",
                        "maiorDesempenho", "menorDesempenho", "disciplinas"),
                Arrays.stream(DesempenhoDTO.class.getRecordComponents())
                        .map(componente -> componente.getName()).toList());
        assertFalse(desempenho.toString().contains(EMAIL));
        assertFalse(desempenho.toString().contains("GABARITO"));
    }

    @Test
    void consultaEmLoteENaoExecutaEscritas() {
        prepararRelatoriosValidos();

        service.consultar(aluno());

        verify(questaoRepository).findAllById(List.of(1, 2, 3, 4, 5));
        verify(relatorioRepository, never()).save(any());
        verify(relatorioRepository, never()).delete(any());
        verify(questaoRepository, never()).save(any());
        verify(questaoRepository, never()).delete(any(Questao.class));
    }

    private void prepararRelatoriosValidos() {
        when(relatorioRepository.findByEmailAndTipoUsu(EMAIL, "ALUNO")).thenReturn(List.of(
                relatorio(1, 1), relatorio(2, 1),
                relatorio(3, 1), relatorio(4, 0), relatorio(5, 0)));
        when(questaoRepository.findAllById(List.of(1, 2, 3, 4, 5))).thenReturn(List.of(
                questao(1, "Matematica"), questao(2, "Matematica"),
                questao(3, "Portugues"), questao(4, "Portugues"),
                questao(5, "Portugues"), questao(6, "Biologia")));
    }

    private UsuarioAutenticado aluno() {
        return usuario(EMAIL, TipoUsuario.ALUNO);
    }

    private UsuarioAutenticado usuario(String email, TipoUsuario tipo) {
        return new UsuarioAutenticado(email, tipo);
    }

    private Relatorio relatorio(int questaoId, Integer resultado) {
        return relatorio(questaoId, resultado, "ALUNO");
    }

    private Relatorio relatorio(int questaoId, Integer resultado, String tipo) {
        Relatorio relatorio = new Relatorio();
        relatorio.setCodQuest(questaoId);
        relatorio.setEmail(EMAIL);
        relatorio.setTipoUsu(tipo);
        relatorio.setAcertouErrou(resultado);
        return relatorio;
    }

    private Questao questao(int id, String disciplina) {
        Questao questao = new Questao();
        questao.setCodQuestao(id);
        questao.setDisciplina(disciplina);
        questao.setResposta("GABARITO");
        return questao;
    }

    private DesempenhoDisciplinaDTO disciplina(
            String nome, int percentual, int acertos, int respondidas) {
        return new DesempenhoDisciplinaDTO(nome, percentual, acertos, respondidas);
    }
}
