package Tinker.demo.dto.simulado;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class CorrigirQuestaoSimuladoDTO {

    @NotNull
    private Integer questaoId;

    @NotBlank
    private String alternativaSelecionadaId;

    public Integer getQuestaoId() {
        return questaoId;
    }

    public void setQuestaoId(Integer questaoId) {
        this.questaoId = questaoId;
    }

    public String getAlternativaSelecionadaId() {
        return alternativaSelecionadaId;
    }

    public void setAlternativaSelecionadaId(String alternativaSelecionadaId) {
        this.alternativaSelecionadaId = alternativaSelecionadaId;
    }
}
