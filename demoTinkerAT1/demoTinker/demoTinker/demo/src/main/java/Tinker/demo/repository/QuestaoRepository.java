package Tinker.demo.repository;

import Tinker.demo.model.Questao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface QuestaoRepository extends JpaRepository<Questao, Integer> {
    // ID é Integer (codQuestao)
}