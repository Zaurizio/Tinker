package Tinker.demo.repository;

import org.junit.jupiter.api.Test;
import org.springframework.data.jpa.repository.Query;

import java.lang.reflect.Method;

import static org.junit.jupiter.api.Assertions.assertTrue;

class QuestaoRepositoryTest {

    @Test
    void consultaDeDisciplinasEConteudosFiltraSomenteAtivasESemDuplicatas() throws Exception {
        String jpql = queryDe("findDisciplinasEConteudosAtivos");

        assertTrue(jpql.contains("distinct"), "a consulta deve usar DISTINCT");
        assertTrue(jpql.contains("q.ativo = 1"), "a consulta deve filtrar somente questoes ativas");
        assertTrue(jpql.contains("q.disciplina"), "a consulta deve trazer a disciplina");
        assertTrue(jpql.contains("q.conteudo"), "a consulta deve trazer o conteudo");
    }

    @Test
    void consultaDeVestibularesFiltraSomenteAtivasEUsaDistinct() throws Exception {
        String jpql = queryDe("findVestibularesAtivos");

        assertTrue(jpql.contains("distinct"), "a consulta deve usar DISTINCT");
        assertTrue(jpql.contains("q.ativo = 1"), "a consulta deve filtrar somente questoes ativas");
        assertTrue(jpql.contains("q.vestibular"), "a consulta deve trazer o vestibular");
    }

    @Test
    void consultaDeAnosFiltraSomenteAtivasEUsaDistinct() throws Exception {
        String jpql = queryDe("findAnosAtivos");

        assertTrue(jpql.contains("distinct"), "a consulta deve usar DISTINCT");
        assertTrue(jpql.contains("q.ativo = 1"), "a consulta deve filtrar somente questoes ativas");
        assertTrue(jpql.contains("q.ano"), "a consulta deve trazer o ano");
    }

    private String queryDe(String nomeDoMetodo) throws Exception {
        Method metodo = QuestaoRepository.class.getDeclaredMethod(nomeDoMetodo);
        Query anotacao = metodo.getAnnotation(Query.class);
        assertTrue(anotacao != null, "o metodo deve ser anotado com @Query");
        return anotacao.value();
    }
}
