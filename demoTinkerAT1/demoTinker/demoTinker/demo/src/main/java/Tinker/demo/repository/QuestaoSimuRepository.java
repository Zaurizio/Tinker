package Tinker.demo.repository;

import Tinker.demo.model.QuestaoSimu;
import Tinker.demo.model.QuestaoSimuid;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuestaoSimuRepository extends JpaRepository<QuestaoSimu, QuestaoSimuid> {
    List<QuestaoSimu> findByCodSimulado(Integer codSimulado);
}