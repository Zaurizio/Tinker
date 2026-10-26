package Tinker.demo.repository;

import Tinker.demo.model.QuestaoSimu;
import Tinker.demo.model.QuestaoSimuid;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuestaoSimuRepository extends JpaRepository<QuestaoSimu, QuestaoSimuid> {
    List<QuestaoSimu> findByCodSimulado(Integer codSimulado);

    long countByCodSimulado(Integer codSimulado);

    @Query("select qs.codQuestao from QuestaoSimu qs where qs.codSimulado = :codSimulado order by qs.codQuestao")
    List<Integer> findCodQuestoesByCodSimulado(@Param("codSimulado") Integer codSimulado);

    long deleteByCodSimulado(Integer codSimulado);
}
