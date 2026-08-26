package Tinker.demo.repository;

import Tinker.demo.model.AlunoTurma;
import Tinker.demo.model.AlunoTurmaid; // Importe a classe da chave
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AlunoTurmaRepository extends JpaRepository<AlunoTurma, AlunoTurmaid> {
}