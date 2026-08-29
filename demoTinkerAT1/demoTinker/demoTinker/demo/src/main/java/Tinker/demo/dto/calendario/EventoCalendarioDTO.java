package Tinker.demo.dto.calendario;

import java.time.LocalDate;
import java.time.LocalTime;

public record EventoCalendarioDTO(
        String id,
        String titulo,
        LocalDate data,
        LocalTime horarioInicio,
        LocalTime horarioFim,
        boolean diaInteiro,
        String cor) {
}
