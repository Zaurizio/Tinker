package Tinker.demo.dto.calendario;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;
import java.time.LocalTime;

public record CriarEventoDTO(
        @NotBlank @Size(max = 45) String titulo,
        @NotNull LocalDate data,
        LocalTime horarioInicio,
        LocalTime horarioFim,
        @NotNull Boolean diaInteiro,
        @Pattern(regexp = "^#[0-9A-Fa-f]{6}$", message = "deve usar o formato hexadecimal #RRGGBB") String cor,
        @NotNull RecorrenciaEvento recorrencia,
        Integer repeticoes) {
}
