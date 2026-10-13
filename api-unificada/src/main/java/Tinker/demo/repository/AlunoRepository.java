package Tinker.demo.repository;

import Tinker.demo.model.Aluno;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AlunoRepository extends JpaRepository<Aluno, String> {
    // Agora o Spring sabe que o ID é uma String (email)
}