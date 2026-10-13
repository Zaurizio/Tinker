package Tinker.demo.service;

import Tinker.demo.dto.auth.CadastroRequestDTO;
import Tinker.demo.dto.auth.LoginRequestDTO;
import Tinker.demo.dto.auth.LoginResponseDTO;
import Tinker.demo.exception.ConflitoDominioException;
import Tinker.demo.exception.CredenciaisInvalidasException;
import Tinker.demo.exception.DadosInvalidosException;
import Tinker.demo.model.Aluno;
import Tinker.demo.model.Professor;
import Tinker.demo.repository.AlunoRepository;
import Tinker.demo.repository.ProfessorRepository;
import Tinker.demo.security.JwtService;
import Tinker.demo.security.TipoUsuario;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDate;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicReference;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class AuthServiceTest {

    private AlunoRepository alunoRepository;
    private ProfessorRepository professorRepository;
    private JwtService jwtService;
    private PasswordEncoder passwordEncoder;
    private AuthService authService;

    @BeforeEach
    void configurar() {
        alunoRepository = mock(AlunoRepository.class);
        professorRepository = mock(ProfessorRepository.class);
        jwtService = mock(JwtService.class);
        passwordEncoder = new BCryptPasswordEncoder();
        authService = new AuthService(alunoRepository, professorRepository, passwordEncoder, jwtService);
    }

    @Test
    void cadastraEAutenticaAlunoComEmailNormalizado() {
        AtomicReference<Aluno> salvo = new AtomicReference<>();
        when(alunoRepository.save(any(Aluno.class))).thenAnswer(invocacao -> {
            Aluno aluno = invocacao.getArgument(0);
            salvo.set(aluno);
            return aluno;
        });
        when(alunoRepository.findById("aluno@tinker.com")).thenAnswer(ignorado -> Optional.of(salvo.get()));
        when(jwtService.gerarToken("aluno@tinker.com", TipoUsuario.ALUNO)).thenReturn("jwt-aluno");

        authService.cadastrar(cadastro(TipoUsuario.ALUNO, " Aluno@Tinker.COM ", LocalDate.of(2005, 5, 10)));
        LoginResponseDTO resposta = authService.login(login(TipoUsuario.ALUNO, " ALUNO@tinker.com ", "senha123"));

        assertEquals("aluno@tinker.com", salvo.get().getEmail());
        assertEquals(1, salvo.get().getAtivo());
        assertEquals("jwt-aluno", resposta.token());
        assertEquals(TipoUsuario.ALUNO, resposta.tipoUsuario());
        verify(professorRepository, never()).findById(any());
    }

    @Test
    void cadastraEAutenticaProfessorSemNascimento() {
        AtomicReference<Professor> salvo = new AtomicReference<>();
        when(professorRepository.save(any(Professor.class))).thenAnswer(invocacao -> {
            Professor professor = invocacao.getArgument(0);
            salvo.set(professor);
            return professor;
        });
        when(professorRepository.findById("prof@tinker.com")).thenAnswer(ignorado -> Optional.of(salvo.get()));
        when(jwtService.gerarToken("prof@tinker.com", TipoUsuario.PROFESSOR)).thenReturn("jwt-professor");

        authService.cadastrar(cadastro(TipoUsuario.PROFESSOR, "Prof@Tinker.com", null));
        LoginResponseDTO resposta = authService.login(login(TipoUsuario.PROFESSOR, "prof@tinker.com", "senha123"));

        assertEquals(1, salvo.get().getAtivo());
        assertEquals("jwt-professor", resposta.token());
        assertEquals(TipoUsuario.PROFESSOR, resposta.tipoUsuario());
        verify(alunoRepository, never()).findById(any());
    }

    @Test
    void rejeitaDuplicidadeSomenteNoMesmoTipo() {
        when(alunoRepository.existsById("igual@tinker.com")).thenReturn(true);

        assertThrows(ConflitoDominioException.class, () ->
                authService.cadastrar(cadastro(TipoUsuario.ALUNO, "igual@tinker.com", LocalDate.of(2000, 1, 1))));

        verify(professorRepository, never()).existsById(any());
        verify(alunoRepository, never()).save(any());
    }

    @Test
    void permiteMesmoEmailUmaVezComoAlunoEUmaVezComoProfessor() {
        String email = "mesmo@tinker.com";
        AtomicReference<Aluno> alunoSalvo = new AtomicReference<>();
        AtomicReference<Professor> professorSalvo = new AtomicReference<>();
        when(alunoRepository.save(any(Aluno.class))).thenAnswer(invocacao -> {
            Aluno aluno = invocacao.getArgument(0);
            alunoSalvo.set(aluno);
            return aluno;
        });
        when(professorRepository.save(any(Professor.class))).thenAnswer(invocacao -> {
            Professor professor = invocacao.getArgument(0);
            professorSalvo.set(professor);
            return professor;
        });

        authService.cadastrar(cadastro(TipoUsuario.ALUNO, email, LocalDate.of(2000, 1, 1)));
        authService.cadastrar(cadastro(TipoUsuario.PROFESSOR, email, null));

        verify(alunoRepository).existsById(email);
        verify(professorRepository).existsById(email);
        verify(alunoRepository).save(any(Aluno.class));
        verify(professorRepository).save(any(Professor.class));
        assertEquals(email, alunoSalvo.get().getEmail());
        assertEquals(email, professorSalvo.get().getEmail());
    }

    @Test
    void rejeitaTipoNuloOuAdministrativoNoServico() {
        CadastroRequestDTO cadastroNulo = cadastro(TipoUsuario.PROFESSOR, "teste@tinker.com", null);
        cadastroNulo.setTipoUsuario(null);

        assertThrows(DadosInvalidosException.class, () -> authService.cadastrar(cadastroNulo));
        assertThrows(CredenciaisInvalidasException.class, () ->
                authService.login(login(TipoUsuario.ADMINISTRADOR, "adm@tinker.com", "senha123")));
        verify(alunoRepository, never()).save(any());
        verify(professorRepository, never()).save(any());
    }

    @Test
    void armazenaSenhaComBCrypt() {
        AtomicReference<Professor> salvo = new AtomicReference<>();
        when(professorRepository.save(any(Professor.class))).thenAnswer(invocacao -> {
            Professor professor = invocacao.getArgument(0);
            salvo.set(professor);
            return professor;
        });

        authService.cadastrar(cadastro(TipoUsuario.PROFESSOR, "prof@tinker.com", null));

        assertNotEquals("senha123", salvo.get().getSenha());
        assertTrue(passwordEncoder.matches("senha123", salvo.get().getSenha()));
    }

    @Test
    void rejeitaSenhaIncorretaOuContaInativa() {
        Aluno aluno = aluno(passwordEncoder.encode("senha-correta"), 1);
        Professor professor = professor(passwordEncoder.encode("senha123"), 0);
        when(alunoRepository.findById("aluno@tinker.com")).thenReturn(Optional.of(aluno));
        when(professorRepository.findById("prof@tinker.com")).thenReturn(Optional.of(professor));

        assertThrows(CredenciaisInvalidasException.class, () ->
                authService.login(login(TipoUsuario.ALUNO, "aluno@tinker.com", "errada")));
        assertThrows(CredenciaisInvalidasException.class, () ->
                authService.login(login(TipoUsuario.PROFESSOR, "prof@tinker.com", "senha123")));
        verify(jwtService, never()).gerarToken(any(), any());
    }

    private CadastroRequestDTO cadastro(TipoUsuario tipo, String email, LocalDate nascimento) {
        CadastroRequestDTO dto = new CadastroRequestDTO();
        dto.setNome("Nome");
        dto.setSobrenome("Sobrenome");
        dto.setEmail(email);
        dto.setSenha("senha123");
        dto.setNascimento(nascimento);
        dto.setTipoUsuario(tipo);
        return dto;
    }

    private LoginRequestDTO login(TipoUsuario tipo, String email, String senha) {
        LoginRequestDTO dto = new LoginRequestDTO();
        dto.setEmail(email);
        dto.setSenha(senha);
        dto.setTipoUsuario(tipo);
        return dto;
    }

    private Aluno aluno(String senha, int ativo) {
        Aluno aluno = new Aluno();
        aluno.setEmail("aluno@tinker.com");
        aluno.setSenha(senha);
        aluno.setAtivo(ativo);
        return aluno;
    }

    private Professor professor(String senha, int ativo) {
        Professor professor = new Professor();
        professor.setEmail("prof@tinker.com");
        professor.setSenha(senha);
        professor.setAtivo(ativo);
        return professor;
    }
}
