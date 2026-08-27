package Tinker.demo.dto.perfil;

import jakarta.validation.constraints.NotBlank;

public class AlterarSenhaDTO {

    @NotBlank(message = "A senha atual e obrigatoria.")
    private String senhaAtual;

    @NotBlank(message = "A nova senha e obrigatoria.")
    private String novaSenha;

    public String getSenhaAtual() { return senhaAtual; }
    public void setSenhaAtual(String senhaAtual) { this.senhaAtual = senhaAtual; }
    public String getNovaSenha() { return novaSenha; }
    public void setNovaSenha(String novaSenha) { this.novaSenha = novaSenha; }
}
