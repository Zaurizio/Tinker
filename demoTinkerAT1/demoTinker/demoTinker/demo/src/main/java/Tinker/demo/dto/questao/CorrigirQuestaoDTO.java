package Tinker.demo.dto.questao;

import jakarta.validation.constraints.NotBlank;

public record CorrigirQuestaoDTO(
        @NotBlank(message = "A alternativa é obrigatória.") String alternativa) {
}
