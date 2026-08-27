package Tinker.demo.service;

import Tinker.demo.dto.simulado.AtualizarSimuladoDTO;
import Tinker.demo.dto.simulado.CriarSimuladoDTO;
import Tinker.demo.dto.simulado.SimuladoDetalheDTO;
import Tinker.demo.dto.simulado.SimuladoResumoDTO;
import Tinker.demo.exception.RecursoNaoEncontradoException;
import Tinker.demo.model.Simulado;
import Tinker.demo.repository.QuestaoSimuRepository;
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

    @BeforeEach
    void configurar() {
        simuladoRepository = mock(SimuladoRepository.class);
        questaoSimuRepository = mock(QuestaoSimuRepository.class);
        relatorioSimuladoRepository = mock(RelatorioSimuladoRepository.class);
        turmaSimuladoRepository = mock(TurmaSimuladoRepository.class);
        simuladoService = new SimuladoService(
                simuladoRepository,
                questaoSimuRepository,
                relatorioSimuladoRepository,
                turmaSimuladoRepository);

        when(simuladoRepository.save(any(Simulado.class))).thenAnswer(invocacao -> {
            Simulado simulado = invocacao.getArgument(0);
            if (simulado.getCodSimulado() == null) {
                simulado.setCodSimulado(10);
            }
            return simulado;
        });
    }

    @Test
    void alunoListaSomenteSeusSimulados() {
        Simulado proprio = simuladoAluno(1, EMAIL_ALUNO);
        when(simuladoRepository.findByEmailAlunoOrderByCodSimuladoAsc(EMAIL_ALUNO))
                .thenReturn(List.of(proprio));
        when(questaoSimuRepository.countByCodSimulado(1)).thenReturn(2L);

        List<SimuladoResumoDTO> resposta = simuladoService.listar(usuarioAluno());

        assertEquals(List.of(1), resposta.stream().map(SimuladoResumoDTO::id).toList());
        assertEquals(2, resposta.get(0).quantidadeQuestoes());
        verify(simuladoRepository, never()).findByEmailProfOrderByCodSimuladoAsc(any());
    }

    @Test
    void professorListaSomenteSeusSimulados() {
        Simulado proprio = simuladoProfessor(2, EMAIL_PROFESSOR);
        when(simuladoRepository.findByEmailProfOrderByCodSimuladoAsc(EMAIL_PROFESSOR))
                .thenReturn(List.of(proprio));

        List<SimuladoResumoDTO> resposta = simuladoService.listar(usuarioProfessor());

        assertEquals(List.of(2), resposta.stream().map(SimuladoResumoDTO::id).toList());
        verify(simuladoRepository, never()).findByEmailAlunoOrderByCodSimuladoAsc(any());
    }

    @Test
    void criacaoPreencheSomenteDonoCorreto() {
        SimuladoDetalheDTO criadoAluno = simuladoService.criar(usuarioAluno(), criar());
        Simulado alunoSalvo = capturarUltimoSimuladoSalvo();

        assertEquals(EMAIL_ALUNO, alunoSalvo.getEmailAluno());
        assertNull(alunoSalvo.getEmailProf());
        assertEquals(0, alunoSalvo.getConclusao());
        assertEquals(0, criadoAluno.quantidadeQuestoes());

        simuladoService.criar(usuarioProfessor(), criar());
        var captor = org.mockito.ArgumentCaptor.forClass(Simulado.class);
        verify(simuladoRepository, org.mockito.Mockito.times(2)).save(captor.capture());
        Simulado professorSalvo = captor.getAllValues().get(1);
        assertNull(professorSalvo.getEmailAluno());
        assertEquals(EMAIL_PROFESSOR, professorSalvo.getEmailProf());
    }

    @Test
    void usuarioNaoAcessaSimuladoDeOutraConta() {
        when(simuladoRepository.findById(1))
                .thenReturn(Optional.of(simuladoAluno(1, "outro@tinker.com")));

        RecursoNaoEncontradoException erro = assertThrows(
                RecursoNaoEncontradoException.class,
                () -> simuladoService.detalhar(usuarioAluno(), 1));

        assertEquals(404, erro.getStatus().value());
        assertEquals("SIMULADO_NAO_ENCONTRADO", erro.getCodigo());
        verify(questaoSimuRepository, never()).findCodQuestoesByCodSimulado(any());
    }

    @Test
    void criacaoVaziaNaoAssociaQuestoes() {
        SimuladoDetalheDTO resposta = simuladoService.criar(usuarioAluno(), criar());

        assertEquals(0, resposta.quantidadeQuestoes());
        assertEquals(List.of(), resposta.questoesIds());
        verify(questaoSimuRepository, never()).save(any());
        verify(questaoSimuRepository, never()).saveAll(any());
    }

    @Test
    void renameAlteraSomenteCamposPermitidos() {
        Simulado existente = simuladoAluno(1, EMAIL_ALUNO);
        existente.setConclusao(1);
        when(simuladoRepository.findById(1)).thenReturn(Optional.of(existente));
        when(questaoSimuRepository.findCodQuestoesByCodSimulado(1)).thenReturn(List.of(3, 4));
        AtualizarSimuladoDTO dados = new AtualizarSimuladoDTO();
        dados.setTitulo("Novo titulo");
        dados.setDescricao("Nova descricao");
        dados.setTempo(25F);

        SimuladoDetalheDTO resposta = simuladoService.atualizar(usuarioAluno(), 1, dados);

        assertEquals("Novo titulo", existente.getNome());
        assertEquals("Nova descricao", existente.getDescricao());
        assertEquals(25F, existente.getTempo());
        assertEquals(1, existente.getConclusao());
        assertEquals(EMAIL_ALUNO, existente.getEmailAluno());
        assertNull(existente.getEmailProf());
        assertEquals(List.of(3, 4), resposta.questoesIds());
    }

    @Test
    void exclusaoRemoveDependenciasSemApagarQuestoes() {
        Simulado existente = simuladoAluno(1, EMAIL_ALUNO);
        when(simuladoRepository.findById(1)).thenReturn(Optional.of(existente));

        simuladoService.excluir(usuarioAluno(), 1);

        var ordem = inOrder(
                turmaSimuladoRepository,
                relatorioSimuladoRepository,
                questaoSimuRepository,
                simuladoRepository);
        ordem.verify(turmaSimuladoRepository).deleteByCodSimulado(1);
        ordem.verify(relatorioSimuladoRepository)
                .deleteByCodSimuladoAndEmailAluno(1, EMAIL_ALUNO);
        ordem.verify(questaoSimuRepository).deleteByCodSimulado(1);
        ordem.verify(simuladoRepository).delete(existente);

        assertFalse(Arrays.stream(SimuladoService.class.getDeclaredFields())
                .anyMatch(campo -> campo.getType().getSimpleName().equals("QuestaoRepository")));
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

    private Simulado simuladoAluno(Integer id, String email) {
        Simulado simulado = base(id);
        simulado.setEmailAluno(email);
        return simulado;
    }

    private Simulado simuladoProfessor(Integer id, String email) {
        Simulado simulado = base(id);
        simulado.setEmailProf(email);
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
