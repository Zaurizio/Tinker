package Tinker.demo.dto.questao;

import java.util.List;

public record FiltrosQuestaoDTO(
        List<ConteudosPorDisciplinaDTO> disciplinas,
        List<String> vestibulares,
        List<Integer> anos) {
}
