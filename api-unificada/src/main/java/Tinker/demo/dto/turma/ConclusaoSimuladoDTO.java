package Tinker.demo.dto.turma;

public record ConclusaoSimuladoDTO(
        Integer simuladoId,
        int quantidadeQuestoes,
        int acertos,
        int erros,
        boolean completo) {
}
