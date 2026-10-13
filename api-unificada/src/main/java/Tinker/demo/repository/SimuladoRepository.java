package Tinker.demo.repository;

import Tinker.demo.model.Simulado;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SimuladoRepository extends JpaRepository<Simulado, Integer> {
    List<Simulado> findByEmailAlunoAndTipoUsuOrderByCodSimuladoAsc(
            String emailAluno, String tipoUsu);

    List<Simulado> findByEmailProfAndTipoUsuOrderByCodSimuladoAsc(
            String emailProf, String tipoUsu);
}
