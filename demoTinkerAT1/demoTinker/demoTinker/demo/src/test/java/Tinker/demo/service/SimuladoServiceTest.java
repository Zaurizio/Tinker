package Tinker.demo.service;

import Tinker.demo.dto.simulado.AtualizarSimuladoDTO;
import Tinker.demo.dto.simulado.CriarSimuladoDTO;
import Tinker.demo.dto.simulado.SimuladoDetalheDTO;
import Tinker.demo.dto.simulado.SimuladoResumoDTO;
import Tinker.demo.exception.RecursoNaoEncontradoException;
import Tinker.demo.exception.AcessoNegadoException;
import Tinker.demo.model.Simulado;
import Tinker.demo.repository.QuestaoSimuRepository;
import Tinker.demo.repository.QuestaoRepository;
import Tinker.demo.mapper.QuestaoMapper;
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
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class SimuladoServiceTest {

    private static final String EMAIL_ALUNO = "aluno@tinker.com";
    private static final String EMAIL_PROFESSOR = "professor@tinker.com";

    private SimuladoRepository simuladoRepository;
    private QuestaoSimuRepository questaoSimuRepository;
    private RelatorioSimuladoRepository relatorioSimuladoRepository;
    private TurmaSimuladoRepository turmaSimuladoRepository;
    private SimuladoService simuladoService;
    private QuestaoRepository questaoRepository;

    @BeforeEach
    void configurar() {
        simuladoRepository = mock(SimuladoRepository.class);
        questaoSimuRepository = mock(QuestaoSimuRepository.class);
        relatorioSimuladoRepository = mock(RelatorioSimuladoRepository.class);
        turmaSimuladoRepository = mock(TurmaSimuladoRepository.class);
        questaoRepository = mock(QuestaoRepository.class);
        simuladoService = new SimuladoService(
                simuladoRepository,
                questaoSimuRepository,
                relatorioSimuladoRepository,
                turmaSimuladoRepository,
                questaoRepository,
                new QuestaoMapper());

        when(simuladoRepository.save(any(Simulado.class))).thenAnswer(invocacao -> {
            Simulado simulado = invocacao.getArgument(0);
            if (simulado.getCodSimulado() == null) {
                simulado.setCodSimulado(10);
            }
            return simulado;
        });
    }

    @Test
    void alunoNaoListaSimuladosProprios() {
        AcessoNegadoException erro = assertThrows(
                AcessoNegadoException.class,
                () -> simuladoService.listar(usuarioAluno()));

        assertEquals(403, erro.getStatus().value());
        verify(simuladoRepository, never()).findByEmailProfOrderByCodSimuladoAsc(any());
    }

    @Test
    void professorListaSomenteSeusSimulados() {
        Simulado proprio = simuladoProfessor(2, EMAIL_PROFESSOR);
        when(simuladoRepository.findByEmailProfOrderByCodSimuladoAsc(EMAIL_PROFESSOR))
                .thenReturn(List.of(proprio));

        List<SimuladoResumoDTO> resposta = simuladoService.listar(usuarioProfessor());

        assertEquals(List.of(2), resposta.stream().map(SimuladoResumoDTO::id).toList());
    }

    @Test
    void criacaoPreencheProfessorTipoECompatibilidade() {
        SimuladoDetalheDTO criado = simuladoService.criar(usuarioProfessor(), criar());
        Simulado professorSalvo = capturarUltimoSimuladoSalvo();

        assertNull(professorSalvo.getEmailAluno());
        assertEquals(EMAIL_PROFESSOR, professorSalvo.getEmailProf());
        assertEquals(Simulado.TIPO_USUARIO_PROFESSOR, professorSalvo.getTipoUsu());
        assertEquals(0, professorSalvo.getConclusao());
        assertEquals(0, criado.quantidadeQuestoes());
    }

    @Test
    void alunoNaoCriaSimulado() {
        AcessoNegadoException erro = assertThrows(
                AcessoNegadoException.class,
                () -> simuladoService.criar(usuarioAluno(), criar()));

        assertEquals(403, erro.getStatus().value());
        verify(simuladoRepository, never()).save(any());
    }

    @Test
    void usuarioNaoAcessaSimuladoDeOutraConta() {
        when(simuladoRepository.findById(1))
                .thenReturn(Optional.of(simuladoProfessor(1, "outro@tinker.com")));

        RecursoNaoEncontradoException erro = assertThrows(
                RecursoNaoEncontradoException.class,
                () -> simuladoService.detalhar(usuarioProfessor(), 1));

        assertEquals(404, erro.getStatus().value());
        assertEquals("SIMULADO_NAO_ENCONTRADO", erro.getCodigo());
        verify(questaoSimuRepository, never()).findCodQuestoesByCodSimulado(any());
    }

    @Test
    void criacaoVaziaNaoAssociaQuestoes() {
        SimuladoDetalheDTO resposta = simuladoService.criar(usuarioProfessor(), criar());

        assertEquals(0, resposta.quantidadeQuestoes());
        assertEquals(List.of(), resposta.questoesIds());
        verify(questaoSimuRepository, never()).save(any());
        verify(questaoSimuRepository, never()).saveAll(any());
    }

    @Test
    void renameAlteraSomenteCamposPermitidos() {
        Simulado existente = simuladoProfessor(1, EMAIL_PROFESSOR);
        existente.setConclusao(1);
        when(simuladoRepository.findById(1)).thenReturn(Optional.of(existente));
        when(questaoSimuRepository.findCodQuestoesByCodSimulado(1)).thenReturn(List.of(3, 4));
        AtualizarSimuladoDTO dados = new AtualizarSimuladoDTO();
        dados.setTitulo("Novo titulo");
        dados.setDescricao("Nova descricao");
        dados.setTempo(25F);

        SimuladoDetalheDTO resposta = simuladoService.atualizar(usuarioProfessor(), 1, dados);

        assertEquals("Novo titulo", existente.getNome());
        assertEquals("Nova descricao", existente.getDescricao());
        assertEquals(25F, existente.getTempo());
        assertEquals(1, existente.getConclusao());
        assertNull(existente.getEmailAluno());
        assertEquals(EMAIL_PROFESSOR, existente.getEmailProf());
        assertEquals(List.of(3, 4), resposta.questoesIds());
    }

    @Test
    void exclusaoRemoveDependenciasSemApagarQuestoes() {
        Simulado existente = simuladoProfessor(1, EMAIL_PROFESSOR);
        when(simuladoRepository.findById(1)).thenReturn(Optional.of(existente));

        simuladoService.excluir(usuarioProfessor(), 1);

        var ordem = inOrder(
                turmaSimuladoRepository,
                relatorioSimuladoRepository,
                questaoSimuRepository,
                simuladoRepository);
        ordem.verify(turmaSimuladoRepository).deleteByCodSimulado(1);
        ordem.verify(relatorioSimuladoRepository).deleteByCodSimulado(1);
        ordem.verify(questaoSimuRepository).deleteByCodSimulado(1);
        ordem.verify(simuladoRepository).delete(existente);

        verify(questaoRepository, never()).delete(any(Tinker.demo.model.Questao.class));
        verify(questaoRepository, never()).deleteById(any());
    }

    @Test
    void alunoNaoEditaNemExcluiSimulado() {
        AtualizarSimuladoDTO dados = new AtualizarSimuladoDTO();
        dados.setTitulo("Negado");

        assertThrows(AcessoNegadoException.class,
                () -> simuladoService.atualizar(usuarioAluno(), 1, dados));
        assertThrows(AcessoNegadoException.class,
                () -> simuladoService.excluir(usuarioAluno(), 1));

        verify(simuladoRepository, never()).findById(any());
        verify(simuladoRepository, never()).delete(any());
    }

    @Test
    void dtoNaoExpoeOwnershipSenhaOuEntity() {
        List<String> resumo = componentes(SimuladoResumoDTO.class);
        List<String> detalhe = componentes(SimuladoDetalheDTO.class);

        for (String proibido : List.of("emailAluno", "emailProf", "senha", "simulado")) {
            assertFalse(resumo.contains(proibido));
            assertFalse(detalhe.contains(proibido));
        }
    }

    private Simulado capturarUltimoSimuladoSalvo() {
        var captor = org.mockito.ArgumentCaptor.forClass(Simulado.class);
        verify(simuladoRepository).save(captor.capture());
        return captor.getValue();
    }

    private CriarSimuladoDTO criar() {
        CriarSimuladoDTO dto = new CriarSimuladoDTO();
        dto.setTitulo("Meu simulado");
        dto.setDescricao("Descricao");
        dto.setTempo(30F);
        return dto;
    }

    private UsuarioAutenticado usuarioAluno() {
        return new UsuarioAutenticado(EMAIL_ALUNO, TipoUsuario.ALUNO);
    }

    private UsuarioAutenticado usuarioProfessor() {
        return new UsuarioAutenticado(EMAIL_PROFESSOR, TipoUsuario.PROFESSOR);
    }

    private Simulado simuladoProfessor(Integer id, String email) {
        Simulado simulado = base(id);
        simulado.setEmailProf(email);
        simulado.setEmailAluno(null);
        simulado.setTipoUsu(Simulado.TIPO_USUARIO_PROFESSOR);
        return simulado;
    }

    private Simulado base(Integer id) {
        Simulado simulado = new Simulado();
        simulado.setCodSimulado(id);
        simulado.setNome("Simulado " + id);
        simulado.setDescricao("Descricao");
        simulado.setTempo(20F);
        simulado.setConclusao(0);
        return simulado;
    }

    private List<String> componentes(Class<?> tipo) {
        return Arrays.stream(tipo.getRecordComponents()).map(componente -> componente.getName()).toList();
    }
}
