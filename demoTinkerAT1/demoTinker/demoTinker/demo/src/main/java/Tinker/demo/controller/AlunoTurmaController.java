package Tinker.demo.controller;

import Tinker.demo.model.AlunoTurma;
import Tinker.demo.model.AlunoTurmaid;
import Tinker.demo.repository.AlunoTurmaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/aluno-turma")
public class AlunoTurmaController {

    @Autowired
    private AlunoTurmaRepository alunoTurmaRepository;

    @GetMapping
    public List<AlunoTurma> listarTodos() {
        return alunoTurmaRepository.findAll();
    }

    @GetMapping("/{email}/{codTurma}")
    public ResponseEntity<AlunoTurma> buscarPorId(@PathVariable String email, @PathVariable Integer codTurma) {
        AlunoTurmaid id = new AlunoTurmaid(email, codTurma);
        return alunoTurmaRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<AlunoTurma> criar(@RequestBody AlunoTurma alunoTurma) {
        AlunoTurmaid id = new AlunoTurmaid(alunoTurma.getEmailAluno(), alunoTurma.getCodTurma());

        if (alunoTurmaRepository.existsById(id)) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build();
        }

        AlunoTurma saved = alunoTurmaRepository.save(alunoTurma);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @PutMapping("/{email}/{codTurma}")
    public ResponseEntity<AlunoTurma> atualizar(@PathVariable String email, @PathVariable Integer codTurma, @RequestBody AlunoTurma atualizado) {
        AlunoTurmaid id = new AlunoTurmaid(email, codTurma);

        return alunoTurmaRepository.findById(id)
                .map(registroExistente -> {
                    registroExistente.setAtivo(atualizado.getAtivo());
                    AlunoTurma saved = alunoTurmaRepository.save(registroExistente);
                    return ResponseEntity.ok(saved);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{email}/{codTurma}")
    public ResponseEntity<Void> deletar(@PathVariable String email, @PathVariable Integer codTurma) {
        AlunoTurmaid id = new AlunoTurmaid(email, codTurma);

        if (alunoTurmaRepository.existsById(id)) {
            alunoTurmaRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}