package Tinker.demo.repository;

import Tinker.demo.model.Questao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;

@Repository
public interface QuestaoRepository extends JpaRepository<Questao, Integer>, JpaSpecificationExecutor<Questao> {
    List<Questao> findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(
            Collection<Integer> codQuestoes,
            Integer ativo);

    @Query("select distinct q.disciplina as disciplina, q.conteudo as conteudo "
            + "from Questao q where q.ativo = 1")
    List<DisciplinaConteudoProjecao> findDisciplinasEConteudosAtivos();

    @Query("select distinct q.vestibular from Questao q where q.ativo = 1")
    List<String> findVestibularesAtivos();

    @Query("select distinct q.ano from Questao q where q.ativo = 1")
    List<Integer> findAnosAtivos();

    interface DisciplinaConteudoProjecao {
        String getDisciplina();

        String getConteudo();
    }
}
