package Tinker.demo.service;

import Tinker.demo.dto.auth.CadastroRequestDTO;
import Tinker.demo.dto.auth.CadastroResponseDTO;
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
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Date;
import java.util.Locale;

@Service
public class AuthService {

    private final AlunoRepository alunoRepository;
    private final ProfessorRepository professorRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthService(
            AlunoRepository alunoRepository,
            ProfessorRepository professorRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService) {
        this.alunoRepository = alunoRepository;
        this.professorRepository = professorRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @Transactional
    public CadastroResponseDTO cadastrar(CadastroRequestDTO dados) {
        validarTipoCadastro(dados.getTipoUsuario());
        String email = normalizarEmail(dados.getEmail());

        if (dados.getTipoUsuario() == TipoUsuario.ALUNO) {
            if (alunoRepository.existsById(email)) {
                throw emailDuplicado();
            }

            Aluno aluno = new Aluno();
            aluno.setEmail(email);
            aluno.setSenha(passwordEncoder.encode(dados.getSenha()));
            aluno.setNome(dados.getNome().trim());
            aluno.setSobrenome(dados.getSobrenome().trim());
            aluno.setNascimento(Date.valueOf(dados.getNascimento()));
            aluno.setAtivo(1);
            alunoRepository.save(aluno);
            return new CadastroResponseDTO(email, aluno.getNome(), aluno.getSobrenome(), TipoUsuario.ALUNO);
        }

        if (dados.getTipoUsuario() == TipoUsuario.PROFESSOR) {
            if (professorRepository.existsById(email)) {
                throw emailDuplicado();
            }

            Professor professor = new Professor();
            professor.setEmail(email);
            professor.setSenha(passwordEncoder.encode(dados.getSenha()));
            professor.setNome(dados.getNome().trim());
            professor.setSobrenome(dados.getSobrenome().trim());
            professor.setAtivo(1);
            professorRepository.save(professor);
            return new CadastroResponseDTO(email, professor.getNome(), professor.getSobrenome(), TipoUsuario.PROFESSOR);
        }

        throw tipoCadastroInvalido();
    }

    @Transactional(readOnly = true)
    public LoginResponseDTO login(LoginRequestDTO dados) {
        validarTipoLogin(dados.getTipoUsuario());
        String email = normalizarEmail(dados.getEmail());

        if (dados.getTipoUsuario() == TipoUsuario.ALUNO) {
            Aluno aluno = alunoRepository.findById(email).orElseThrow(CredenciaisInvalidasException::new);
            validarCredenciais(aluno.getSenha(), aluno.getAtivo(), dados.getSenha());
            return resposta(email, aluno.getNome(), aluno.getSobrenome(), TipoUsuario.ALUNO);
        }

        if (dados.getTipoUsuario() == TipoUsuario.PROFESSOR) {
            Professor professor = professorRepository.findById(email)
                    .orElseThrow(CredenciaisInvalidasException::new);
            validarCredenciais(professor.getSenha(), professor.getAtivo(), dados.getSenha());
            return resposta(email, professor.getNome(), professor.getSobrenome(), TipoUsuario.PROFESSOR);
        }

        throw new CredenciaisInvalidasException();
    }

    private LoginResponseDTO resposta(String email, String nome, String sobrenome, TipoUsuario tipoUsuario) {
        String token = jwtService.gerarToken(email, tipoUsuario);
        return new LoginResponseDTO(token, "Bearer", email, nome, sobrenome, tipoUsuario);
    }

    private void validarCredenciais(String senhaHash, Integer ativo, String senhaInformada) {
        if (ativo == null || ativo != 1 || senhaHash == null || !passwordEncoder.matches(senhaInformada, senhaHash)) {
            throw new CredenciaisInvalidasException();
        }
    }

    private String normalizarEmail(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }

    private void validarTipoCadastro(TipoUsuario tipoUsuario) {
        if (tipoUsuario != TipoUsuario.ALUNO && tipoUsuario != TipoUsuario.PROFESSOR) {
            throw tipoCadastroInvalido();
        }
    }

    private void validarTipoLogin(TipoUsuario tipoUsuario) {
        if (tipoUsuario != TipoUsuario.ALUNO && tipoUsuario != TipoUsuario.PROFESSOR) {
            throw new CredenciaisInvalidasException();
        }
    }

    private DadosInvalidosException tipoCadastroInvalido() {
        return new DadosInvalidosException(
                "TIPO_USUARIO_INVALIDO",
                "O tipo de usuario deve ser ALUNO ou PROFESSOR.");
    }

    private ConflitoDominioException emailDuplicado() {
        return new ConflitoDominioException(
                "EMAIL_JA_CADASTRADO",
                "Este e-mail ja esta cadastrado para o tipo de usuario informado.");
    }
}
