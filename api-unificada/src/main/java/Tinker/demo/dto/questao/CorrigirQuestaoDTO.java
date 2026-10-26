package Tinker.demo.dto.questao;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.validation.constraints.NotBlank;

public record CorrigirQuestaoDTO(
        // web envia "alternativa"; mobile envia "alternativaSelecionadaId"
        @JsonAlias("alternativaSelecionadaId")
        @NotBlank(message = "A alternativa é obrigatória.") String alternativa) {
}
