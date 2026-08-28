package Tinker.demo.dto.turma;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class RespostaConclusaoSimuladoDTO {

    @NotNull(message = "Informe a questao.")
    private Integer questaoId;

    @NotBlank(message = "Informe a alternativa.")
    private String alternativa;

    public Integer getQuestaoId() {
        return questaoId;
    }

    public void setQuestaoId(Integer questaoId) {
        this.questaoId = questaoId;
    }

    public String getAlternativa() {
        return alternativa;
    }

    public void setAlternativa(String alternativa) {
        this.alternativa = alternativa;
    }
}
