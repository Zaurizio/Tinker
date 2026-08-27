package Tinker.demo.dto.turma;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public class EntrarTurmaDTO {

    @NotBlank(message = "O codigo da turma e obrigatorio.")
    @Pattern(regexp = "^[0-9]{8}$", message = "O codigo deve conter exatamente oito digitos.")
    private String codigo;

    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }
}
