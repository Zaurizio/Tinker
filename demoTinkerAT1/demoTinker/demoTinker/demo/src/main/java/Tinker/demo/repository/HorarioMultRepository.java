package Tinker.demo.repository;

import Tinker.demo.model.HorarioMult;
import Tinker.demo.model.HorarioMultid;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HorarioMultRepository extends JpaRepository<HorarioMult, HorarioMultid> {
    List<HorarioMult> findByEmailOrderByDataAscHorarioInicioAsc(String email);
}
