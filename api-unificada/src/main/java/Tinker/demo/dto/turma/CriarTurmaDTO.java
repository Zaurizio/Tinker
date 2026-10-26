package Tinker.demo.dto.turma;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class CriarTurmaDTO {

    @NotBlank(message = "O nome da turma e obrigatorio.")
    @Size(max = 45, message = "O nome da turma deve ter no maximo 45 caracteres.")
    private String nome;

    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
}
