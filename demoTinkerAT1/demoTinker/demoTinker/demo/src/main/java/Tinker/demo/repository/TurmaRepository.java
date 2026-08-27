package Tinker.demo.repository;

import Tinker.demo.model.Turma;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;

@Repository
public interface TurmaRepository extends JpaRepository<Turma, String> {
    List<Turma> findByEmailProfAndAtivoOrderByCodTurmaAsc(String emailProf, Integer ativo);

    List<Turma> findByCodTurmaInAndAtivoOrderByCodTurmaAsc(
            Collection<String> codigos,
            Integer ativo);
    // O dump atual usa cod_turma varchar(8), sem geração automática.
}
