package Tinker.demo.dto.turma;

public record ResultadoIndividualSimuladoDTO(
        Integer simuladoId,
        int quantidadeQuestoes,
        boolean completo,
        Integer acertos,
        Integer erros) {
}
