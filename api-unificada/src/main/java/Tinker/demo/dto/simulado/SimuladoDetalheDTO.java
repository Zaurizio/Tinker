package Tinker.demo.dto.simulado;

import java.util.List;

public record SimuladoDetalheDTO(
        Integer id,
        String titulo,
        String descricao,
        Float tempo,
        long quantidadeQuestoes,
        List<Integer> questoesIds) {
}
