package Tinker.demo.controller;

import Tinker.demo.model.HorarioMult;
import Tinker.demo.model.HorarioMultid;
import Tinker.demo.repository.HorarioMultRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/horario-mult")
public class HorarioMultController {

    @Autowired
    private HorarioMultRepository horarioMultRepository;

    // 1. GET - Listar todos os horários
    @GetMapping
    public List<HorarioMult> listarTodos() {
        return horarioMultRepository.findAll();
    }

    // 2. GET - Buscar um horário específico (Email + Data + HorarioInicio)
    @GetMapping("/{email}/{data}/{horarioInicio}")
    public ResponseEntity<HorarioMult> buscarPorId(
            @PathVariable String email,
            @PathVariable LocalDate data,
            @PathVariable Float horarioInicio) {

        HorarioMultid id = new HorarioMultid(email, data, horarioInicio);
        return horarioMultRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // 3. POST - Criar um novo horário
    @PostMapping
    public ResponseEntity<HorarioMult> criar(@RequestBody HorarioMult horarioMult) {
        HorarioMultid id = new HorarioMultid(
                horarioMult.getEmail(),
                horarioMult.getData(),
                horarioMult.getHorarioInicio());

        if (horarioMultRepository.existsById(id)) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build(); // 409 - Já existe
        }

        HorarioMult saved = horarioMultRepository.save(horarioMult);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    // 4. PUT - Atualizar um horário
    @PutMapping("/{email}/{data}/{horarioInicio}")
    public ResponseEntity<HorarioMult> atualizar(
            @PathVariable String email,
            @PathVariable LocalDate data,
            @PathVariable Float horarioInicio,
            @RequestBody HorarioMult atualizado) {

        HorarioMultid id = new HorarioMultid(email, data, horarioInicio);

        return horarioMultRepository.findById(id)
                .map(registroExistente -> {
                    // Atualiza os campos que podem mudar
                    registroExistente.setHorarioFim(atualizado.getHorarioFim());
                    registroExistente.setDisciplina(atualizado.getDisciplina());
                    registroExistente.setConteudo(atualizado.getConteudo());
                    registroExistente.setDescricao(atualizado.getDescricao());
                    registroExistente.setTitulo(atualizado.getTitulo());
                    registroExistente.setDiaInteiro(atualizado.getDiaInteiro());
                    registroExistente.setCor(atualizado.getCor());

                    HorarioMult saved = horarioMultRepository.save(registroExistente);
                    return ResponseEntity.ok(saved);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    // 5. DELETE - Remover um horário
    @DeleteMapping("/{email}/{data}/{horarioInicio}")
    public ResponseEntity<Void> deletar(
            @PathVariable String email,
            @PathVariable LocalDate data,
            @PathVariable Float horarioInicio) {

        HorarioMultid id = new HorarioMultid(email, data, horarioInicio);

        if (horarioMultRepository.existsById(id)) {
            horarioMultRepository.deleteById(id);
            return ResponseEntity.noContent().build(); // 204
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}
