package Tinker.demo.repository;

import Tinker.demo.model.AlunoTurma;
import Tinker.demo.model.AlunoTurmaid; // Importe a classe da chave
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AlunoTurmaRepository extends JpaRepository<AlunoTurma, AlunoTurmaid> {
    List<AlunoTurma> findByEmailAlunoAndAtivoOrderByCodTurmaAsc(String emailAluno, Integer ativo);

    List<AlunoTurma> findByCodTurmaAndAtivoOrderByEmailAlunoAsc(String codTurma, Integer ativo);

    Optional<AlunoTurma> findByEmailAlunoAndCodTurmaAndAtivo(
            String emailAluno,
            String codTurma,
            Integer ativo);
}
