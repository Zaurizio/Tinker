package Tinker.demo.dto.auth;

import Tinker.demo.security.TipoUsuario;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.Locale;

public class LoginRequestDTO {

    @NotBlank(message = "O e-mail é obrigatório.")
    @Email(message = "Informe um e-mail válido.")
    @Size(max = 50, message = "O e-mail deve ter no máximo 50 caracteres.")
    private String email;

    @NotBlank(message = "A senha é obrigatória.")
    private String senha;
    private TipoUsuario tipoUsuario;

    public LoginRequestDTO() {
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email == null ? null : email.trim().toLowerCase(Locale.ROOT);
    }

    public String getSenha() {
        return senha;
    }

    public void setSenha(String senha) {
        this.senha = senha;
    }

    public TipoUsuario getTipoUsuario() {
        return tipoUsuario;
    }

    public void setTipoUsuario(TipoUsuario tipoUsuario) {
        this.tipoUsuario = tipoUsuario;
    }

    @AssertTrue(message = "O tipo de usuario deve ser ALUNO ou PROFESSOR.")
    public boolean isTipoUsuarioPermitido() {
        return tipoUsuario == TipoUsuario.ALUNO || tipoUsuario == TipoUsuario.PROFESSOR;
    }
}
