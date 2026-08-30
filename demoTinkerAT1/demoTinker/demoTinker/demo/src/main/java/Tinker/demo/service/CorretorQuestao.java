package Tinker.demo.service;

import Tinker.demo.exception.DadosInvalidosException;
import Tinker.demo.model.Questao;

import java.util.Locale;
import java.util.Set;

final class CorretorQuestao {

    private CorretorQuestao() {
    }

    static boolean corrigir(Questao questao, String alternativa) {
        String alternativaId = normalizar(alternativa);
        String textoSelecionado = textoAlternativa(questao, alternativaId);
        if (textoSelecionado == null || textoSelecionado.isBlank()) {
            throw new DadosInvalidosException(
                    "ALTERNATIVA_INEXISTENTE",
                    "A alternativa selecionada nao existe nesta questao.");
        }

        String resposta = questao.getResposta();
        if (resposta == null) {
            return false;
        }
        String respostaNormalizada = resposta.trim();
        if (respostaNormalizada.matches("(?i)[A-E]")) {
            return alternativaId.equals(respostaNormalizada.toUpperCase(Locale.ROOT));
        }
        return textoSelecionado.trim().equals(respostaNormalizada);
    }

    static String alternativaCorreta(Questao questao) {
        String resposta = questao.getResposta();
        if (resposta == null) {
            return null;
        }

        String respostaNormalizada = resposta.trim();
        if (respostaNormalizada.matches("(?i)[A-E]")) {
            return respostaNormalizada.toUpperCase(Locale.ROOT);
        }

        for (String alternativa : Set.of("A", "B", "C", "D", "E")) {
            String texto = textoAlternativa(questao, alternativa);
            if (texto != null && texto.trim().equals(respostaNormalizada)) {
                return alternativa;
            }
        }
        return null;
    }

    private static String normalizar(String alternativa) {
        if (alternativa == null) {
            throw alternativaInvalida();
        }
        String normalizada = alternativa.trim().toUpperCase(Locale.ROOT);
        if (!Set.of("A", "B", "C", "D", "E").contains(normalizada)) {
            throw alternativaInvalida();
        }
        return normalizada;
    }

    private static String textoAlternativa(Questao questao, String alternativaId) {
        return switch (alternativaId) {
            case "A" -> questao.getAlternativaA();
            case "B" -> questao.getAlternativaB();
            case "C" -> questao.getAlternativaC();
            case "D" -> questao.getAlternativaD();
            case "E" -> questao.getAlternativaE();
            default -> null;
        };
    }

    private static DadosInvalidosException alternativaInvalida() {
        return new DadosInvalidosException(
                "ALTERNATIVA_INVALIDA",
                "A alternativa deve ser A, B, C, D ou E.");
    }
}
