package Tinker.demo.controller;

import Tinker.demo.model.Professor;
import Tinker.demo.repository.ProfessorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/professor")
public class ProfessorController {

    @Autowired
    private ProfessorRepository professorRepository;

    // 1. GET - Listar todos os professores
    @GetMapping
    public List<Professor> listarTodos() {
        return professorRepository.findAll();
    }

    // 2. GET - Buscar um professor pelo e-mail
    @GetMapping("/{email}")
    public ResponseEntity<Professor> buscarPorId(@PathVariable String email) {
        Optional<Professor> professor = professorRepository.findById(email);
        return professor.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    // 3. POST - Criar um novo professor
    @PostMapping
    public ResponseEntity<Professor> criar(@RequestBody Professor professor) {
        if (professorRepository.existsById(professor.getEmail())) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build(); // 409 - E-mail já cadastrado
        }
        Professor saved = professorRepository.save(professor);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    // 4. PUT - Atualizar dados de um professor
    @PutMapping("/{email}")
    public ResponseEntity<Professor> atualizar(@PathVariable String email, @RequestBody Professor professorAtualizado) {
        return professorRepository.findById(email)
                .map(professorExistente -> {
                    professorExistente.setSenha(professorAtualizado.getSenha());
                    professorExistente.setNome(professorAtualizado.getNome());
                    professorExistente.setSobrenome(professorAtualizado.getSobrenome());
                    professorExistente.setAtivo(professorAtualizado.getAtivo());
                    professorExistente.setFoto(professorAtualizado.getFoto());

                    Professor saved = professorRepository.save(professorExistente);
                    return ResponseEntity.ok(saved);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    // 5. DELETE - Remover um professor pelo e-mail
    @DeleteMapping("/{email}")
    public ResponseEntity<Void> deletar(@PathVariable String email) {
        if (professorRepository.existsById(email)) {
            professorRepository.deleteById(email);
            return ResponseEntity.noContent().build(); // 204 - Deletado com sucesso
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}