package Tinker.demo.dto.simulado;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.util.List;

public class GerarSimuladoDTO {

    @NotBlank(message = "O titulo e obrigatorio.")
    @Size(max = 20, message = "O titulo deve ter no maximo 20 caracteres.")
    private String titulo;

    @Size(max = 300, message = "A descricao deve ter no maximo 300 caracteres.")
    private String descricao;

    @Positive(message = "O tempo deve ser positivo.")
    private Float tempo;

    @NotNull(message = "A quantidade de questoes e obrigatoria.")
    @Min(value = 1, message = "A quantidade deve ser no minimo 1.")
    @Max(value = 50, message = "A quantidade deve ser no maximo 50.")
    private Integer quantidadeQuestoes;

    private List<String> disciplinas;
    private List<String> conteudos;
    private List<String> vestibulares;
    private List<Integer> anos;

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }
    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }
    public Float getTempo() { return tempo; }
    public void setTempo(Float tempo) { this.tempo = tempo; }
    public Integer getQuantidadeQuestoes() { return quantidadeQuestoes; }
    public void setQuantidadeQuestoes(Integer quantidadeQuestoes) { this.quantidadeQuestoes = quantidadeQuestoes; }
    public List<String> getDisciplinas() { return disciplinas; }
    public void setDisciplinas(List<String> disciplinas) { this.disciplinas = disciplinas; }
    public List<String> getConteudos() { return conteudos; }
    public void setConteudos(List<String> conteudos) { this.conteudos = conteudos; }
    public List<String> getVestibulares() { return vestibulares; }
    public void setVestibulares(List<String> vestibulares) { this.vestibulares = vestibulares; }
    public List<Integer> getAnos() { return anos; }
    public void setAnos(List<Integer> anos) { this.anos = anos; }
}
