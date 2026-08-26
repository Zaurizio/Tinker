package Tinker.demo.repository;

import Tinker.demo.model.Relatorio;
import Tinker.demo.model.Relatorioid;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RelatorioRepository extends JpaRepository<Relatorio, Relatorioid> {
}
