package Tinker.demo.dto.questao;

public record CorrecaoQuestaoDTO(
        Integer questaoId,
        boolean acertou,
        String alternativaCorreta) {
}
