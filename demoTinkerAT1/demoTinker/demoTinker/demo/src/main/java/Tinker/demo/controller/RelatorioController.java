package Tinker.demo.controller;

import Tinker.demo.model.Relatorio;
import Tinker.demo.model.Relatorioid;
import Tinker.demo.repository.RelatorioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/relatorio")
public class RelatorioController {

    @Autowired
    private RelatorioRepository relatorioRepository;

    // 1. GET - Listar todos os relatórios
    @GetMapping
    public List<Relatorio> listarTodos() {
        return relatorioRepository.findAll();
    }

    // 2. GET - Buscar um relatório específico (por código da questão e email)
    // Formato da URL: /api/relatorio/10/aluno@email.com
    @GetMapping("/{codQuest}/{email}")
    public ResponseEntity<Relatorio> buscarPorId(@PathVariable Integer codQuest, @PathVariable String email) {
        Relatorioid id = new Relatorioid(codQuest, email);
        return relatorioRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // 3. POST - Criar um novo registro de relatório
    @PostMapping
    public ResponseEntity<Relatorio> criar(@RequestBody Relatorio relatorio) {
        Relatorioid id = new Relatorioid(relatorio.getCodQuest(), relatorio.getEmail());

        if (relatorioRepository.existsById(id)) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build(); // 409 - Já existe
        }

        Relatorio saved = relatorioRepository.save(relatorio);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    // 4. PUT - Atualizar o resultado (acertou/errou) de um relatório
    @PutMapping("/{codQuest}/{email}")
    public ResponseEntity<Relatorio> atualizar(@PathVariable Integer codQuest, @PathVariable String email, @RequestBody Relatorio atualizado) {
        Relatorioid id = new Relatorioid(codQuest, email);

        return relatorioRepository.findById(id)
                .map(registroExistente -> {
                    // Só o campo "acertouErrou" pode ser alterado
                    registroExistente.setAcertouErrou(atualizado.getAcertouErrou());

                    Relatorio saved = relatorioRepository.save(registroExistente);
                    return ResponseEntity.ok(saved);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    // 5. DELETE - Remover um relatório
    @DeleteMapping("/{codQuest}/{email}")
    public ResponseEntity<Void> deletar(@PathVariable Integer codQuest, @PathVariable String email) {
        Relatorioid id = new Relatorioid(codQuest, email);

        if (relatorioRepository.existsById(id)) {
            relatorioRepository.deleteById(id);
            return ResponseEntity.noContent().build(); // 204 - Deletado com sucesso
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}
