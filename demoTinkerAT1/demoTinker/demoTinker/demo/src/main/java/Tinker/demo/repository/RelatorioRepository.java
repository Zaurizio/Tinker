package Tinker.demo.repository;

import Tinker.demo.model.Relatorio;
import Tinker.demo.model.Relatorioid;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RelatorioRepository extends JpaRepository<Relatorio, Relatorioid> {
    List<Relatorio> findByEmailAndTipoUsu(String email, String tipoUsu);
    Optional<Relatorio> findByCodQuestAndEmailAndTipoUsu(
            Integer codQuest, String email, String tipoUsu);
}
