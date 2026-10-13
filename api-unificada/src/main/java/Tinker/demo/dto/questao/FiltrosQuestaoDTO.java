package Tinker.demo.dto.questao;

import java.util.List;

public record FiltrosQuestaoDTO(
        List<ConteudosPorDisciplinaDTO> disciplinas,
        List<String> vestibulares,
        List<String> conteudos,
        List<Integer> anos) {
}
