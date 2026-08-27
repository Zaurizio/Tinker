package Tinker.demo.dto.perfil;

import jakarta.validation.constraints.NotBlank;

import java.time.LocalDate;

public class AtualizarPerfilDTO {

    @NotBlank(message = "O nome e obrigatorio.")
    private String nome;

    @NotBlank(message = "O sobrenome e obrigatorio.")
    private String sobrenome;

    private LocalDate nascimento;

    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    public String getSobrenome() { return sobrenome; }
    public void setSobrenome(String sobrenome) { this.sobrenome = sobrenome; }
    public LocalDate getNascimento() { return nascimento; }
    public void setNascimento(LocalDate nascimento) { this.nascimento = nascimento; }
}
