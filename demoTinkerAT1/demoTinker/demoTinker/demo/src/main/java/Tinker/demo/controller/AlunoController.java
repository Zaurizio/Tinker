package Tinker.demo.controller;

import Tinker.demo.model.Aluno;
import Tinker.demo.repository.AlunoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/aluno")
public class AlunoController {

    @Autowired
    private AlunoRepository AlunoRepository;

    // 1. GET - Listar todos os alunos
    @GetMapping
    public List<Aluno> listarTodos() {
        return AlunoRepository.findAll();
    }

    // 2. GET - Buscar um aluno pelo e-mail
    @GetMapping("/{email}")
    public ResponseEntity<Aluno> buscarPorId(@PathVariable String email) {
        Optional<Aluno> aluno = AlunoRepository.findById(email);
        return aluno.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    // 3. POST - Criar um novo aluno
    @PostMapping
    public ResponseEntity<Aluno> criar(@RequestBody Aluno aluno) {
        // Verifica se o e-mail (ID) já existe para não duplicar
        if (AlunoRepository.existsById(aluno.getEmail())) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build();
        }
        Aluno savedAluno = AlunoRepository.save(aluno);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedAluno);
    }

    // 4. PUT - Atualizar dados de um aluno
    @PutMapping("/{email}")
    public ResponseEntity<Aluno> atualizar(@PathVariable String email, @RequestBody Aluno alunoAtualizado) {
        return AlunoRepository.findById(email)
                .map(alunoExistente -> {
                    // Atualize aqui os campos que podem ser alterados
                    alunoExistente.setNome(alunoAtualizado.getNome());
                    alunoExistente.setSobrenome(alunoAtualizado.getSobrenome());
                    alunoExistente.setSenha(alunoAtualizado.getSenha()); // Cuidado: futuramente use hash de senha
                    alunoExistente.setNascimento(alunoAtualizado.getNascimento());
                    alunoExistente.setAtivo(alunoAtualizado.getAtivo());
                    // alunoExistente.setFoto(alunoAtualizado.getFoto()); // Se for permitido alterar a foto

                    Aluno saved = AlunoRepository.save(alunoExistente);
                    return ResponseEntity.ok(saved);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    // 5. DELETE - Remover um aluno pelo e-mail
    @DeleteMapping("/{email}")
    public ResponseEntity<Void> deletar(@PathVariable String email) {
        if (AlunoRepository.existsById(email)) {
            AlunoRepository.deleteById(email);
            return ResponseEntity.noContent().build(); // 204 No Content
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}