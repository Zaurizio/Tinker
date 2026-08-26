package Tinker.demo.controller;

import Tinker.demo.model.Cronograma;
import Tinker.demo.model.Cronogramaid;
import Tinker.demo.repository.CronogramaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/cronograma")
public class CronogramaController {

    @Autowired
    private CronogramaRepository cronogramaRepository;

    // 1. GET - Listar todos os cronogramas
    @GetMapping
    public List<Cronograma> listarTodos() {
        return cronogramaRepository.findAll();
    }

    // 2. GET - Buscar um cronograma específico pela Data e Email
    // Formato da URL: /api/cronograma/2026-08-12/aluno@email.com
    @GetMapping("/{data}/{email}")
    public ResponseEntity<Cronograma> buscarPorId(@PathVariable LocalDate data, @PathVariable String email) {
        Cronogramaid id = new Cronogramaid(data, email);
        return cronogramaRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // 3. POST - Criar um novo agendamento
    @PostMapping
    public ResponseEntity<Cronograma> criar(@RequestBody Cronograma cronograma) {
        Cronogramaid id = new Cronogramaid(cronograma.getData(), cronograma.getEmail());

        if (cronogramaRepository.existsById(id)) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build(); // 409 - Já existe este agendamento
        }

        Cronograma saved = cronogramaRepository.save(cronograma);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    // 4. PUT - Atualizar um agendamento (exemplo: mudar o simulado)
    @PutMapping("/{data}/{email}")
    public ResponseEntity<Cronograma> atualizar(@PathVariable LocalDate data, @PathVariable String email, @RequestBody Cronograma atualizado) {
        Cronogramaid id = new Cronogramaid(data, email);

        return cronogramaRepository.findById(id)
                .map(registroExistente -> {
                    // Atualiza o campo que pode mudar
                    registroExistente.setCodSimulado(atualizado.getCodSimulado());

                    Cronograma saved = cronogramaRepository.save(registroExistente);
                    return ResponseEntity.ok(saved);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    // 5. DELETE - Remover um agendamento
    @DeleteMapping("/{data}/{email}")
    public ResponseEntity<Void> deletar(@PathVariable LocalDate data, @PathVariable String email) {
        Cronogramaid id = new Cronogramaid(data, email);

        if (cronogramaRepository.existsById(id)) {
            cronogramaRepository.deleteById(id);
            return ResponseEntity.noContent().build(); // 204 - Deletado com sucesso
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}
