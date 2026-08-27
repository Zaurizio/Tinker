package Tinker.demo.repository;

import Tinker.demo.model.RelatorioSimulado;
import Tinker.demo.model.RelatorioSimuladoid;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RelatorioSimuladoRepository
        extends JpaRepository<RelatorioSimulado, RelatorioSimuladoid> {
}
