package Tinker.demo.dto.simulado;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public class CriarSimuladoDTO {

    @NotBlank(message = "O titulo e obrigatorio.")
    @Size(max = 20, message = "O titulo deve ter no maximo 20 caracteres.")
    private String titulo;

    @Size(max = 300, message = "A descricao deve ter no maximo 300 caracteres.")
    private String descricao;

    @Positive(message = "O tempo deve ser positivo.")
    private Float tempo;

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }
    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }
    public Float getTempo() { return tempo; }
    public void setTempo(Float tempo) { this.tempo = tempo; }
}
