package Tinker.demo.controller;

import Tinker.demo.model.ConteudoQuest;
import Tinker.demo.repository.ConteudoQuestRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/conteudo-quest")
public class ConteudoQuestController {

    @Autowired
    private ConteudoQuestRepository conteudoQuestRepository;

    // 1. GET - Listar todos
    @GetMapping
    public List<ConteudoQuest> listarTodos() {
        return conteudoQuestRepository.findAll();
    }

    // 2. GET - Buscar por ID
    @GetMapping("/{id}")
    public ResponseEntity<ConteudoQuest> buscarPorId(@PathVariable Integer id) {
        Optional<ConteudoQuest> conteudoQuest = conteudoQuestRepository.findById(id);
        return conteudoQuest.map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // 3. POST - Criar novo
    @PostMapping
    public ResponseEntity<ConteudoQuest> criar(@RequestBody ConteudoQuest conteudoQuest) {
        if (conteudoQuestRepository.existsById(conteudoQuest.getIdConteudoQuest())) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build(); // 409 - Conflito (ID já existe)
        }
        ConteudoQuest saved = conteudoQuestRepository.save(conteudoQuest);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    // 4. PUT - Atualizar
    @PutMapping("/{id}")
    public ResponseEntity<ConteudoQuest> atualizar(@PathVariable Integer id, @RequestBody ConteudoQuest conteudoQuestAtualizado) {
        return conteudoQuestRepository.findById(id)
                .map(conteudoExistente -> {
                    // Atualiza os campos permitidos
                    conteudoExistente.setCodQuest(conteudoQuestAtualizado.getCodQuest());
                    conteudoExistente.setConteudo(conteudoQuestAtualizado.getConteudo());

                    ConteudoQuest saved = conteudoQuestRepository.save(conteudoExistente);
                    return ResponseEntity.ok(saved);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    // 5. DELETE - Deletar por ID
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletar(@PathVariable Integer id) {
        if (conteudoQuestRepository.existsById(id)) {
            conteudoQuestRepository.deleteById(id);
            return ResponseEntity.noContent().build(); // 204 - Deletado com sucesso
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}
