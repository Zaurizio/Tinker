package Tinker.demo.repository;

import Tinker.demo.model.ConteudoQuest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ConteudoQuestRepository extends JpaRepository<ConteudoQuest, Integer> {
    // Métodos CRUD padrão já estão prontos!
}