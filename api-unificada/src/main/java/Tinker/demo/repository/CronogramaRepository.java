package Tinker.demo.repository;

import Tinker.demo.model.Cronograma;
import Tinker.demo.model.Cronogramaid;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CronogramaRepository extends JpaRepository<Cronograma, Cronogramaid> {
}