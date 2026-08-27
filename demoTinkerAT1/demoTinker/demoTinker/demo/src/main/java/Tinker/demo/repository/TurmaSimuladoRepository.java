package Tinker.demo.repository;

import Tinker.demo.model.TurmaSimulado;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TurmaSimuladoRepository extends JpaRepository<TurmaSimulado, String> {
    long deleteByCodSimulado(Integer codSimulado);
}
