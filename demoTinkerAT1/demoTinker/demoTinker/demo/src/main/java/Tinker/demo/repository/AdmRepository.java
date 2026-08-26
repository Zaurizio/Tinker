package Tinker.demo.repository;

import Tinker.demo.model.Adm;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AdmRepository extends JpaRepository<Adm, String> {
    // O Spring Data JPA já fornece automaticamente os métodos:
    // save(), findAll(), findById(), deleteById(), existsById()...
}