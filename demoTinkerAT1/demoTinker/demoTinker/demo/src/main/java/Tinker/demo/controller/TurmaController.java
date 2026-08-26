package Tinker.demo.controller;

import Tinker.demo.model.Turma;
import Tinker.demo.repository.TurmaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/turma")
public class TurmaController {

    @Autowired
    private TurmaRepository turmaRepository;

    // 1. GET - Listar todas as turmas
    @GetMapping
    public List<Turma> listarTodos() {
        return turmaRepository.findAll();
    }

    // 2. GET - Buscar uma turma pelo ID
    @GetMapping("/{id}")
    public ResponseEntity<Turma> buscarPorId(@PathVariable Integer id) {
        Optional<Turma> turma = turmaRepository.findById(id);
        return turma.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    // 3. POST - Criar uma nova turma
    @PostMapping
    public ResponseEntity<Turma> criar(@RequestBody Turma turma) {
        if (turma.getCodTurma() != null && turmaRepository.existsById(turma.getCodTurma())) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build(); // 409 - ID já existe
        }
        Turma saved = turmaRepository.save(turma);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    // 4. PUT - Atualizar uma turma
    @PutMapping("/{id}")
    public ResponseEntity<Turma> atualizar(@PathVariable Integer id, @RequestBody Turma turmaAtualizada) {
        return turmaRepository.findById(id)
                .map(turmaExistente -> {
                    turmaExistente.setNomeTurma(turmaAtualizada.getNomeTurma());
                    turmaExistente.setEmailProf(turmaAtualizada.getEmailProf());
                    turmaExistente.setAtivo(turmaAtualizada.getAtivo());

                    Turma saved = turmaRepository.save(turmaExistente);
                    return ResponseEntity.ok(saved);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    // 5. DELETE - Remover uma turma pelo ID
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletar(@PathVariable Integer id) {
        if (turmaRepository.existsById(id)) {
            turmaRepository.deleteById(id);
            return ResponseEntity.noContent().build(); // 204 - Deletado com sucesso
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}