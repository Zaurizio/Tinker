package Tinker.demo.service;

import Tinker.demo.dto.turma.PublicarSimuladoDTO;
import Tinker.demo.exception.AcessoNegadoException;
import Tinker.demo.exception.ConflitoDominioException;
import Tinker.demo.exception.RecursoNaoEncontradoException;
import Tinker.demo.model.Simulado;
import Tinker.demo.model.Questao;
import Tinker.demo.model.Turma;
import Tinker.demo.model.TurmaSimulado;
import Tinker.demo.repository.QuestaoSimuRepository;
import Tinker.demo.repository.QuestaoRepository;
import Tinker.demo.repository.RelatorioRepository;
import Tinker.demo.mapper.QuestaoMapper;
import Tinker.demo.repository.SimuladoRepository;
import Tinker.demo.repository.TurmaSimuladoRepository;
import Tinker.demo.security.TipoUsuario;
import Tinker.demo.security.UsuarioAutenticado;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class TurmaSimuladoServiceTest {

    private static final String CODIGO = "00123456";
    private static final String EMAIL_PROF = "prof@tinker.com";
    private static final String EMAIL_ALUNO = "aluno@tinker.com";

    private TurmaService turmaService;
    private TurmaSimuladoRepository publicacaoRepository;
    private SimuladoRepository simuladoRepository;
    private QuestaoSimuRepository questaoSimuRepository;
    private QuestaoRepository questaoRepository;
    private Tinker.demo.repository.RelatorioSimuladoRepository relatorioSimuladoRepository;
    private TurmaSimuladoService service;

    @BeforeEach
    void configurar() {
        turmaService = mock(TurmaService.class);
        publicacaoRepository = mock(TurmaSimuladoRepository.class);
        simuladoRepository = mock(SimuladoRepository.class);
        questaoSimuRepository = mock(QuestaoSimuRepository.class);
        questaoRepository = mock(QuestaoRepository.class);
        relatorioSimuladoRepository = mock(Tinker.demo.repository.RelatorioSimuladoRepository.class);
        service = new TurmaSimuladoService(
                turmaService,
                publicacaoRepository,
                simuladoRepository,
                questaoSimuRepository,
                questaoRepository,
                new QuestaoMapper(),
                mock(RelatorioRepository.class),
                relatorioSimuladoRepository);
        when(turmaService.buscarAtiva(CODIGO)).thenReturn(turma());
        when(simuladoRepository.findById(15)).thenReturn(Optional.of(simulado()));
        when(questaoSimuRepository.countByCodSimulado(15)).thenReturn(10L);
        when(publicacaoRepository.save(any(TurmaSimulado.class)))
                .thenAnswer(invocacao -> invocacao.getArgument(0));
    }

    @Test
    void professorCriadorPublicaSeuSimuladoComUuidDataIsoEAtivo() {
        when(publicacaoRepository.findByCodTurmaAndCodSimuladoOrderByIdPublicacaoAsc(CODIGO, 15))
                .thenReturn(List.of());

        var resultado = service.publicar(professor(), CODIGO, dados());

        var captor = org.mockito.ArgumentCaptor.forClass(TurmaSimulado.class);
        verify(publicacaoRepository).save(captor.capture());
        TurmaSimulado salva = captor.getValue();
        assertTrue(resultado.nova());
        assertEquals(1, salva.getAtivo());
        assertEquals(CODIGO, salva.getCodTurma());
        assertEquals(15, salva.getCodSimulado());
        assertEquals(salva.getIdPublicacao(), UUID.fromString(salva.getIdPublicacao()).toString());
        assertNotNull(OffsetDateTime.parse(salva.getDataPublicacao()));
        assertEquals(10, resultado.publicacao().quantidadeQuestoes());
    }

    @Test
    void alunoEAdministradorNaoPublicam() {
        org.mockito.Mockito.doThrow(new AcessoNegadoException("ACESSO_NEGADO", "negado"))
                .when(turmaService).exigirProfessor(any());

        assertThrows(AcessoNegadoException.class, () -> service.publicar(aluno(), CODIGO, dados()));
        assertThrows(AcessoNegadoException.class,
                () -> service.publicar(usuario("adm", TipoUsuario.ADMINISTRADOR), CODIGO, dados()));
        verify(publicacaoRepository, never()).save(any());
    }

    @Test
    void outroProfessorNaoPublicaNaTurma() {
        org.mockito.Mockito.doThrow(new RecursoNaoEncontradoException("TURMA_NAO_ENCONTRADA", "nao"))
                .when(turmaService).exigirCriador(any(), any());

        assertThrows(RecursoNaoEncontradoException.class,
                () -> service.publicar(usuario("outro@tinker.com", TipoUsuario.PROFESSOR), CODIGO, dados()));
        verify(publicacaoRepository, never()).save(any());
    }

    @Test
    void professorNaoPublicaSimuladoDeOutroProfessor() {
        Simulado alheio = simulado();
        alheio.setEmailProf("outro@tinker.com");
        when(simuladoRepository.findById(15)).thenReturn(Optional.of(alheio));

        assertThrows(RecursoNaoEncontradoException.class,
                () -> service.publicar(professor(), CODIGO, dados()));
        verify(publicacaoRepository, never()).save(any());
    }

    @Test
    void listaContendoPublicacaoAtivaRetornaConflito() {
        when(publicacaoRepository.findByCodTurmaAndCodSimuladoOrderByIdPublicacaoAsc(CODIGO, 15))
                .thenReturn(List.of(publicacao("a-inativa", 0), publicacao("b-ativa", 1)));

        ConflitoDominioException erro = assertThrows(ConflitoDominioException.class,
                () -> service.publicar(professor(), CODIGO, dados()));

        assertEquals("SIMULADO_JA_PUBLICADO", erro.getCodigo());
        verify(publicacaoRepository, never()).save(any());
    }

    @Test
    void duasPublicacoesInativasReativamSomenteAPrimeiraSemCriarNovaLinha() {
        TurmaSimulado inativa = publicacao("a-primeira", 0);
        TurmaSimulado outraInativa = publicacao("b-segunda", 0);
        String idOriginal = inativa.getIdPublicacao();
        when(publicacaoRepository.findByCodTurmaAndCodSimuladoOrderByIdPublicacaoAsc(CODIGO, 15))
                .thenReturn(List.of(inativa, outraInativa));

        var resultado = service.publicar(professor(), CODIGO, dados());

        assertEquals(false, resultado.nova());
        assertEquals(idOriginal, resultado.publicacao().idPublicacao());
        assertEquals(1, inativa.getAtivo());
        assertEquals(0, outraInativa.getAtivo());
        assertNotNull(OffsetDateTime.parse(inativa.getDataPublicacao()));
        verify(publicacaoRepository).save(inativa);
        verify(publicacaoRepository, never()).save(outraInativa);
        verify(publicacaoRepository).findByCodTurmaAndCodSimuladoOrderByIdPublicacaoAsc(CODIGO, 15);
    }

    @Test
    void criadorEAlunoMembroListamSomenteAtivasComDtoSeguro() {
        when(publicacaoRepository.findByCodTurmaAndAtivoOrderByDataPublicacaoDesc(CODIGO, 1))
                .thenReturn(List.of(publicacao(1)));

        var doProfessor = service.listar(professor(), CODIGO);
        var doAluno = service.listar(aluno(), CODIGO);

        assertEquals(1, doProfessor.size());
        assertEquals(1, doAluno.size());
        assertEquals("Simulado ENEM", doProfessor.get(0).titulo());
        assertEquals(10, doProfessor.get(0).quantidadeQuestoes());
        assertEquals(List.of(
                "idPublicacao", "simuladoId", "titulo", "descricao",
                "quantidadeQuestoes", "dataPublicacao", "concluido"),
                java.util.Arrays.stream(doProfessor.get(0).getClass().getRecordComponents())
                        .map(java.lang.reflect.RecordComponent::getName).toList());
        assertEquals(false, doProfessor.get(0).concluido());
        assertEquals(false, doAluno.get(0).concluido());
        verify(publicacaoRepository, org.mockito.Mockito.times(2))
                .findByCodTurmaAndAtivoOrderByDataPublicacaoDesc(CODIGO, 1);
    }

    @Test
    void alunoComResultadoValidoListaSimuladoComoConcluido() {
        when(publicacaoRepository.findByCodTurmaAndAtivoOrderByDataPublicacaoDesc(CODIGO, 1))
                .thenReturn(List.of(publicacao(1)));
        Tinker.demo.model.RelatorioSimulado resultado = new Tinker.demo.model.RelatorioSimulado();
        resultado.setAcertos(7);
        resultado.setErros(3);
        when(relatorioSimuladoRepository.findByCodSimuladoAndEmailAluno(15, EMAIL_ALUNO))
                .thenReturn(Optional.of(resultado));

        var doAluno = service.listar(aluno(), CODIGO);
        var doProfessor = service.listar(professor(), CODIGO);

        assertEquals(true, doAluno.get(0).concluido());
        assertEquals(false, doProfessor.get(0).concluido());
    }

    @Test
    void naoMembroNaoListaERegistroInconsistenteEhIgnorado() {
        org.mockito.Mockito.doThrow(new RecursoNaoEncontradoException("TURMA_NAO_ENCONTRADA", "nao"))
                .when(turmaService).exigirAcesso(any(), any());
        assertThrows(RecursoNaoEncontradoException.class,
                () -> service.listar(usuario("nao-membro@tinker.com", TipoUsuario.ALUNO), CODIGO));

        org.mockito.Mockito.doNothing().when(turmaService).exigirAcesso(any(), any());
        when(publicacaoRepository.findByCodTurmaAndAtivoOrderByDataPublicacaoDesc(CODIGO, 1))
                .thenReturn(List.of(publicacao(1)));
        when(simuladoRepository.findById(15)).thenReturn(Optional.empty());
        assertEquals(List.of(), service.listar(professor(), CODIGO));
    }

    @Test
    void somenteCriadorDespublicaPorExclusaoLogica() {
        TurmaSimulado ativa = publicacao(1);
        when(publicacaoRepository.findByIdPublicacaoAndCodTurmaAndAtivo(
                ativa.getIdPublicacao(), CODIGO, 1)).thenReturn(Optional.of(ativa));

        service.despublicar(professor(), CODIGO, ativa.getIdPublicacao());

        assertEquals(0, ativa.getAtivo());
        verify(publicacaoRepository).save(ativa);
        verify(publicacaoRepository, never()).delete(any());
        verify(simuladoRepository, never()).delete(any());
        verify(questaoSimuRepository, never()).delete(any());
    }

    @Test
    void outroProfessorNaoDespublicaEPublicacaoInativaRetorna404() {
        org.mockito.Mockito.doThrow(new RecursoNaoEncontradoException("TURMA_NAO_ENCONTRADA", "nao"))
                .when(turmaService).exigirCriador(any(), any());
        assertThrows(RecursoNaoEncontradoException.class,
                () -> service.despublicar(
                        usuario("outro@tinker.com", TipoUsuario.PROFESSOR), CODIGO, "id"));

        org.mockito.Mockito.doNothing().when(turmaService).exigirCriador(any(), any());
        when(publicacaoRepository.findByIdPublicacaoAndCodTurmaAndAtivo("id", CODIGO, 1))
                .thenReturn(Optional.empty());
        assertThrows(RecursoNaoEncontradoException.class,
                () -> service.despublicar(professor(), CODIGO, "id"));
        verify(publicacaoRepository, never()).save(any());
    }

    @Test
    void professorCriadorEAlunoMembroAtivoAbremQuestoes() {
        prepararAberturaValida();

        assertEquals(List.of(2, 7), service.listarQuestoes(
                professor(), CODIGO, "publicacao").stream().map(dto -> dto.id()).toList());
        assertEquals(List.of(2, 7), service.listarQuestoes(
                aluno(), CODIGO, "publicacao").stream().map(dto -> dto.id()).toList());

        verify(turmaService, org.mockito.Mockito.times(2)).exigirAcesso(any(), any());
        verify(questaoRepository, org.mockito.Mockito.times(2))
                .findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(List.of(2, 7, 11), 1);
    }

    @Test
    void alunoNaoMembroRecebe404AoAbrir() {
        negarAcessoATurma();

        assertThrows(RecursoNaoEncontradoException.class,
                () -> service.listarQuestoes(
                        usuario("nao-membro@tinker.com", TipoUsuario.ALUNO), CODIGO, "publicacao"));
        verify(publicacaoRepository, never()).findById(any());
    }

    @Test
    void membershipInativoRecebe404AoAbrir() {
        negarAcessoATurma();

        assertThrows(RecursoNaoEncontradoException.class,
                () -> service.listarQuestoes(aluno(), CODIGO, "publicacao"));
        verify(questaoSimuRepository, never()).findCodQuestoesByCodSimulado(any());
    }

    @Test
    void outroProfessorEAdministradorRecebem404AoAbrir() {
        negarAcessoATurma();

        assertThrows(RecursoNaoEncontradoException.class,
                () -> service.listarQuestoes(
                        usuario("outro@tinker.com", TipoUsuario.PROFESSOR), CODIGO, "publicacao"));
        assertThrows(RecursoNaoEncontradoException.class,
                () -> service.listarQuestoes(
                        usuario("adm@tinker.com", TipoUsuario.ADMINISTRADOR), CODIGO, "publicacao"));
    }

    @Test
    void turmaInativaRecebe404AoAbrir() {
        when(turmaService.buscarAtiva(CODIGO)).thenThrow(
                new RecursoNaoEncontradoException("TURMA_NAO_ENCONTRADA", "nao"));

        assertThrows(RecursoNaoEncontradoException.class,
                () -> service.listarQuestoes(aluno(), CODIGO, "publicacao"));
        verify(publicacaoRepository, never()).findById(any());
    }

    @Test
    void publicacaoInativaInexistenteOuDeOutraTurmaRecebe404() {
        when(publicacaoRepository.findByIdPublicacaoAndCodTurmaAndAtivo("inativa", CODIGO, 1))
                .thenReturn(Optional.empty());
        when(publicacaoRepository.findByIdPublicacaoAndCodTurmaAndAtivo("inexistente", CODIGO, 1))
                .thenReturn(Optional.empty());
        when(publicacaoRepository.findByIdPublicacaoAndCodTurmaAndAtivo("outra-turma", CODIGO, 1))
                .thenReturn(Optional.empty());

        assertThrows(RecursoNaoEncontradoException.class,
                () -> service.listarQuestoes(aluno(), CODIGO, "inativa"));
        assertThrows(RecursoNaoEncontradoException.class,
                () -> service.listarQuestoes(aluno(), CODIGO, "inexistente"));
        assertThrows(RecursoNaoEncontradoException.class,
                () -> service.listarQuestoes(aluno(), CODIGO, "outra-turma"));
        verify(simuladoRepository, never()).save(any());
    }

    @Test
    void questoesInexistentesEInativasSaoIgnoradasEmBuscaUnicaEOrdenada() {
        prepararAberturaValida();

        var resposta = service.listarQuestoes(aluno(), CODIGO, "publicacao");

        assertEquals(List.of(2, 7), resposta.stream().map(dto -> dto.id()).toList());
        verify(questaoRepository).findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(
                List.of(2, 7, 11), 1);
        verify(questaoRepository, never()).findById(any());
    }

    @Test
    void dtoNaoExpoeRespostaCorretaENenhumEstadoEhGravadoNaAbertura() {
        prepararAberturaValida();

        var resposta = service.listarQuestoes(aluno(), CODIGO, "publicacao");
        List<String> campos = java.util.Arrays.stream(
                        resposta.get(0).getClass().getRecordComponents())
                .map(java.lang.reflect.RecordComponent::getName)
                .toList();

        assertTrue(!campos.contains("resposta"));
        assertTrue(!campos.contains("gabarito"));
        verify(publicacaoRepository, never()).save(any());
        verify(simuladoRepository, never()).save(any());
        verify(questaoSimuRepository, never()).save(any());
        verify(questaoRepository, never()).save(any());
    }

    private void prepararAberturaValida() {
        when(publicacaoRepository.findByIdPublicacaoAndCodTurmaAndAtivo("publicacao", CODIGO, 1))
                .thenReturn(Optional.of(publicacao("publicacao", 1)));
        when(questaoSimuRepository.findCodQuestoesByCodSimulado(15))
                .thenReturn(List.of(2, 7, 11));
        when(questaoRepository.findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(
                List.of(2, 7, 11), 1)).thenReturn(List.of(questao(2), questao(7)));
    }

    private void negarAcessoATurma() {
        org.mockito.Mockito.doThrow(
                        new RecursoNaoEncontradoException("TURMA_NAO_ENCONTRADA", "nao"))
                .when(turmaService).exigirAcesso(any(), any());
    }

    private PublicarSimuladoDTO dados() {
        PublicarSimuladoDTO dados = new PublicarSimuladoDTO();
        dados.setSimuladoId(15);
        return dados;
    }

    private Turma turma() {
        Turma turma = new Turma();
        turma.setCodTurma(CODIGO);
        turma.setEmailProf(EMAIL_PROF);
        turma.setAtivo(1);
        return turma;
    }

    private Simulado simulado() {
        Simulado simulado = new Simulado();
        simulado.setCodSimulado(15);
        simulado.setNome("Simulado ENEM");
        simulado.setDescricao("Questoes de matematica");
        simulado.setEmailProf(EMAIL_PROF);
        return simulado;
    }

    private Questao questao(int id) {
        Questao questao = new Questao();
        questao.setCodQuestao(id);
        questao.setVestibular("ENEM");
        questao.setAno(2026);
        questao.setFase("Unica");
        questao.setDisciplina("Matematica");
        questao.setConteudo("Algebra");
        questao.setEnunciado("Enunciado " + id);
        questao.setAlternativaA("Alternativa A");
        questao.setAlternativaB("Alternativa B");
        questao.setResposta("A");
        questao.setAtivo(1);
        return questao;
    }

    private TurmaSimulado publicacao(int ativo) {
        return publicacao("d30ca6a8-4234-4bbf-9f5c-c2cf5bb64a80", ativo);
    }

    private TurmaSimulado publicacao(String idPublicacao, int ativo) {
        TurmaSimulado publicacao = new TurmaSimulado();
        publicacao.setIdPublicacao(idPublicacao);
        publicacao.setCodSimulado(15);
        publicacao.setCodTurma(CODIGO);
        publicacao.setAtivo(ativo);
        publicacao.setDataPublicacao("2026-08-28T15:30:00-03:00");
        return publicacao;
    }

    private UsuarioAutenticado professor() {
        return usuario(EMAIL_PROF, TipoUsuario.PROFESSOR);
    }

    private UsuarioAutenticado aluno() {
        return usuario(EMAIL_ALUNO, TipoUsuario.ALUNO);
    }

    private UsuarioAutenticado usuario(String email, TipoUsuario tipo) {
        return new UsuarioAutenticado(email, tipo);
    }
}
