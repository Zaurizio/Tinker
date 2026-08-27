package Tinker.demo.service;

import Tinker.demo.dto.turma.CriarTurmaDTO;
import Tinker.demo.dto.turma.EntrarTurmaDTO;
import Tinker.demo.dto.turma.MembroTurmaDTO;
import Tinker.demo.dto.turma.TurmaDTO;
import Tinker.demo.exception.AcessoNegadoException;
import Tinker.demo.exception.RecursoNaoEncontradoException;
import Tinker.demo.model.Aluno;
import Tinker.demo.model.AlunoTurma;
import Tinker.demo.model.AlunoTurmaid;
import Tinker.demo.model.Professor;
import Tinker.demo.model.Turma;
import Tinker.demo.repository.AlunoRepository;
import Tinker.demo.repository.AlunoTurmaRepository;
import Tinker.demo.repository.ProfessorRepository;
import Tinker.demo.repository.TurmaRepository;
import Tinker.demo.security.TipoUsuario;
import Tinker.demo.security.UsuarioAutenticado;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class TurmaServiceTest {

    private static final String CODIGO = "00123456";
    private static final String EMAIL_PROF = "prof@tinker.com";
    private static final String EMAIL_ALUNO = "aluno@tinker.com";

    private TurmaRepository turmaRepository;
    private AlunoTurmaRepository alunoTurmaRepository;
    private AlunoRepository alunoRepository;
    private ProfessorRepository professorRepository;
    private GeradorCodigoTurma gerador;
    private TurmaService service;

    @BeforeEach
    void configurar() {
        turmaRepository = mock(TurmaRepository.class);
        alunoTurmaRepository = mock(AlunoTurmaRepository.class);
        alunoRepository = mock(AlunoRepository.class);
        professorRepository = mock(ProfessorRepository.class);
        gerador = mock(GeradorCodigoTurma.class);
        service = new TurmaService(
                turmaRepository,
                alunoTurmaRepository,
                alunoRepository,
                professorRepository,
                gerador);

        when(turmaRepository.save(any(Turma.class))).thenAnswer(i -> i.getArgument(0));
        when(alunoTurmaRepository.save(any(AlunoTurma.class))).thenAnswer(i -> i.getArgument(0));
        when(professorRepository.findById(EMAIL_PROF)).thenReturn(Optional.of(professor()));
    }

    @Test
    void professorCriaTurmaComCodigoTextualEOitoDigitos() {
        when(gerador.gerar()).thenReturn(CODIGO);
        when(turmaRepository.existsById(CODIGO)).thenReturn(false);

        TurmaDTO resposta = service.criar(professorAutenticado(), criarDTO());

        var captor = org.mockito.ArgumentCaptor.forClass(Turma.class);
        verify(turmaRepository).save(captor.capture());
        Turma salva = captor.getValue();
        assertEquals(CODIGO, resposta.codigo());
        assertEquals(CODIGO, salva.getCodTurma());
        assertEquals(8, salva.getCodTurma().length());
        assertEquals(EMAIL_PROF, salva.getEmailProf());
        assertEquals(1, salva.getAtivo());
        verify(alunoTurmaRepository, never()).save(any());
    }

    @Test
    void alunoEAdministradorNaoCriamTurma() {
        assertThrows(AcessoNegadoException.class,
                () -> service.criar(alunoAutenticado(), criarDTO()));
        assertThrows(AcessoNegadoException.class,
                () -> service.criar(usuario("adm", TipoUsuario.ADMINISTRADOR), criarDTO()));
        verify(turmaRepository, never()).save(any());
    }

    @Test
    void colisaoGeraOutroCodigoEPreservaZeroAEsquerda() {
        when(gerador.gerar()).thenReturn("00000001", "00001234");
        when(turmaRepository.existsById("00000001")).thenReturn(true);
        when(turmaRepository.existsById("00001234")).thenReturn(false);

        TurmaDTO resposta = service.criar(professorAutenticado(), criarDTO());

        assertEquals("00001234", resposta.codigo());
        verify(gerador, times(2)).gerar();
    }

    @Test
    void professorListaSomenteTurmasAtivasProprias() {
        when(turmaRepository.findByEmailProfAndAtivoOrderByCodTurmaAsc(EMAIL_PROF, 1))
                .thenReturn(List.of(turmaAtiva()));

        List<TurmaDTO> resposta = service.listar(professorAutenticado());

        assertEquals(List.of(CODIGO), resposta.stream().map(TurmaDTO::codigo).toList());
        verify(turmaRepository).findByEmailProfAndAtivoOrderByCodTurmaAsc(EMAIL_PROF, 1);
    }

    @Test
    void alunoListaSomenteMembershipsAtivosEmTurmasAtivas() {
        when(alunoTurmaRepository.findByEmailAlunoAndAtivoOrderByCodTurmaAsc(EMAIL_ALUNO, 1))
                .thenReturn(List.of(membership(EMAIL_ALUNO, CODIGO, 1)));
        when(turmaRepository.findByCodTurmaInAndAtivoOrderByCodTurmaAsc(List.of(CODIGO), 1))
                .thenReturn(List.of(turmaAtiva()));

        List<TurmaDTO> resposta = service.listar(alunoAutenticado());

        assertEquals(List.of(CODIGO), resposta.stream().map(TurmaDTO::codigo).toList());
    }

    @Test
    void alunoEntraEmTurmaAtivaSemReceberEmailPeloDto() {
        prepararTurmaAtiva();
        when(alunoTurmaRepository.findById(new AlunoTurmaid(EMAIL_ALUNO, CODIGO)))
                .thenReturn(Optional.empty());
        when(alunoTurmaRepository.existsById(new AlunoTurmaid(EMAIL_ALUNO, CODIGO)))
                .thenReturn(false);

        service.entrar(alunoAutenticado(), entrarDTO());

        var captor = org.mockito.ArgumentCaptor.forClass(AlunoTurma.class);
        verify(alunoTurmaRepository).save(captor.capture());
        assertEquals(EMAIL_ALUNO, captor.getValue().getEmailAluno());
        assertEquals(CODIGO, captor.getValue().getCodTurma());
        assertEquals(1, captor.getValue().getAtivo());
    }

    @Test
    void entradaEmTurmaInexistenteOuInativaFalha() {
        when(turmaRepository.findById(CODIGO))
                .thenReturn(Optional.empty(), Optional.of(turma(CODIGO, EMAIL_PROF, 0)));

        assertThrows(RecursoNaoEncontradoException.class,
                () -> service.entrar(alunoAutenticado(), entrarDTO()));
        assertThrows(RecursoNaoEncontradoException.class,
                () -> service.entrar(alunoAutenticado(), entrarDTO()));
        verify(alunoTurmaRepository, never()).save(any());
    }

    @Test
    void membershipInativoEhReativado() {
        prepararTurmaAtiva();
        AlunoTurma inativo = membership(EMAIL_ALUNO, CODIGO, 0);
        when(alunoTurmaRepository.findById(new AlunoTurmaid(EMAIL_ALUNO, CODIGO)))
                .thenReturn(Optional.of(inativo));

        service.entrar(alunoAutenticado(), entrarDTO());

        assertEquals(1, inativo.getAtivo());
        verify(alunoTurmaRepository).save(inativo);
    }

    @Test
    void membershipAtivoTemEntradaIdempotente() {
        prepararTurmaAtiva();
        AlunoTurma ativo = membership(EMAIL_ALUNO, CODIGO, 1);
        when(alunoTurmaRepository.findById(new AlunoTurmaid(EMAIL_ALUNO, CODIGO)))
                .thenReturn(Optional.of(ativo));

        service.entrar(alunoAutenticado(), entrarDTO());

        verify(alunoTurmaRepository, never()).save(any());
    }

    @Test
    void alunoSaiComExclusaoLogica() {
        prepararTurmaAtiva();
        AlunoTurma membership = membership(EMAIL_ALUNO, CODIGO, 1);
        when(alunoTurmaRepository.findByEmailAlunoAndCodTurmaAndAtivo(EMAIL_ALUNO, CODIGO, 1))
                .thenReturn(Optional.of(membership));

        service.sair(alunoAutenticado(), CODIGO);

        assertEquals(0, membership.getAtivo());
        verify(alunoTurmaRepository).save(membership);
        verify(alunoTurmaRepository, never()).delete(any());
    }

    @Test
    void professorCriadorRemoveAlunoComExclusaoLogica() {
        prepararTurmaAtiva();
        AlunoTurma membership = membership(EMAIL_ALUNO, CODIGO, 1);
        when(alunoTurmaRepository.findByEmailAlunoAndCodTurmaAndAtivo(EMAIL_ALUNO, CODIGO, 1))
                .thenReturn(Optional.of(membership));

        service.removerMembro(professorAutenticado(), CODIGO, EMAIL_ALUNO);

        assertEquals(0, membership.getAtivo());
        verify(alunoTurmaRepository).save(membership);
    }

    @Test
    void outroProfessorNaoRemoveAluno() {
        prepararTurmaAtiva();

        assertThrows(RecursoNaoEncontradoException.class,
                () -> service.removerMembro(
                        usuario("outro@tinker.com", TipoUsuario.PROFESSOR),
                        CODIGO,
                        EMAIL_ALUNO));

        verify(alunoTurmaRepository, never()).save(any());
    }

    @Test
    void apenasCriadorOuMembroAtivoAbreTurma() {
        prepararTurmaAtiva();
        when(alunoTurmaRepository.findByEmailAlunoAndCodTurmaAndAtivo(EMAIL_ALUNO, CODIGO, 1))
                .thenReturn(Optional.of(membership(EMAIL_ALUNO, CODIGO, 1)));

        assertEquals(CODIGO, service.detalhar(professorAutenticado(), CODIGO).codigo());
        assertEquals(CODIGO, service.detalhar(alunoAutenticado(), CODIGO).codigo());
        assertThrows(RecursoNaoEncontradoException.class,
                () -> service.detalhar(
                        usuario("nao-membro@tinker.com", TipoUsuario.ALUNO), CODIGO));
    }

    @Test
    void usuariosAutorizadosListamSomenteMembrosAtivosComDtoSeguro() {
        prepararTurmaAtiva();
        when(alunoTurmaRepository.findByCodTurmaAndAtivoOrderByEmailAlunoAsc(CODIGO, 1))
                .thenReturn(List.of(membership(EMAIL_ALUNO, CODIGO, 1)));
        when(alunoRepository.findById(EMAIL_ALUNO)).thenReturn(Optional.of(aluno()));

        List<MembroTurmaDTO> membros = service.listarMembros(professorAutenticado(), CODIGO);

        assertEquals(1, membros.size());
        assertEquals(EMAIL_ALUNO, membros.get(0).email());
        assertFalse(membros.get(0).toString().contains("hash-secreto"));
    }

    @Test
    void usuarioSemAcessoNaoListaMembros() {
        prepararTurmaAtiva();

        assertThrows(RecursoNaoEncontradoException.class,
                () -> service.listarMembros(
                        usuario("nao-membro@tinker.com", TipoUsuario.ALUNO), CODIGO));

        verify(alunoTurmaRepository, never())
                .findByCodTurmaAndAtivoOrderByEmailAlunoAsc(CODIGO, 1);
    }

    @Test
    void desativarTurmaDesativaMembershipsNaMesmaOperacao() {
        Turma turma = turmaAtiva();
        AlunoTurma primeiro = membership(EMAIL_ALUNO, CODIGO, 1);
        AlunoTurma segundo = membership("outro@tinker.com", CODIGO, 1);
        when(turmaRepository.findById(CODIGO)).thenReturn(Optional.of(turma));
        when(alunoTurmaRepository.findByCodTurmaAndAtivoOrderByEmailAlunoAsc(CODIGO, 1))
                .thenReturn(List.of(primeiro, segundo));

        service.desativar(professorAutenticado(), CODIGO);

        assertEquals(0, turma.getAtivo());
        assertEquals(0, primeiro.getAtivo());
        assertEquals(0, segundo.getAtivo());
        var ordem = inOrder(alunoTurmaRepository, turmaRepository);
        ordem.verify(alunoTurmaRepository).saveAll(List.of(primeiro, segundo));
        ordem.verify(turmaRepository).save(turma);
        verify(turmaRepository, never()).delete(any());
        verify(alunoTurmaRepository, never()).delete(any());
    }

    private void prepararTurmaAtiva() {
        when(turmaRepository.findById(CODIGO)).thenReturn(Optional.of(turmaAtiva()));
    }

    private CriarTurmaDTO criarDTO() {
        CriarTurmaDTO dto = new CriarTurmaDTO();
        dto.setNome("Turma de Matematica");
        return dto;
    }

    private EntrarTurmaDTO entrarDTO() {
        EntrarTurmaDTO dto = new EntrarTurmaDTO();
        dto.setCodigo(CODIGO);
        return dto;
    }

    private Turma turmaAtiva() {
        return turma(CODIGO, EMAIL_PROF, 1);
    }

    private Turma turma(String codigo, String emailProfessor, int ativo) {
        Turma turma = new Turma();
        turma.setCodTurma(codigo);
        turma.setNomeTurma("Turma de Matematica");
        turma.setEmailProf(emailProfessor);
        turma.setAtivo(ativo);
        return turma;
    }

    private AlunoTurma membership(String email, String codigo, int ativo) {
        AlunoTurma membership = new AlunoTurma();
        membership.setEmailAluno(email);
        membership.setCodTurma(codigo);
        membership.setAtivo(ativo);
        return membership;
    }

    private Professor professor() {
        Professor professor = new Professor();
        professor.setEmail(EMAIL_PROF);
        professor.setNome("Professor Joao");
        professor.setSobrenome("Silva");
        professor.setSenha("hash-secreto");
        professor.setAtivo(1);
        return professor;
    }

    private Aluno aluno() {
        Aluno aluno = new Aluno();
        aluno.setEmail(EMAIL_ALUNO);
        aluno.setNome("Maria");
        aluno.setSobrenome("Silva");
        aluno.setSenha("hash-secreto");
        aluno.setAtivo(1);
        return aluno;
    }

    private UsuarioAutenticado professorAutenticado() {
        return usuario(EMAIL_PROF, TipoUsuario.PROFESSOR);
    }

    private UsuarioAutenticado alunoAutenticado() {
        return usuario(EMAIL_ALUNO, TipoUsuario.ALUNO);
    }

    private UsuarioAutenticado usuario(String email, TipoUsuario tipo) {
        return new UsuarioAutenticado(email, tipo);
    }
}
