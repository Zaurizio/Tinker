package Tinker.demo.controller;

import Tinker.demo.dto.questao.PaginaQuestaoDTO;
import Tinker.demo.dto.questao.QuestaoDTO;
import Tinker.demo.service.QuestaoService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/questoes")
public class QuestaoController {

    private final QuestaoService questaoService;

    public QuestaoController(QuestaoService questaoService) {
        this.questaoService = questaoService;
    }

    @GetMapping
    public PaginaQuestaoDTO listar(
            @RequestParam(required = false) List<String> disciplinas,
            @RequestParam(required = false) List<String> conteudos,
            @RequestParam(required = false) List<String> vestibulares,
            @RequestParam(required = false) List<Integer> anos,
            @RequestParam(required = false) String trecho,
            @RequestParam(defaultValue = "0") int pagina,
            @RequestParam(defaultValue = "10") int tamanho) {
        return questaoService.listar(
                disciplinas, conteudos, vestibulares, anos, trecho, pagina, tamanho);
    }

    @GetMapping("/{id}")
    public QuestaoDTO detalhar(@PathVariable Integer id) {
        return questaoService.detalhar(id);
    }
}
