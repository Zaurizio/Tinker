package Tinker.demo.controller;

import Tinker.demo.model.QuestaoSimu;
import Tinker.demo.model.QuestaoSimuid;
import Tinker.demo.repository.QuestaoSimuRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/questao-simu")
public class QuestaoSimuController {

    @Autowired
    private QuestaoSimuRepository questaoSimuRepository;

    @GetMapping
    public List<QuestaoSimu> listarTodos() {
        return questaoSimuRepository.findAll();
    }

    @GetMapping("/simulado/{codSimulado}")
    public List<QuestaoSimu> listarPorSimulado(@PathVariable Integer codSimulado) {
        return questaoSimuRepository.findByCodSimulado(codSimulado);
    }

    @PostMapping
    public ResponseEntity<QuestaoSimu> criar(@RequestBody QuestaoSimu questaoSimu) {
        QuestaoSimuid id = new QuestaoSimuid(questaoSimu.getCodSimulado(), questaoSimu.getCodQuestao());

        if (questaoSimuRepository.existsById(id)) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build();
        }

        QuestaoSimu saved = questaoSimuRepository.save(questaoSimu);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @DeleteMapping("/{codSimulado}/{codQuestao}")
    public ResponseEntity<Void> deletar(@PathVariable Integer codSimulado, @PathVariable Integer codQuestao) {
        QuestaoSimuid id = new QuestaoSimuid(codSimulado, codQuestao);

        if (questaoSimuRepository.existsById(id)) {
            questaoSimuRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}