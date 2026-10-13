package Tinker.demo.dto.auth;

import Tinker.demo.security.TipoUsuario;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;
import java.util.Locale;

public class CadastroRequestDTO {

    @NotBlank(message = "O nome e obrigatorio.")
    private String nome;

    @NotBlank(message = "O sobrenome e obrigatorio.")
    private String sobrenome;

    @NotBlank(message = "O e-mail e obrigatorio.")
    @Email(message = "Informe um e-mail valido.")
    @Size(max = 50, message = "O e-mail deve ter no maximo 50 caracteres.")
    private String email;

    @NotBlank(message = "A senha e obrigatoria.")
    private String senha;

    private LocalDate nascimento;
    private TipoUsuario tipoUsuario;

    @AssertTrue(message = "O tipo de usuario deve ser ALUNO ou PROFESSOR.")
    public boolean isTipoUsuarioPermitido() {
        return tipoUsuario == TipoUsuario.ALUNO || tipoUsuario == TipoUsuario.PROFESSOR;
    }

    @AssertTrue(message = "A data de nascimento e obrigatoria para aluno.")
    public boolean isNascimentoValido() {
        return tipoUsuario != TipoUsuario.ALUNO || nascimento != null;
    }

    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    public String getSobrenome() { return sobrenome; }
    public void setSobrenome(String sobrenome) { this.sobrenome = sobrenome; }
    public String getEmail() { return email; }
    public void setEmail(String email) {
        this.email = email == null ? null : email.trim().toLowerCase(Locale.ROOT);
    }
    public String getSenha() { return senha; }
    public void setSenha(String senha) { this.senha = senha; }
    public LocalDate getNascimento() { return nascimento; }
    public void setNascimento(LocalDate nascimento) { this.nascimento = nascimento; }
    public TipoUsuario getTipoUsuario() { return tipoUsuario; }
    public void setTipoUsuario(TipoUsuario tipoUsuario) { this.tipoUsuario = tipoUsuario; }
}
