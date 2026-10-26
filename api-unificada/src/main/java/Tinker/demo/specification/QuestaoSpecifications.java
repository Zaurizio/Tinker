package Tinker.demo.specification;

import Tinker.demo.model.Questao;
import org.springframework.data.jpa.domain.Specification;

import java.util.List;
import java.util.Locale;

public final class QuestaoSpecifications {

    private QuestaoSpecifications() {
    }

    public static Specification<Questao> comFiltros(
            List<String> disciplinas,
            List<String> conteudos,
            List<String> vestibulares,
            List<Integer> anos,
            String trecho) {
        Specification<Questao> especificacao = (root, query, builder) ->
                builder.equal(root.get("ativo"), 1);

        List<String> disciplinasValidas = normalizar(disciplinas);
        List<String> conteudosValidos = normalizar(conteudos);
        List<String> vestibularesValidos = normalizar(vestibulares);

        if (!disciplinasValidas.isEmpty()) {
            especificacao = especificacao.and((root, query, builder) ->
                    root.get("disciplina").in(disciplinasValidas));
        }
        if (!conteudosValidos.isEmpty()) {
            especificacao = especificacao.and((root, query, builder) ->
                    root.get("conteudo").in(conteudosValidos));
        }
        if (!vestibularesValidos.isEmpty()) {
            especificacao = especificacao.and((root, query, builder) ->
                    root.get("vestibular").in(vestibularesValidos));
        }
        if (anos != null && !anos.isEmpty()) {
            especificacao = especificacao.and((root, query, builder) ->
                    root.get("ano").in(anos));
        }
        if (trecho != null && !trecho.isBlank()
                && !trecho.trim().equalsIgnoreCase("todas")) {
            String pesquisa = "%" + trecho.trim().toLowerCase(Locale.ROOT) + "%";
            especificacao = especificacao.and((root, query, builder) ->
                    builder.like(builder.lower(root.get("enunciado")), pesquisa));
        }

        return especificacao;
    }

    private static List<String> normalizar(List<String> valores) {
        if (valores == null || valores.isEmpty()) {
            return List.of();
        }
        if (valores.stream()
                .filter(java.util.Objects::nonNull)
                .map(String::trim)
                .anyMatch(valor -> valor.equalsIgnoreCase("todas"))) {
            return List.of();
        }
        return valores.stream()
                .filter(java.util.Objects::nonNull)
                .map(String::trim)
                .filter(valor -> !valor.isEmpty())
                .toList();
    }
}
