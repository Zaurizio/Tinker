package Tinker.demo.repository;

import Tinker.demo.model.Turma;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TurmaRepository extends JpaRepository<Turma, String> {
    // O dump atual usa cod_turma varchar(8), sem geração automática.
}
