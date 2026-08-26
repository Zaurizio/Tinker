package Tinker.demo.repository;

import Tinker.demo.model.Simulado;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SimuladoRepository extends JpaRepository<Simulado, Integer> {
    // ID é Integer (codSimulado)
}
