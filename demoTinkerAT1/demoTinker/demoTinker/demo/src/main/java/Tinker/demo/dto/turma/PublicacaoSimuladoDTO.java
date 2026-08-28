package Tinker.demo.dto.turma;

public record PublicacaoSimuladoDTO(
        String idPublicacao,
        Integer simuladoId,
        String titulo,
        String descricao,
        long quantidadeQuestoes,
        String dataPublicacao) {
}
