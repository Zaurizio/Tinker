package Tinker.demo.service;

import Tinker.demo.dto.questao.PaginaQuestaoDTO;
import Tinker.demo.dto.questao.CorrigirQuestaoDTO;
import Tinker.demo.dto.questao.CorrecaoQuestaoDTO;
import Tinker.demo.dto.questao.ConteudosPorDisciplinaDTO;
import Tinker.demo.dto.questao.FiltrosQuestaoDTO;
import Tinker.demo.exception.AcessoNegadoException;
import Tinker.demo.exception.DadosInvalidosException;
import Tinker.demo.exception.RecursoNaoEncontradoException;
import Tinker.demo.mapper.QuestaoMapper;
import Tinker.demo.model.Questao;
import Tinker.demo.model.Relatorio;
import Tinker.demo.repository.QuestaoRepository;
import Tinker.demo.repository.RelatorioRepository;
import Tinker.demo.security.TipoUsuario;
import Tinker.demo.security.UsuarioAutenticado;
import Tinker.demo.specification.QuestaoSpecifications;
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
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.when;

@SuppressWarnings("unchecked")
class QuestaoServiceTest {

    private QuestaoRepository questaoRepository;
    private RelatorioRepository relatorioRepository;
    private QuestaoService questaoService;

    @BeforeEach
    void configurar() {
        questaoRepository = mock(QuestaoRepository.class);
        relatorioRepository = mock(RelatorioRepository.class);
        questaoService = new QuestaoService(
                questaoRepository, new QuestaoMapper(), relatorioRepository);
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
        Specification<Questao> specification = QuestaoSpecifications.comFiltros(
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

    @Test
    void respostaAvulsaCorretaCriaResultadoTipadoSemGabarito() {
        Questao questao = questaoAtiva();
        questao.setResposta("A");
        when(questaoRepository.findById(1)).thenReturn(Optional.of(questao));

        CorrecaoQuestaoDTO resposta = questaoService.corrigir(
                usuario("mesmo@teste.com", TipoUsuario.ALUNO), 1, new CorrigirQuestaoDTO(" a "));

        assertEquals(1, resposta.questaoId());
        assertTrue(resposta.acertou());
        assertEquals(null, resposta.alternativaCorreta());
        assertEquals(List.of("questaoId", "acertou", "alternativaCorreta"),
                java.util.Arrays.stream(CorrecaoQuestaoDTO.class.getRecordComponents())
                        .map(c -> c.getName()).toList());
        Relatorio salvo = relatorioSalvo();
        assertEquals("mesmo@teste.com", salvo.getEmail());
        assertEquals("ALUNO", salvo.getTipoUsu());
        assertEquals(1, salvo.getAcertouErrou());
    }

    @Test
    void respostaAvulsaIncorretaEhPersistida() {
        Questao questao = questaoAtiva();
        questao.setResposta("A");
        when(questaoRepository.findById(1)).thenReturn(Optional.of(questao));

        CorrecaoQuestaoDTO resposta = questaoService.corrigir(
                usuario("aluno@teste.com", TipoUsuario.ALUNO), 1, new CorrigirQuestaoDTO("B"));

        assertFalse(resposta.acertou());
        assertEquals("A", resposta.alternativaCorreta());
        assertEquals(0, relatorioSalvo().getAcertouErrou());
    }

    @Test
    void respostaAvulsaIncorretaConverteGabaritoTextualEmLetra() {
        Questao questao = questaoAtiva();
        questao.setAlternativaC("Texto correto");
        questao.setResposta("  Texto correto  ");
        when(questaoRepository.findById(1)).thenReturn(Optional.of(questao));

        CorrecaoQuestaoDTO resposta = questaoService.corrigir(
                usuario("aluno@teste.com", TipoUsuario.ALUNO), 1, new CorrigirQuestaoDTO("B"));

        assertFalse(resposta.acertou());
        assertEquals("C", resposta.alternativaCorreta());
    }

    @Test
    void novaRespostaSubstituiResultadoDaMesmaConta() {
        Questao questao = questaoAtiva();
        questao.setResposta("A");
        Relatorio existente = new Relatorio(1, "mesmo@teste.com", "PROFESSOR", 0);
        when(questaoRepository.findById(1)).thenReturn(Optional.of(questao));
        when(relatorioRepository.findByCodQuestAndEmailAndTipoUsu(
                1, "mesmo@teste.com", "PROFESSOR")).thenReturn(Optional.of(existente));

        questaoService.corrigir(
                usuario("mesmo@teste.com", TipoUsuario.PROFESSOR),
                1, new CorrigirQuestaoDTO("A"));

        assertEquals(1, existente.getAcertouErrou());
        verify(relatorioRepository).save(existente);
    }

    @Test
    void mesmoEmailMantemResultadosSeparadosPorTipo() {
        Questao questao = questaoAtiva();
        questao.setResposta("A");
        when(questaoRepository.findById(1)).thenReturn(Optional.of(questao));

        questaoService.corrigir(
                usuario("mesmo@teste.com", TipoUsuario.ALUNO), 1, new CorrigirQuestaoDTO("A"));
        questaoService.corrigir(
                usuario("mesmo@teste.com", TipoUsuario.PROFESSOR), 1, new CorrigirQuestaoDTO("B"));

        verify(relatorioRepository).findByCodQuestAndEmailAndTipoUsu(
                1, "mesmo@teste.com", "ALUNO");
        verify(relatorioRepository).findByCodQuestAndEmailAndTipoUsu(
                1, "mesmo@teste.com", "PROFESSOR");
    }

    @Test
    void alternativaInvalidaNaoPersiste() {
        when(questaoRepository.findById(1)).thenReturn(Optional.of(questaoAtiva()));
        assertThrows(DadosInvalidosException.class, () -> questaoService.corrigir(
                usuario("aluno@teste.com", TipoUsuario.ALUNO), 1, new CorrigirQuestaoDTO("F")));
        verify(relatorioRepository, never()).save(any());
    }

    @Test
    void questaoInexistenteOuInativaNaoPodeSerRespondida() {
        Questao inativa = questaoAtiva();
        inativa.setAtivo(0);
        when(questaoRepository.findById(1)).thenReturn(Optional.empty());
        when(questaoRepository.findById(2)).thenReturn(Optional.of(inativa));

        assertThrows(RecursoNaoEncontradoException.class, () -> questaoService.corrigir(
                usuario("aluno@teste.com", TipoUsuario.ALUNO), 1, new CorrigirQuestaoDTO("A")));
        assertThrows(RecursoNaoEncontradoException.class, () -> questaoService.corrigir(
                usuario("aluno@teste.com", TipoUsuario.ALUNO), 2, new CorrigirQuestaoDTO("A")));
        verify(relatorioRepository, never()).save(any());
    }

    @Test
    void administradorNaoPodeResponder() {
        assertThrows(AcessoNegadoException.class, () -> questaoService.corrigir(
                usuario("adm@teste.com", TipoUsuario.ADMINISTRADOR),
                1, new CorrigirQuestaoDTO("A")));
        verify(questaoRepository, never()).findById(any());
    }

    @Test
    void disciplinasNaoSeRepetemEConteudosFicamAgrupadosNaDisciplinaCorreta() {
        when(questaoRepository.findDisciplinasEConteudosAtivos()).thenReturn(List.of(
                par("Matematica", "Geometria"),
                par("Matematica", "Algebra"),
                par("Fisica", "Mecanica")));
        when(questaoRepository.findVestibularesAtivos()).thenReturn(List.of());
        when(questaoRepository.findAnosAtivos()).thenReturn(List.of());

        FiltrosQuestaoDTO filtros = questaoService.filtros();

        assertEquals(2, filtros.disciplinas().size());
        assertEquals(List.of("Fisica", "Matematica"),
                filtros.disciplinas().stream().map(ConteudosPorDisciplinaDTO::nome).toList());
        ConteudosPorDisciplinaDTO matematica = disciplina(filtros, "Matematica");
        assertEquals(List.of("Algebra", "Geometria"), matematica.conteudos());
        ConteudosPorDisciplinaDTO fisica = disciplina(filtros, "Fisica");
        assertEquals(List.of("Mecanica"), fisica.conteudos());
    }

    @Test
    void conteudoNaoEAssociadoAOutraDisciplinaPorEngano() {
        when(questaoRepository.findDisciplinasEConteudosAtivos()).thenReturn(List.of(
                par("Matematica", "Algebra"),
                par("Fisica", "Mecanica")));
        when(questaoRepository.findVestibularesAtivos()).thenReturn(List.of());
        when(questaoRepository.findAnosAtivos()).thenReturn(List.of());

        FiltrosQuestaoDTO filtros = questaoService.filtros();

        assertFalse(disciplina(filtros, "Fisica").conteudos().contains("Algebra"));
        assertFalse(disciplina(filtros, "Matematica").conteudos().contains("Mecanica"));
    }

    @Test
    void conteudosDuplicadosNaMesmaDisciplinaSaoRemovidos() {
        when(questaoRepository.findDisciplinasEConteudosAtivos()).thenReturn(List.of(
                par("Matematica", "Algebra"),
                par("Matematica", "Algebra"),
                par(" Matematica ", " Algebra ")));
        when(questaoRepository.findVestibularesAtivos()).thenReturn(List.of());
        when(questaoRepository.findAnosAtivos()).thenReturn(List.of());

        FiltrosQuestaoDTO filtros = questaoService.filtros();

        assertEquals(1, filtros.disciplinas().size());
        assertEquals(List.of("Algebra"), disciplina(filtros, "Matematica").conteudos());
    }

    @Test
    void mesmoConteudoPodeExistirEmDisciplinasDiferentesSemQuebrarOAgrupamento() {
        when(questaoRepository.findDisciplinasEConteudosAtivos()).thenReturn(List.of(
                par("Matematica", "Estatistica"),
                par("Fisica", "Estatistica")));
        when(questaoRepository.findVestibularesAtivos()).thenReturn(List.of());
        when(questaoRepository.findAnosAtivos()).thenReturn(List.of());

        FiltrosQuestaoDTO filtros = questaoService.filtros();

        assertEquals(List.of("Estatistica"), disciplina(filtros, "Matematica").conteudos());
        assertEquals(List.of("Estatistica"), disciplina(filtros, "Fisica").conteudos());
    }

    @Test
    void valoresNulosVaziosOuComEspacosSaoIgnorados() {
        when(questaoRepository.findDisciplinasEConteudosAtivos()).thenReturn(java.util.Arrays.asList(
                par(null, "Algebra"),
                par("Matematica", null),
                par("", "Algebra"),
                par("Matematica", "   "),
                par("Matematica", "Algebra")));
        when(questaoRepository.findVestibularesAtivos()).thenReturn(
                java.util.Arrays.asList(null, "", "   ", "ENEM"));
        when(questaoRepository.findAnosAtivos()).thenReturn(
                java.util.Arrays.asList((Integer) null, 2025));

        FiltrosQuestaoDTO filtros = questaoService.filtros();

        assertEquals(1, filtros.disciplinas().size());
        assertEquals(List.of("Algebra"), disciplina(filtros, "Matematica").conteudos());
        assertEquals(List.of("ENEM"), filtros.vestibulares());
        assertEquals(List.of(2025), filtros.anos());
    }

    @Test
    void espacosExternosSaoRemovidosDeDisciplinaConteudoEVestibular() {
        when(questaoRepository.findDisciplinasEConteudosAtivos())
                .thenReturn(List.of(par("  Matematica  ", "  Algebra  ")));
        when(questaoRepository.findVestibularesAtivos()).thenReturn(List.of("  ENEM  "));
        when(questaoRepository.findAnosAtivos()).thenReturn(List.of());

        FiltrosQuestaoDTO filtros = questaoService.filtros();

        assertEquals("Matematica", filtros.disciplinas().get(0).nome());
        assertEquals("Algebra", filtros.disciplinas().get(0).conteudos().get(0));
        assertEquals("ENEM", filtros.vestibulares().get(0));
    }

    @Test
    void disciplinasEConteudosFicamOrdenadosAlfabeticamente() {
        when(questaoRepository.findDisciplinasEConteudosAtivos()).thenReturn(List.of(
                par("Fisica", "Termodinamica"),
                par("Fisica", "Mecanica"),
                par("Matematica", "Probabilidade"),
                par("Matematica", "Algebra")));
        when(questaoRepository.findVestibularesAtivos()).thenReturn(List.of());
        when(questaoRepository.findAnosAtivos()).thenReturn(List.of());

        FiltrosQuestaoDTO filtros = questaoService.filtros();

        assertEquals(List.of("Fisica", "Matematica"),
                filtros.disciplinas().stream().map(ConteudosPorDisciplinaDTO::nome).toList());
        assertEquals(List.of("Mecanica", "Termodinamica"), disciplina(filtros, "Fisica").conteudos());
        assertEquals(List.of("Algebra", "Probabilidade"), disciplina(filtros, "Matematica").conteudos());
    }

    @Test
    void vestibularesFicamDistintosEOrdenadosAlfabeticamente() {
        when(questaoRepository.findDisciplinasEConteudosAtivos()).thenReturn(List.of());
        when(questaoRepository.findVestibularesAtivos())
                .thenReturn(List.of("FUVEST", "ENEM", "ENEM", "  FUVEST  "));
        when(questaoRepository.findAnosAtivos()).thenReturn(List.of());

        FiltrosQuestaoDTO filtros = questaoService.filtros();

        assertEquals(List.of("ENEM", "FUVEST"), filtros.vestibulares());
    }

    @Test
    void anosFicamDistintosEEmOrdemDecrescente() {
        when(questaoRepository.findDisciplinasEConteudosAtivos()).thenReturn(List.of());
        when(questaoRepository.findVestibularesAtivos()).thenReturn(List.of());
        when(questaoRepository.findAnosAtivos()).thenReturn(List.of(2024, 2026, 2025, 2025));

        FiltrosQuestaoDTO filtros = questaoService.filtros();

        assertEquals(List.of(2026, 2025, 2024), filtros.anos());
    }

    @Test
    void ausenciaDeOpcoesRetornaListasVazias() {
        when(questaoRepository.findDisciplinasEConteudosAtivos()).thenReturn(List.of());
        when(questaoRepository.findVestibularesAtivos()).thenReturn(List.of());
        when(questaoRepository.findAnosAtivos()).thenReturn(List.of());

        FiltrosQuestaoDTO filtros = questaoService.filtros();

        assertTrue(filtros.disciplinas().isEmpty());
        assertTrue(filtros.vestibulares().isEmpty());
        assertTrue(filtros.anos().isEmpty());
    }

    @Test
    void respostaDeFiltrosNaoExpoeQuestaoEnunciadoAlternativaOuGabarito() {
        assertEquals(List.of("disciplinas", "vestibulares", "anos"),
                java.util.Arrays.stream(FiltrosQuestaoDTO.class.getRecordComponents())
                        .map(java.lang.reflect.RecordComponent::getName).toList());
        assertEquals(List.of("nome", "conteudos"),
                java.util.Arrays.stream(ConteudosPorDisciplinaDTO.class.getRecordComponents())
                        .map(java.lang.reflect.RecordComponent::getName).toList());
    }

    private ConteudosPorDisciplinaDTO disciplina(FiltrosQuestaoDTO filtros, String nome) {
        return filtros.disciplinas().stream()
                .filter(item -> item.nome().equals(nome))
                .findFirst()
                .orElseThrow();
    }

    private Tinker.demo.repository.QuestaoRepository.DisciplinaConteudoProjecao par(
            String disciplina, String conteudo) {
        return new Tinker.demo.repository.QuestaoRepository.DisciplinaConteudoProjecao() {
            @Override
            public String getDisciplina() {
                return disciplina;
            }

            @Override
            public String getConteudo() {
                return conteudo;
            }
        };
    }

    private Relatorio relatorioSalvo() {
        var captor = org.mockito.ArgumentCaptor.forClass(Relatorio.class);
        verify(relatorioRepository).save(captor.capture());
        return captor.getValue();
    }

    private UsuarioAutenticado usuario(String email, TipoUsuario tipo) {
        return new UsuarioAutenticado(email, tipo);
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
