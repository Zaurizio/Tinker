package Tinker.demo.dto.turma;

import jakarta.validation.constraints.NotBlank;

public class CorrigirQuestaoPublicadaDTO {

    @NotBlank(message = "Informe a alternativa.")
    private String alternativa;

    public String getAlternativa() {
        return alternativa;
    }

    public void setAlternativa(String alternativa) {
        this.alternativa = alternativa;
    }
}
