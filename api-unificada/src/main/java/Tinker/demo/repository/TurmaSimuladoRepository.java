package Tinker.demo.repository;

import Tinker.demo.model.TurmaSimulado;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TurmaSimuladoRepository extends JpaRepository<TurmaSimulado, String> {
    List<TurmaSimulado> findByCodTurmaAndAtivoOrderByDataPublicacaoDesc(
            String codTurma,
            Integer ativo);

    List<TurmaSimulado> findByCodTurmaAndCodSimuladoOrderByIdPublicacaoAsc(
            String codTurma,
            Integer codSimulado);

    Optional<TurmaSimulado> findByIdPublicacaoAndCodTurmaAndAtivo(
            String idPublicacao,
            String codTurma,
            Integer ativo);

    long deleteByCodSimulado(Integer codSimulado);
}
