package Tinker.demo.dto.desempenho;

import java.util.List;

public record DesempenhoDTO(
        int questoesRespondidas,
        int totalAcertos,
        int percentualGeral,
        DesempenhoDisciplinaDTO maiorDesempenho,
        DesempenhoDisciplinaDTO menorDesempenho,
        List<DesempenhoDisciplinaDTO> disciplinas) {
}
