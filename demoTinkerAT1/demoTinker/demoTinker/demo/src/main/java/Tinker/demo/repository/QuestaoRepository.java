package Tinker.demo.repository;

import Tinker.demo.model.Questao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;

@Repository
public interface QuestaoRepository extends JpaRepository<Questao, Integer>, JpaSpecificationExecutor<Questao> {
    List<Questao> findByCodQuestaoInAndAtivoOrderByCodQuestaoAsc(
            Collection<Integer> codQuestoes,
            Integer ativo);
}
