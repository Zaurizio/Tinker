package Tinker.demo.service;

import Tinker.demo.dto.questao.PaginaQuestaoDTO;
import Tinker.demo.exception.RecursoNaoEncontradoException;
import Tinker.demo.mapper.QuestaoMapper;
import Tinker.demo.model.Questao;
import Tinker.demo.repository.QuestaoRepository;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Expression;
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

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@SuppressWarnings("unchecked")
class QuestaoServiceTest {

    private QuestaoRepository questaoRepository;
    private QuestaoService questaoService;

    @BeforeEach
    void configurar() {
        questaoRepository = mock(QuestaoRepository.class);
        questaoService = new QuestaoService(questaoRepository, new QuestaoMapper());
    }

    @Test
    void paginaComTamanhoDezEOrdemCrescente() {
        Questao questao = questaoAtiva();
        when(questaoRepository.findAll(
                any(Specification.class), any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(questao), PageRequest.of(0, 10), 1));

        PaginaQuestaoDTO pagina = questaoService.listar(
                null, null, null, null, null, 0, 10);

        var pageable = org.mockito.ArgumentCaptor.forClass(Pageable.class);
        verify(questaoRepository).findAll(any(Specification.class), pageable.capture());
        assertEquals(10, pageable.getValue().getPageSize());
        assertEquals(0, pageable.getValue().getPageNumber());
        assertEquals(Sort.Direction.ASC,
                pageable.getValue().getSort().getOrderFor("codQuestao").getDirection());
        assertEquals(10, pagina.tamanho());
    }

    @Test
    void calculaTemMaisComResultadoPaginado() {
        when(questaoRepository.findAll(
                any(Specification.class), any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(questaoAtiva()), PageRequest.of(0, 10), 11));

        PaginaQuestaoDTO pagina = questaoService.listar(
                null, null, null, null, null, 0, 10);

        assertTrue(pagina.temMais());
        assertEquals(11, pagina.total());
    }

    @Test
    void semProximaPaginaRetornaTemMaisFalso() {
        when(questaoRepository.findAll(
                any(Specification.class), any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(questaoAtiva()), PageRequest.of(0, 10), 1));

        PaginaQuestaoDTO pagina = questaoService.listar(
                null, null, null, null, null, 0, 10);

        assertFalse(pagina.temMais());
    }

    @Test
    void questaoInativaOuInexistenteRetorna404() {
        Questao inativa = questaoAtiva();
        inativa.setAtivo(0);
        when(questaoRepository.findById(1)).thenReturn(Optional.of(inativa));
        when(questaoRepository.findById(2)).thenReturn(Optional.empty());

        RecursoNaoEncontradoException erroInativa = assertThrows(
                RecursoNaoEncontradoException.class, () -> questaoService.detalhar(1));
        RecursoNaoEncontradoException erroInexistente = assertThrows(
                RecursoNaoEncontradoException.class, () -> questaoService.detalhar(2));

        assertEquals("QUESTAO_NAO_ENCONTRADA", erroInativa.getCodigo());
        assertEquals(404, erroInativa.getStatus().value());
        assertEquals("QUESTAO_NAO_ENCONTRADA", erroInexistente.getCodigo());
    }

    @Test
    @SuppressWarnings({"unchecked", "rawtypes"})
    void encaminhaTodosOsFiltrosParaSpecification() {
        Specification<Questao> specification = questaoService.criarEspecificacao(
                List.of("Matematica", "Fisica"),
                List.of("Algebra"),
                List.of("ENEM"),
                List.of(2024, 2025),
                "  funcao  ");

        Root<Questao> root = mock(Root.class);
        CriteriaQuery<?> query = mock(CriteriaQuery.class);
        CriteriaBuilder builder = mock(CriteriaBuilder.class);
        Path path = mock(Path.class);
        Predicate predicate = mock(Predicate.class);
        Expression<String> textoMinusculo = mock(Expression.class);
        when(root.get(anyString())).thenReturn(path);
        when(builder.equal(any(), any())).thenReturn(predicate);
        when(path.in(any(List.class))).thenReturn(predicate);
        when(builder.lower(any())).thenReturn(textoMinusculo);
        when(builder.like(textoMinusculo, "%funcao%")).thenReturn(predicate);

        specification.toPredicate(root, query, builder);

        verify(root).get("ativo");
        verify(root).get("disciplina");
        verify(root).get("conteudo");
        verify(root).get("vestibular");
        verify(root).get("ano");
        verify(root).get("enunciado");
        verify(path).in(List.of("Matematica", "Fisica"));
        verify(path).in(List.of("Algebra"));
        verify(path).in(List.of("ENEM"));
        verify(path).in(List.of(2024, 2025));
        verify(builder).like(textoMinusculo, "%funcao%");
    }

    private Questao questaoAtiva() {
        Questao questao = new Questao();
        questao.setCodQuestao(1);
        questao.setVestibular("ENEM");
        questao.setAno(2025);
        questao.setDisciplina("Matematica");
        questao.setConteudo("Algebra");
        questao.setEnunciado("Enunciado");
        questao.setAlternativaA("A");
        questao.setAlternativaB("B");
        questao.setAlternativaC("C");
        questao.setAlternativaD("D");
        questao.setAtivo(1);
        return questao;
    }
}
