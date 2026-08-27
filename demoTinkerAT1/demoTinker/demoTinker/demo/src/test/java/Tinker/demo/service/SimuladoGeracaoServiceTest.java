package Tinker.demo.service;

import Tinker.demo.dto.simulado.GerarSimuladoDTO;
import Tinker.demo.dto.simulado.SimuladoGeradoDTO;
import Tinker.demo.exception.DadosInvalidosException;
import Tinker.demo.mapper.QuestaoMapper;
import Tinker.demo.model.Questao;
import Tinker.demo.model.QuestaoSimu;
import Tinker.demo.model.Simulado;
import Tinker.demo.repository.QuestaoRepository;
import Tinker.demo.repository.QuestaoSimuRepository;
import Tinker.demo.repository.RelatorioSimuladoRepository;
import Tinker.demo.repository.SimuladoRepository;
import Tinker.demo.repository.TurmaSimuladoRepository;
import Tinker.demo.security.TipoUsuario;
import Tinker.demo.security.UsuarioAutenticado;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Path;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collection;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@SuppressWarnings({"unchecked", "rawtypes"})
class SimuladoGeracaoServiceTest {

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
        when(simuladoRepository.save(any(Simulado.class))).thenAnswer(invocacao -> {
            Simulado simulado = invocacao.getArgument(0);
            simulado.setCodSimulado(25);
            return simulado;
        });
    }

    @Test
    void alunoConsegueGerarSimuladoComSomenteSeuDono() {
        prepararQuestoes(3);

        SimuladoGeradoDTO resposta = simuladoService.gerar(
                new UsuarioAutenticado("aluno@tinker.com", TipoUsuario.ALUNO), dados(3));

        Simulado salvo = capturarSimulado();
        assertEquals("aluno@tinker.com", salvo.getEmailAluno());
        assertNull(salvo.getEmailProf());
        assertEquals(0, salvo.getConclusao());
        assertEquals(3, resposta.quantidadeQuestoes());
    }

    @Test
    void professorConsegueGerarSimuladoComSomenteSeuDono() {
        prepararQuestoes(2);

        simuladoService.gerar(
                new UsuarioAutenticado("prof@tinker.com", TipoUsuario.PROFESSOR), dados(2));

        Simulado salvo = capturarSimulado();
        assertNull(salvo.getEmailAluno());
        assertEquals("prof@tinker.com", salvo.getEmailProf());
    }

    @Test
    void administradorEhRejeitadoAntesDaConsulta() {
        UsuarioAutenticado administrador =
                new UsuarioAutenticado("adm@tinker.com", TipoUsuario.ADMINISTRADOR);

        DadosInvalidosException erro = assertThrows(
                DadosInvalidosException.class,
                () -> simuladoService.gerar(administrador, dados(2)));

        assertEquals("TIPO_USUARIO_INVALIDO", erro.getCodigo());
        verify(questaoRepository, never()).findAll(any(Specification.class), any(Pageable.class));
        verify(simuladoRepository, never()).save(any());
    }

    @Test
    void filtrosSaoRepassadosPelaSpecificationCompartilhada() {
        GerarSimuladoDTO dados = dados(1);
        dados.setDisciplinas(List.of("Matematica"));
        dados.setConteudos(List.of("Algebra"));
        dados.setVestibulares(List.of("ENEM"));
        dados.setAnos(List.of(2024));
        prepararQuestoes(1);

        simuladoService.gerar(usuarioAluno(), dados);

        var specificationCaptor = org.mockito.ArgumentCaptor.forClass(Specification.class);
        verify(questaoRepository).findAll(specificationCaptor.capture(), any(Pageable.class));
        Root<Questao> root = mock(Root.class);
        CriteriaQuery<?> query = mock(CriteriaQuery.class);
        CriteriaBuilder builder = mock(CriteriaBuilder.class);
        Path path = mock(Path.class);
        Predicate predicate = mock(Predicate.class);
        when(root.get(anyString())).thenReturn(path);
        when(builder.equal(any(), any())).thenReturn(predicate);
        when(path.in(any(List.class))).thenReturn(predicate);

        specificationCaptor.getValue().toPredicate(root, query, builder);

        verify(root).get("ativo");
        verify(root).get("disciplina");
        verify(root).get("conteudo");
        verify(root).get("vestibular");
        verify(root).get("ano");
        verify(path).in(List.of("Matematica"));
        verify(path).in(List.of("Algebra"));
        verify(path).in(List.of("ENEM"));
        verify(path).in(List.of(2024));
    }

    @Test
    void todasETextosVaziosNaoRestringemFiltro() {
        GerarSimuladoDTO dados = dados(1);
        dados.setDisciplinas(List.of("todas"));
        dados.setConteudos(List.of("  "));
        dados.setVestibulares(List.of());
        prepararQuestoes(1);

        simuladoService.gerar(usuarioAluno(), dados);

        var specificationCaptor = org.mockito.ArgumentCaptor.forClass(Specification.class);
        verify(questaoRepository).findAll(specificationCaptor.capture(), any(Pageable.class));
        Root<Questao> root = mock(Root.class);
        CriteriaQuery<?> query = mock(CriteriaQuery.class);
        CriteriaBuilder builder = mock(CriteriaBuilder.class);
        Path path = mock(Path.class);
        Predicate predicate = mock(Predicate.class);
        when(root.get(anyString())).thenReturn(path);
        when(builder.equal(any(), any())).thenReturn(predicate);

        specificationCaptor.getValue().toPredicate(root, query, builder);

        verify(root).get("ativo");
        verify(root, never()).get("disciplina");
        verify(root, never()).get("conteudo");
        verify(root, never()).get("vestibular");
    }

    @Test
    void consultaConsideraAtivasQuantidadeEOrdemCrescente() {
        prepararQuestoes(4);

        simuladoService.gerar(usuarioAluno(), dados(4));

        var pageableCaptor = org.mockito.ArgumentCaptor.forClass(Pageable.class);
        verify(questaoRepository).findAll(any(Specification.class), pageableCaptor.capture());
        Pageable pageable = pageableCaptor.getValue();
        assertEquals(4, pageable.getPageSize());
        assertEquals(0, pageable.getPageNumber());
        assertEquals(Sort.Direction.ASC,
                pageable.getSort().getOrderFor("codQuestao").getDirection());

        var associacoes = org.mockito.ArgumentCaptor.forClass(Iterable.class);
        verify(questaoSimuRepository).saveAll(associacoes.capture());
        List<QuestaoSimu> salvas = ((Collection<QuestaoSimu>) associacoes.getValue()).stream().toList();
        assertEquals(List.of(1, 2, 3, 4),
                salvas.stream().map(QuestaoSimu::getCodQuestao).toList());
    }

    @Test
    void quantidadeForaDoIntervaloEhRejeitada() {
        DadosInvalidosException menor = assertThrows(
                DadosInvalidosException.class,
                () -> simuladoService.gerar(usuarioAluno(), dados(0)));
        DadosInvalidosException maior = assertThrows(
                DadosInvalidosException.class,
                () -> simuladoService.gerar(usuarioAluno(), dados(51)));

        assertEquals("QUANTIDADE_QUESTOES_INVALIDA", menor.getCodigo());
        assertEquals("QUANTIDADE_QUESTOES_INVALIDA", maior.getCodigo());
        verify(questaoRepository, never()).findAll(any(Specification.class), any(Pageable.class));
    }

    @Test
    void questoesInsuficientesNaoCriamSimuladoOuAssociacoes() {
        GerarSimuladoDTO dados = dados(3);
        when(questaoRepository.findAll(any(Specification.class), any(Pageable.class)))
                .thenReturn(new PageImpl<>(
                        List.of(questao(1), questao(2)),
                        PageRequest.of(0, 3),
                        2));

        DadosInvalidosException erro = assertThrows(
                DadosInvalidosException.class,
                () -> simuladoService.gerar(usuarioAluno(), dados));

        assertEquals("QUESTOES_INSUFICIENTES", erro.getCodigo());
        assertEquals(400, erro.getStatus().value());
        verify(simuladoRepository, never()).save(any());
        verify(questaoSimuRepository, never()).saveAll(any());
    }

    @Test
    void falhaNasAssociacoesPropagaParaRollbackTransacional() throws Exception {
        prepararQuestoes(2);
        doThrow(new RuntimeException("falha simulada"))
                .when(questaoSimuRepository).saveAll(any());

        assertThrows(RuntimeException.class,
                () -> simuladoService.gerar(usuarioAluno(), dados(2)));

        Transactional transacao = SimuladoService.class
                .getMethod("gerar", UsuarioAutenticado.class, GerarSimuladoDTO.class)
                .getAnnotation(Transactional.class);
        assertNotNull(transacao);
        verify(simuladoRepository).save(any(Simulado.class));
        verify(questaoSimuRepository).saveAll(any());
    }

    @Test
    void respostaNaoExpoeQuestoesOuGabarito() {
        prepararQuestoes(1);

        SimuladoGeradoDTO resposta = simuladoService.gerar(usuarioAluno(), dados(1));
        List<String> campos = java.util.Arrays.stream(SimuladoGeradoDTO.class.getRecordComponents())
                .map(componente -> componente.getName())
                .toList();

        assertEquals(List.of("id", "titulo", "quantidadeQuestoes"), campos);
        assertFalse(resposta.toString().contains("GABARITO_SECRETO"));
    }

    private void prepararQuestoes(int quantidade) {
        List<Questao> questoes = java.util.stream.IntStream.rangeClosed(1, quantidade)
                .mapToObj(this::questao)
                .toList();
        when(questaoRepository.findAll(any(Specification.class), any(Pageable.class)))
                .thenReturn(new PageImpl<>(
                        questoes,
                        PageRequest.of(0, quantidade),
                        quantidade));
    }

    private Simulado capturarSimulado() {
        var captor = org.mockito.ArgumentCaptor.forClass(Simulado.class);
        verify(simuladoRepository).save(captor.capture());
        return captor.getValue();
    }

    private UsuarioAutenticado usuarioAluno() {
        return new UsuarioAutenticado("aluno@tinker.com", TipoUsuario.ALUNO);
    }

    private GerarSimuladoDTO dados(int quantidade) {
        GerarSimuladoDTO dto = new GerarSimuladoDTO();
        dto.setTitulo("Simulado gerado");
        dto.setDescricao("Descricao");
        dto.setTempo(60F);
        dto.setQuantidadeQuestoes(quantidade);
        return dto;
    }

    private Questao questao(int id) {
        Questao questao = new Questao();
        questao.setCodQuestao(id);
        questao.setAtivo(1);
        questao.setResposta("GABARITO_SECRETO");
        return questao;
    }
}
