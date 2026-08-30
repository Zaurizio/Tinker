package Tinker.demo.dto.simulado;

public record ConclusaoSimuladoDTO(
        Integer simuladoId,
        int quantidadeQuestoes,
        int acertos,
        int erros,
        boolean completo) {
}
