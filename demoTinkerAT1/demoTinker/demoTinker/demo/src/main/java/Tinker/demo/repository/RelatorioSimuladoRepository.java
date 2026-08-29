package Tinker.demo.repository;

import Tinker.demo.model.RelatorioSimulado;
import Tinker.demo.model.RelatorioSimuladoid;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RelatorioSimuladoRepository
        extends JpaRepository<RelatorioSimulado, RelatorioSimuladoid> {
    Optional<RelatorioSimulado> findByCodSimuladoAndEmailAluno(Integer codSimulado, String emailAluno);
    long deleteByCodSimuladoAndEmailAluno(Integer codSimulado, String emailAluno);
    long deleteByCodSimulado(Integer codSimulado);
}
