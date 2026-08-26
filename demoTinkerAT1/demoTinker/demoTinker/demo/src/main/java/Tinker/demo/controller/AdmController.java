package Tinker.demo.controller;

import Tinker.demo.model.Adm;
import Tinker.demo.repository.AdmRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/adm")
public class AdmController {

    @Autowired
    private AdmRepository admRepository;

    // 1. GET - Listar todos
    @GetMapping
    public List<Adm> listarTodos() {
        return admRepository.findAll();
    }

    // 2. GET - Buscar por ID (Login)
    @GetMapping("/{login}")
    public ResponseEntity<Adm> buscarPorId(@PathVariable String login) {
        Optional<Adm> adm = admRepository.findById(login);
        return adm.map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // 3. POST - Criar novo
    @PostMapping
    public ResponseEntity<Adm> criar(@RequestBody Adm adm) {
        if (admRepository.existsById(adm.getLogin())) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build();
        }
        Adm savedAdm = admRepository.save(adm);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedAdm);
    }

    // 4. PUT - Atualizar (exemplo: senha)
    @PutMapping("/{login}")
    public ResponseEntity<Adm> atualizar(@PathVariable String login, @RequestBody Adm admAtualizado) {
        return admRepository.findById(login)
                .map(admExistente -> {
                    admExistente.setSenha(admAtualizado.getSenha());
                    Adm saved = admRepository.save(admExistente);
                    return ResponseEntity.ok(saved);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    // 5. DELETE - Deletar por ID (Login)
    @DeleteMapping("/{login}")
    public ResponseEntity<Void> deletar(@PathVariable String login) {
        if (admRepository.existsById(login)) {
            admRepository.deleteById(login);
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}