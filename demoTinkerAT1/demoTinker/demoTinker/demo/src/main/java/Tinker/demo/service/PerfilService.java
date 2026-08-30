package Tinker.demo.service;

import Tinker.demo.dto.perfil.AlterarSenhaDTO;
import Tinker.demo.dto.perfil.AtualizarPerfilDTO;
import Tinker.demo.dto.perfil.PerfilDTO;
import Tinker.demo.exception.DadosInvalidosException;
import Tinker.demo.exception.RecursoNaoEncontradoException;
import Tinker.demo.model.Aluno;
import Tinker.demo.model.Professor;
import Tinker.demo.repository.AlunoRepository;
import Tinker.demo.repository.ProfessorRepository;
import Tinker.demo.security.TipoUsuario;
import Tinker.demo.security.UsuarioAutenticado;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.sql.Date;
import java.util.Base64;

@Service
public class PerfilService {

    private static final byte[] ASSINATURA_JPEG = { (byte) 0xFF, (byte) 0xD8, (byte) 0xFF };
    private static final byte[] ASSINATURA_PNG =
            { (byte) 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A };

    private final AlunoRepository alunoRepository;
    private final ProfessorRepository professorRepository;
    private final PasswordEncoder passwordEncoder;

    public PerfilService(
            AlunoRepository alunoRepository,
            ProfessorRepository professorRepository,
            PasswordEncoder passwordEncoder) {
        this.alunoRepository = alunoRepository;
        this.professorRepository = professorRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional(readOnly = true)
    public PerfilDTO consultar(UsuarioAutenticado usuario) {
        if (usuario.tipoUsuario() == TipoUsuario.ALUNO) {
            return perfilAluno(buscarAluno(usuario.email()));
        }
        if (usuario.tipoUsuario() == TipoUsuario.PROFESSOR) {
            return perfilProfessor(buscarProfessor(usuario.email()));
        }
        throw tipoNaoPermitido();
    }

    @Transactional
    public PerfilDTO atualizar(UsuarioAutenticado usuario, AtualizarPerfilDTO dados) {
        if (usuario.tipoUsuario() == TipoUsuario.ALUNO) {
            if (dados.getNascimento() == null) {
                throw new DadosInvalidosException(
                        "NASCIMENTO_OBRIGATORIO",
                        "A data de nascimento e obrigatoria para aluno.");
            }
            Aluno aluno = buscarAluno(usuario.email());
            aluno.setNome(dados.getNome().trim());
            aluno.setSobrenome(dados.getSobrenome().trim());
            aluno.setNascimento(Date.valueOf(dados.getNascimento()));
            return perfilAluno(alunoRepository.save(aluno));
        }

        if (usuario.tipoUsuario() == TipoUsuario.PROFESSOR) {
            if (dados.getNascimento() != null) {
                throw new DadosInvalidosException(
                        "NASCIMENTO_NAO_PERMITIDO",
                        "Professor nao possui data de nascimento no perfil.");
            }
            Professor professor = buscarProfessor(usuario.email());
            professor.setNome(dados.getNome().trim());
            professor.setSobrenome(dados.getSobrenome().trim());
            return perfilProfessor(professorRepository.save(professor));
        }

        throw tipoNaoPermitido();
    }

    @Transactional
    public void alterarSenha(UsuarioAutenticado usuario, AlterarSenhaDTO dados) {
        if (usuario.tipoUsuario() == TipoUsuario.ALUNO) {
            Aluno aluno = buscarAluno(usuario.email());
            validarSenhaAtual(dados.getSenhaAtual(), aluno.getSenha());
            aluno.setSenha(passwordEncoder.encode(dados.getNovaSenha()));
            alunoRepository.save(aluno);
            return;
        }

        if (usuario.tipoUsuario() == TipoUsuario.PROFESSOR) {
            Professor professor = buscarProfessor(usuario.email());
            validarSenhaAtual(dados.getSenhaAtual(), professor.getSenha());
            professor.setSenha(passwordEncoder.encode(dados.getNovaSenha()));
            professorRepository.save(professor);
            return;
        }

        throw tipoNaoPermitido();
    }

    @Transactional
    public PerfilDTO enviarFoto(UsuarioAutenticado usuario, MultipartFile arquivo) {
        if (arquivo == null || arquivo.isEmpty()) {
            throw new DadosInvalidosException(
                    "FOTO_OBRIGATORIA",
                    "Selecione uma foto para enviar.");
        }

        byte[] bytes;
        try {
            bytes = arquivo.getBytes();
        } catch (IOException excecaoLeitura) {
            throw new DadosInvalidosException(
                    "FOTO_INVALIDA",
                    "Nao foi possivel ler a foto enviada.");
        }

        if (tipoImagem(bytes) == null) {
            throw new DadosInvalidosException(
                    "FOTO_FORMATO_INVALIDO",
                    "A foto deve estar no formato JPG ou PNG.");
        }

        if (usuario.tipoUsuario() == TipoUsuario.ALUNO) {
            Aluno aluno = buscarAluno(usuario.email());
            aluno.setFoto(bytes);
            return perfilAluno(alunoRepository.save(aluno));
        }

        if (usuario.tipoUsuario() == TipoUsuario.PROFESSOR) {
            Professor professor = buscarProfessor(usuario.email());
            professor.setFoto(bytes);
            return perfilProfessor(professorRepository.save(professor));
        }

        throw tipoNaoPermitido();
    }

    @Transactional
    public void inativar(UsuarioAutenticado usuario) {
        if (usuario.tipoUsuario() == TipoUsuario.ALUNO) {
            Aluno aluno = buscarAluno(usuario.email());
            aluno.setAtivo(0);
            alunoRepository.save(aluno);
            return;
        }

        if (usuario.tipoUsuario() == TipoUsuario.PROFESSOR) {
            Professor professor = buscarProfessor(usuario.email());
            professor.setAtivo(0);
            professorRepository.save(professor);
            return;
        }

        throw tipoNaoPermitido();
    }

    private Aluno buscarAluno(String email) {
        return alunoRepository.findById(email).orElseThrow(this::perfilNaoEncontrado);
    }

    private Professor buscarProfessor(String email) {
        return professorRepository.findById(email).orElseThrow(this::perfilNaoEncontrado);
    }

    private PerfilDTO perfilAluno(Aluno aluno) {
        return new PerfilDTO(
                aluno.getEmail(),
                aluno.getNome(),
                aluno.getSobrenome(),
                TipoUsuario.ALUNO,
                aluno.getNascimento() == null ? null : aluno.getNascimento().toLocalDate(),
                aluno.getAtivo(),
                paraDataUri(aluno.getFoto()));
    }

    private PerfilDTO perfilProfessor(Professor professor) {
        return new PerfilDTO(
                professor.getEmail(),
                professor.getNome(),
                professor.getSobrenome(),
                TipoUsuario.PROFESSOR,
                null,
                professor.getAtivo(),
                paraDataUri(professor.getFoto()));
    }

    private String paraDataUri(byte[] foto) {
        if (foto == null || foto.length == 0) {
            return null;
        }
        String tipo = tipoImagem(foto);
        if (tipo == null) {
            return null;
        }
        return "data:" + tipo + ";base64," + Base64.getEncoder().encodeToString(foto);
    }

    private String tipoImagem(byte[] bytes) {
        if (comecaCom(bytes, ASSINATURA_JPEG)) {
            return "image/jpeg";
        }
        if (comecaCom(bytes, ASSINATURA_PNG)) {
            return "image/png";
        }
        return null;
    }

    private boolean comecaCom(byte[] bytes, byte[] assinatura) {
        if (bytes == null || bytes.length < assinatura.length) {
            return false;
        }
        for (int indice = 0; indice < assinatura.length; indice++) {
            if (bytes[indice] != assinatura[indice]) {
                return false;
            }
        }
        return true;
    }

    private void validarSenhaAtual(String senhaAtual, String hashAtual) {
        if (hashAtual == null || !passwordEncoder.matches(senhaAtual, hashAtual)) {
            throw new DadosInvalidosException(
                    "SENHA_ATUAL_INCORRETA",
                    "A senha atual esta incorreta.");
        }
    }

    private RecursoNaoEncontradoException perfilNaoEncontrado() {
        return new RecursoNaoEncontradoException(
                "PERFIL_NAO_ENCONTRADO",
                "O perfil autenticado nao foi encontrado.");
    }

    private DadosInvalidosException tipoNaoPermitido() {
        return new DadosInvalidosException(
                "TIPO_USUARIO_INVALIDO",
                "O perfil esta disponivel apenas para aluno ou professor.");
    }
}
