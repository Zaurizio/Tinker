package Tinker.demo.service;

import Tinker.demo.dto.questao.QuestaoDTO;
import Tinker.demo.dto.simulado.QuantidadeQuestoesSimuladoDTO;
import Tinker.demo.dto.simulado.QuestoesIdsDTO;
import Tinker.demo.exception.RecursoNaoEncontradoException;
import Tinker.demo.exception.DadosInvalidosException;
import Tinker.demo.mapper.QuestaoMapper;
import Tinker.demo.model.Questao;
import Tinker.demo.model.QuestaoSimu;
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
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@SuppressWarnings("unchecked")
class SimuladoQuestoesServiceTest {

    private static final String EMAIL = "aluno@tinker.com";

    private SimuladoRepository simuladoRepository;
    private QuestaoSimuRepository questaoSimuRepository;
    private QuestaoRepository questaoRepository;
    private SimuladoService simuladoService;

    @BeforeEach
    void configurar() {
        simuladoRepository = mock(SimuladoRepository.class);
        questaoSimuRepository = mock(QuestaoSimuRepository.class);
        questaoRepository = mock(QuestaoRepository.class);
        simuladoService = new SimuladoService(
                simuladoRepository,
                questaoSimuRepository,
                mock(RelatorioSimuladoRepository.class),
                mock(TurmaSimuladoRepository.class),
                questaoRepository,
                new QuestaoMapper());
        when(simuladoRepository.findById(10)).thenReturn(Optional.of(simuladoDoDono()));
    }

    @Test
    void donoConsegueListarQuestoesEmOrdemSegura() {
        when(questaoSimuRepository.findCodQuestoesByCodSimulado(10)).thenReturn(List.of(2, 1));
        when(questaoRepository.findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(List.of(2, 1), 1))
                .thenReturn(List.of(questao(1, 1), questao(2, 1)));

        List<QuestaoDTO> resposta = simuladoService.listarQuestoes(usuario(), 10);

        assertEquals(List.of(1, 2), resposta.stream().map(QuestaoDTO::id).toList());
        assertFalse(componentes(QuestaoDTO.class).contains("resposta"));
        assertFalse(componentes(QuestaoDTO.class).contains("alternativaCorretaId"));
    }

    @Test
    void outroUsuarioNaoConsegueAcessarOuModificar() {
        UsuarioAutenticado outro = new UsuarioAutenticado("outro@tinker.com", TipoUsuario.ALUNO);

        assertThrows(RecursoNaoEncontradoException.class,
                () -> simuladoService.listarQuestoes(outro, 10));
        assertThrows(RecursoNaoEncontradoException.class,
                () -> simuladoService.adicionarQuestoes(outro, 10, ids(1)));
        assertThrows(RecursoNaoEncontradoException.class,
                () -> simuladoService.removerQuestao(outro, 10, 1));

        verify(questaoRepository, never())
                .findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(any(), any());
        verify(questaoSimuRepository, never()).saveAll(any());
        verify(questaoSimuRepository, never()).deleteById(any());
    }

    @Test
    void questoesAtivasSaoAssociadas() {
        Set<Integer> solicitadas = Set.of(1, 2);
        when(questaoRepository.findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(solicitadas, 1))
                .thenReturn(List.of(questao(1, 1), questao(2, 1)));
        when(questaoSimuRepository.findCodQuestoesByCodSimulado(10)).thenReturn(List.of());
        when(questaoSimuRepository.countByCodSimulado(10)).thenReturn(2L);

        QuantidadeQuestoesSimuladoDTO resposta =
                simuladoService.adicionarQuestoes(usuario(), 10, ids(1, 2));

        var captor = org.mockito.ArgumentCaptor.forClass(Iterable.class);
        verify(questaoSimuRepository).saveAll(captor.capture());
        List<QuestaoSimu> salvas = ((Collection<QuestaoSimu>) captor.getValue()).stream().toList();
        assertEquals(List.of(1, 2), salvas.stream().map(QuestaoSimu::getCodQuestao).toList());
        assertEquals(2, resposta.quantidadeQuestoes());
    }

    @Test
    void questaoInexistenteOuInativaRejeitaTodaOperacao() {
        Set<Integer> solicitadas = Set.of(1, 2);
        when(questaoRepository.findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(solicitadas, 1))
                .thenReturn(List.of(questao(1, 1)));

        RecursoNaoEncontradoException erro = assertThrows(
                RecursoNaoEncontradoException.class,
                () -> simuladoService.adicionarQuestoes(usuario(), 10, ids(1, 2)));

        assertEquals("QUESTAO_NAO_ENCONTRADA", erro.getCodigo());
        verify(questaoSimuRepository, never()).save(any());
        verify(questaoSimuRepository, never()).saveAll(any());
    }

    @Test
    void idsRepetidosNaoGeramAssociacoesDuplicadas() {
        Set<Integer> unica = Set.of(1);
        when(questaoRepository.findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(unica, 1))
                .thenReturn(List.of(questao(1, 1)));
        when(questaoSimuRepository.findCodQuestoesByCodSimulado(10)).thenReturn(List.of());

        simuladoService.adicionarQuestoes(usuario(), 10, ids(1, 1, 1));

        var captor = org.mockito.ArgumentCaptor.forClass(Iterable.class);
        verify(questaoSimuRepository).saveAll(captor.capture());
        assertEquals(1, ((Collection<?>) captor.getValue()).size());
    }

    @Test
    void questaoJaAssociadaNaoEhDuplicada() {
        Set<Integer> unica = Set.of(1);
        when(questaoRepository.findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(unica, 1))
                .thenReturn(List.of(questao(1, 1)));
        when(questaoSimuRepository.findCodQuestoesByCodSimulado(10)).thenReturn(List.of(1));

        simuladoService.adicionarQuestoes(usuario(), 10, ids(1));

        verify(questaoSimuRepository, never()).save(any());
        verify(questaoSimuRepository, never()).saveAll(any());
    }

    @Test
    void remocaoApagaSomenteQuestSimu() {
        QuestaoSimuid associacao = new QuestaoSimuid(10, 1);
        when(questaoSimuRepository.existsById(associacao)).thenReturn(true);

        simuladoService.removerQuestao(usuario(), 10, 1);

        verify(questaoSimuRepository).deleteById(associacao);
        verify(questaoRepository, never()).delete(any(Questao.class));
        verify(questaoRepository, never()).deleteById(any());
        verify(simuladoRepository, never()).delete(any());
    }

    @Test
    void remocaoDeAssociacaoInexistenteRetorna404() {
        QuestaoSimuid associacao = new QuestaoSimuid(10, 99);
        when(questaoSimuRepository.existsById(associacao)).thenReturn(false);

        RecursoNaoEncontradoException erro = assertThrows(
                RecursoNaoEncontradoException.class,
                () -> simuladoService.removerQuestao(usuario(), 10, 99));

        assertEquals(404, erro.getStatus().value());
        assertEquals("ASSOCIACAO_NAO_ENCONTRADA", erro.getCodigo());
        verify(questaoSimuRepository, never()).deleteById(any());
    }

    @Test
    void respostaCorretaNuncaEhExposta() {
        when(questaoSimuRepository.findCodQuestoesByCodSimulado(10)).thenReturn(List.of(1));
        when(questaoRepository.findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(List.of(1), 1))
                .thenReturn(List.of(questao(1, 1)));

        QuestaoDTO dto = simuladoService.listarQuestoes(usuario(), 10).get(0);

        assertFalse(dto.toString().contains("GABARITO_SECRETO"));
        assertFalse(componentes(QuestaoDTO.class).contains("resposta"));
    }

    @Test
    void repositoryDeQuestaoNuncaRecebeComandoDeExclusao() {
        QuestaoSimuid associacao = new QuestaoSimuid(10, 1);
        when(questaoSimuRepository.existsById(associacao)).thenReturn(true);

        simuladoService.removerQuestao(usuario(), 10, 1);

        verify(questaoRepository, never()).delete(any(Questao.class));
        verify(questaoRepository, never()).deleteAll(any(Iterable.class));
        verify(questaoRepository, never()).deleteAllById(any());
    }

    @Test
    void listaNulaOuVaziaEhRejeitada() {
        QuestoesIdsDTO nula = new QuestoesIdsDTO();
        QuestoesIdsDTO vazia = ids();

        assertThrows(DadosInvalidosException.class,
                () -> simuladoService.adicionarQuestoes(usuario(), 10, nula));
        assertThrows(DadosInvalidosException.class,
                () -> simuladoService.adicionarQuestoes(usuario(), 10, vazia));
        verify(questaoRepository, never())
                .findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(any(), any());
        verify(questaoSimuRepository, never()).saveAll(any());
    }

    private UsuarioAutenticado usuario() {
        return new UsuarioAutenticado(EMAIL, TipoUsuario.ALUNO);
    }

    private Simulado simuladoDoDono() {
        Simulado simulado = new Simulado();
        simulado.setCodSimulado(10);
        simulado.setEmailAluno(EMAIL);
        simulado.setNome("Simulado");
        simulado.setConclusao(0);
        return simulado;
    }

    private QuestoesIdsDTO ids(Integer... ids) {
        QuestoesIdsDTO dto = new QuestoesIdsDTO();
        dto.setQuestoesIds(Arrays.asList(ids));
        return dto;
    }

    private Questao questao(Integer id, Integer ativo) {
        Questao questao = new Questao();
        questao.setCodQuestao(id);
        questao.setVestibular("ENEM");
        questao.setAno(2025);
        questao.setDisciplina("Matematica");
        questao.setConteudo("Algebra");
        questao.setEnunciado("Enunciado " + id);
        questao.setAlternativaA("A");
        questao.setAlternativaB("B");
        questao.setAlternativaC("C");
        questao.setAlternativaD("D");
        questao.setResposta("GABARITO_SECRETO");
        questao.setAtivo(ativo);
        return questao;
    }

    private List<String> componentes(Class<?> tipo) {
        return Arrays.stream(tipo.getRecordComponents()).map(componente -> componente.getName()).toList();
    }
}
