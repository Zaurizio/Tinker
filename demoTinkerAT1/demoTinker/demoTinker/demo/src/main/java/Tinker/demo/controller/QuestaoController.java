package Tinker.demo.controller;

import Tinker.demo.model.Questao;
import Tinker.demo.repository.QuestaoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/questao")
public class QuestaoController {

    @Autowired
    private QuestaoRepository questaoRepository;

    // 1. GET - Listar todas as questões
    @GetMapping
    public List<Questao> listarTodos() {
        return questaoRepository.findAll();
    }

    // 2. GET - Buscar uma questão pelo ID
    @GetMapping("/{id}")
    public ResponseEntity<Questao> buscarPorId(@PathVariable Integer id) {
        Optional<Questao> questao = questaoRepository.findById(id);
        return questao.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    // 3. POST - Criar uma nova questão
    @PostMapping
    public ResponseEntity<Questao> criar(@RequestBody Questao questao) {
        if (questaoRepository.existsById(questao.getCodQuestao())) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build(); // 409 - ID já existe
        }
        Questao saved = questaoRepository.save(questao);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    // 4. PUT - Atualizar uma questão existente
    @PutMapping("/{id}")
    public ResponseEntity<Questao> atualizar(@PathVariable Integer id, @RequestBody Questao questaoAtualizada) {
        return questaoRepository.findById(id)
                .map(questaoExistente -> {
                    questaoExistente.setVestibular(questaoAtualizada.getVestibular());
                    questaoExistente.setAno(questaoAtualizada.getAno());
                    questaoExistente.setFase(questaoAtualizada.getFase());
                    questaoExistente.setDisciplina(questaoAtualizada.getDisciplina());
                    questaoExistente.setConteudo(questaoAtualizada.getConteudo());
                    questaoExistente.setEnunciado(questaoAtualizada.getEnunciado());
                    questaoExistente.setImagem(questaoAtualizada.getImagem());
                    questaoExistente.setAlternativaA(questaoAtualizada.getAlternativaA());
                    questaoExistente.setAlternativaB(questaoAtualizada.getAlternativaB());
                    questaoExistente.setAlternativaC(questaoAtualizada.getAlternativaC());
                    questaoExistente.setAlternativaD(questaoAtualizada.getAlternativaD());
                    questaoExistente.setAlternativaE(questaoAtualizada.getAlternativaE());
                    questaoExistente.setResposta(questaoAtualizada.getResposta());
                    questaoExistente.setAtivo(questaoAtualizada.getAtivo());

                    Questao saved = questaoRepository.save(questaoExistente);
                    return ResponseEntity.ok(saved);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    // 5. DELETE - Remover uma questão pelo ID
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletar(@PathVariable Integer id) {
        if (questaoRepository.existsById(id)) {
            questaoRepository.deleteById(id);
            return ResponseEntity.noContent().build(); // 204 - Deletado com sucesso
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}
