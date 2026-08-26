package Tinker.demo.controller;

import Tinker.demo.model.Simulado;
import Tinker.demo.repository.SimuladoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/simulado")
public class SimuladoController {

    @Autowired
    private SimuladoRepository simuladoRepository;

    // 1. GET - Listar todos os simulados
    @GetMapping
    public List<Simulado> listarTodos() {
        return simuladoRepository.findAll();
    }

    // 2. GET - Buscar um simulado pelo ID
    @GetMapping("/{id}")
    public ResponseEntity<Simulado> buscarPorId(@PathVariable Integer id) {
        Optional<Simulado> simulado = simuladoRepository.findById(id);
        return simulado.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    // 3. POST - Criar um novo simulado
    @PostMapping
    public ResponseEntity<Simulado> criar(@RequestBody Simulado simulado) {
        // Como o ID é auto-incremento, normalmente não precisamos verificar existsById antes de salvar,
        // mas se você tiver uma regra de negócio que impeça duplicidade, mantenha.
        if (simulado.getCodSimulado() != null && simuladoRepository.existsById(simulado.getCodSimulado())) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build(); // 409
        }
        Simulado saved = simuladoRepository.save(simulado);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    // 4. PUT - Atualizar um simulado existente
    @PutMapping("/{id}")
    public ResponseEntity<Simulado> atualizar(@PathVariable Integer id, @RequestBody Simulado simuladoAtualizado) {
        return simuladoRepository.findById(id)
                .map(simuladoExistente -> {
                    simuladoExistente.setNome(simuladoAtualizado.getNome());
                    simuladoExistente.setDescricao(simuladoAtualizado.getDescricao());
                    simuladoExistente.setConclusao(simuladoAtualizado.getConclusao());
                    simuladoExistente.setTempo(simuladoAtualizado.getTempo());
                    simuladoExistente.setEmailAluno(simuladoAtualizado.getEmailAluno());
                    simuladoExistente.setEmailProf(simuladoAtualizado.getEmailProf());

                    Simulado saved = simuladoRepository.save(simuladoExistente);
                    return ResponseEntity.ok(saved);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    // 5. DELETE - Remover um simulado pelo ID
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletar(@PathVariable Integer id) {
        if (simuladoRepository.existsById(id)) {
            simuladoRepository.deleteById(id);
            return ResponseEntity.noContent().build(); // 204
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}