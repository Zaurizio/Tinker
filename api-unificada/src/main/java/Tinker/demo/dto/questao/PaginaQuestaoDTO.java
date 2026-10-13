package Tinker.demo.dto.questao;

import java.util.List;

public record PaginaQuestaoDTO(
        List<QuestaoDTO> itens,
        boolean temMais,
        long total,
        int pagina,
        int tamanho) {
}
