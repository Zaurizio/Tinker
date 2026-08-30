package Tinker.demo.service;

import Tinker.demo.dto.perfil.AlterarSenhaDTO;
import Tinker.demo.dto.perfil.AtualizarPerfilDTO;
import Tinker.demo.dto.perfil.PerfilDTO;
import Tinker.demo.exception.DadosInvalidosException;
import Tinker.demo.model.Aluno;
import Tinker.demo.model.Professor;
import Tinker.demo.repository.AlunoRepository;
import Tinker.demo.repository.ProfessorRepository;
import Tinker.demo.security.TipoUsuario;
import Tinker.demo.security.UsuarioAutenticado;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.sql.Date;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class PerfilServiceTest {

    private static final String EMAIL_ALUNO = "aluno@tinker.com";
    private static final String EMAIL_PROFESSOR = "professor@tinker.com";
    private static final byte[] BYTES_JPEG =
            { (byte) 0xFF, (byte) 0xD8, (byte) 0xFF, 0x00, 0x01, 0x02 };
    private static final byte[] BYTES_PNG =
            { (byte) 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00 };

    private AlunoRepository alunoRepository;
    private ProfessorRepository professorRepository;
    private PasswordEncoder passwordEncoder;
    private PerfilService perfilService;

    @BeforeEach
    void configurar() {
        alunoRepository = mock(AlunoRepository.class);
        professorRepository = mock(ProfessorRepository.class);
        passwordEncoder = new BCryptPasswordEncoder();
        perfilService = new PerfilService(alunoRepository, professorRepository, passwordEncoder);

        when(alunoRepository.save(any(Aluno.class))).thenAnswer(invocacao -> invocacao.getArgument(0));
        when(professorRepository.save(any(Professor.class))).thenAnswer(invocacao -> invocacao.getArgument(0));
    }

    @Test
    void consultaPerfilDeAluno() {
        when(alunoRepository.findById(EMAIL_ALUNO)).thenReturn(Optional.of(aluno()));

        PerfilDTO perfil = perfilService.consultar(usuarioAluno());

        assertEquals(EMAIL_ALUNO, perfil.email());
        assertEquals(TipoUsuario.ALUNO, perfil.tipoUsuario());
        assertEquals(LocalDate.of(2005, 5, 10), perfil.nascimento());
        assertEquals(1, perfil.ativo());
        verify(professorRepository, never()).findById(any());
    }

    @Test
    void consultaPerfilDeProfessorSemNascimento() {
        when(professorRepository.findById(EMAIL_PROFESSOR)).thenReturn(Optional.of(professor()));

        PerfilDTO perfil = perfilService.consultar(usuarioProfessor());

        assertEquals(EMAIL_PROFESSOR, perfil.email());
        assertEquals(TipoUsuario.PROFESSOR, perfil.tipoUsuario());
        assertNull(perfil.nascimento());
        verify(alunoRepository, never()).findById(any());
    }

    @Test
    void atualizaAluno() {
        Aluno aluno = aluno();
        when(alunoRepository.findById(EMAIL_ALUNO)).thenReturn(Optional.of(aluno));

        PerfilDTO perfil = perfilService.atualizar(
                usuarioAluno(), atualizar("Novo", "Aluno", LocalDate.of(2004, 4, 9)));

        assertEquals("Novo", aluno.getNome());
        assertEquals("Aluno", aluno.getSobrenome());
        assertEquals(Date.valueOf("2004-04-09"), aluno.getNascimento());
        assertEquals(LocalDate.of(2004, 4, 9), perfil.nascimento());
        verify(alunoRepository).save(aluno);
    }

    @Test
    void atualizaProfessorSemNascimento() {
        Professor professor = professor();
        when(professorRepository.findById(EMAIL_PROFESSOR)).thenReturn(Optional.of(professor));

        PerfilDTO perfil = perfilService.atualizar(
                usuarioProfessor(), atualizar("Novo", "Professor", null));

        assertEquals("Novo", professor.getNome());
        assertEquals("Professor", professor.getSobrenome());
        assertNull(perfil.nascimento());
        verify(professorRepository).save(professor);
    }

    @Test
    void impedeProfessorDeEnviarNascimento() {
        DadosInvalidosException erro = assertThrows(DadosInvalidosException.class, () ->
                perfilService.atualizar(
                        usuarioProfessor(), atualizar("Nome", "Professor", LocalDate.of(1990, 1, 1))));

        assertEquals("NASCIMENTO_NAO_PERMITIDO", erro.getCodigo());
        verify(professorRepository, never()).findById(any());
        verify(professorRepository, never()).save(any());
    }

    @Test
    void alteraSenhaQuandoSenhaAtualEstaCorreta() {
        Aluno aluno = aluno();
        aluno.setSenha(passwordEncoder.encode("senha-atual"));
        when(alunoRepository.findById(EMAIL_ALUNO)).thenReturn(Optional.of(aluno));

        perfilService.alterarSenha(usuarioAluno(), senhas("senha-atual", "senha-nova"));

        assertTrue(passwordEncoder.matches("senha-nova", aluno.getSenha()));
        assertFalse(passwordEncoder.matches("senha-atual", aluno.getSenha()));
        verify(alunoRepository).save(aluno);
    }

    @Test
    void rejeitaSenhaAtualIncorreta() {
        Aluno aluno = aluno();
        aluno.setSenha(passwordEncoder.encode("senha-atual"));
        when(alunoRepository.findById(EMAIL_ALUNO)).thenReturn(Optional.of(aluno));

        DadosInvalidosException erro = assertThrows(DadosInvalidosException.class, () ->
                perfilService.alterarSenha(usuarioAluno(), senhas("incorreta", "senha-nova")));

        assertEquals("SENHA_ATUAL_INCORRETA", erro.getCodigo());
        verify(alunoRepository, never()).save(any());
    }

    @Test
    void inativaContaSemExcluir() {
        Professor professor = professor();
        when(professorRepository.findById(EMAIL_PROFESSOR)).thenReturn(Optional.of(professor));

        perfilService.inativar(usuarioProfessor());

        assertEquals(0, professor.getAtivo());
        verify(professorRepository).save(professor);
        verify(professorRepository, never()).delete(any());
        verify(professorRepository, never()).deleteById(any());
    }

    @Test
    void identidadeVemDoUsuarioAutenticadoENaoPodeSerEscolhidaNoDto() {
        when(alunoRepository.findById(EMAIL_ALUNO)).thenReturn(Optional.of(aluno()));

        perfilService.atualizar(usuarioAluno(), atualizar("Nome", "Atualizado", LocalDate.of(2005, 5, 10)));

        verify(alunoRepository).findById(EMAIL_ALUNO);
        assertFalse(possuiCampo(AtualizarPerfilDTO.class, "email"));
        assertFalse(possuiCampo(AtualizarPerfilDTO.class, "tipoUsuario"));
        assertFalse(possuiCampo(AlterarSenhaDTO.class, "email"));
    }

    @Test
    void respostaDePerfilNaoContemSenhaOuHash() {
        assertFalse(possuiCampo(PerfilDTO.class, "senha"));
        assertFalse(possuiCampo(PerfilDTO.class, "hash"));
        assertEquals(
                Arrays.asList(
                        "email", "nome", "sobrenome", "tipoUsuario", "nascimento", "ativo", "foto"),
                Arrays.stream(PerfilDTO.class.getRecordComponents()).map(c -> c.getName()).toList());
    }

    @Test
    void alunoSemFotoTemFotoNulaNoPerfil() {
        when(alunoRepository.findById(EMAIL_ALUNO)).thenReturn(Optional.of(aluno()));

        PerfilDTO perfil = perfilService.consultar(usuarioAluno());

        assertNull(perfil.foto());
    }

    @Test
    void alunoEnviaFotoJpegEPassaAExpoLaComoDataUri() {
        Aluno aluno = aluno();
        when(alunoRepository.findById(EMAIL_ALUNO)).thenReturn(Optional.of(aluno));

        PerfilDTO perfil = perfilService.enviarFoto(usuarioAluno(), fotoJpeg());

        assertTrue(perfil.foto().startsWith("data:image/jpeg;base64,"));
        assertTrue(Arrays.equals(BYTES_JPEG, aluno.getFoto()));
        verify(alunoRepository).save(aluno);
    }

    @Test
    void professorEnviaFotoPngEPassaAExpoLaComoDataUri() {
        Professor professor = professor();
        when(professorRepository.findById(EMAIL_PROFESSOR)).thenReturn(Optional.of(professor));

        PerfilDTO perfil = perfilService.enviarFoto(usuarioProfessor(), fotoPng());

        assertTrue(perfil.foto().startsWith("data:image/png;base64,"));
        assertTrue(Arrays.equals(BYTES_PNG, professor.getFoto()));
        verify(professorRepository).save(professor);
    }

    @Test
    void rejeitaFotoVazia() {
        DadosInvalidosException erro = assertThrows(DadosInvalidosException.class, () ->
                perfilService.enviarFoto(
                        usuarioAluno(),
                        new MockMultipartFile("foto", "vazia.jpg", "image/jpeg", new byte[0])));

        assertEquals("FOTO_OBRIGATORIA", erro.getCodigo());
        verify(alunoRepository, never()).save(any());
    }

    @Test
    void rejeitaFormatoQueNaoEhJpgOuPng() {
        MockMultipartFile arquivo = new MockMultipartFile(
                "foto", "arquivo.gif", "image/gif", "GIF89a".getBytes());

        DadosInvalidosException erro = assertThrows(DadosInvalidosException.class, () ->
                perfilService.enviarFoto(usuarioAluno(), arquivo));

        assertEquals("FOTO_FORMATO_INVALIDO", erro.getCodigo());
        verify(alunoRepository, never()).save(any());
    }

    @Test
    void naoConfiaNoContentTypeInformadoPeloCliente() {
        MockMultipartFile arquivo = new MockMultipartFile(
                "foto", "falsa.jpg", "image/jpeg", "GIF89a".getBytes());

        DadosInvalidosException erro = assertThrows(DadosInvalidosException.class, () ->
                perfilService.enviarFoto(usuarioAluno(), arquivo));

        assertEquals("FOTO_FORMATO_INVALIDO", erro.getCodigo());
    }

    private UsuarioAutenticado usuarioAluno() {
        return new UsuarioAutenticado(EMAIL_ALUNO, TipoUsuario.ALUNO);
    }

    private UsuarioAutenticado usuarioProfessor() {
        return new UsuarioAutenticado(EMAIL_PROFESSOR, TipoUsuario.PROFESSOR);
    }

    private AtualizarPerfilDTO atualizar(String nome, String sobrenome, LocalDate nascimento) {
        AtualizarPerfilDTO dto = new AtualizarPerfilDTO();
        dto.setNome(nome);
        dto.setSobrenome(sobrenome);
        dto.setNascimento(nascimento);
        return dto;
    }

    private AlterarSenhaDTO senhas(String atual, String nova) {
        AlterarSenhaDTO dto = new AlterarSenhaDTO();
        dto.setSenhaAtual(atual);
        dto.setNovaSenha(nova);
        return dto;
    }

    private Aluno aluno() {
        Aluno aluno = new Aluno();
        aluno.setEmail(EMAIL_ALUNO);
        aluno.setNome("Nome");
        aluno.setSobrenome("Aluno");
        aluno.setNascimento(Date.valueOf("2005-05-10"));
        aluno.setAtivo(1);
        return aluno;
    }

    private Professor professor() {
        Professor professor = new Professor();
        professor.setEmail(EMAIL_PROFESSOR);
        professor.setNome("Nome");
        professor.setSobrenome("Professor");
        professor.setAtivo(1);
        return professor;
    }

    private MockMultipartFile fotoJpeg() {
        return new MockMultipartFile("foto", "foto.jpg", "image/jpeg", BYTES_JPEG);
    }

    private MockMultipartFile fotoPng() {
        return new MockMultipartFile("foto", "foto.png", "image/png", BYTES_PNG);
    }

    private boolean possuiCampo(Class<?> tipo, String nome) {
        return Arrays.stream(tipo.getDeclaredFields()).anyMatch(campo -> campo.getName().equals(nome));
    }
}
