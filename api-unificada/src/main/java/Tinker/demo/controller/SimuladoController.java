package Tinker.demo.controller;

import Tinker.demo.dto.simulado.AtualizarSimuladoDTO;
import Tinker.demo.dto.simulado.ConcluirSimuladoDTO;
import Tinker.demo.dto.simulado.ConclusaoSimuladoDTO;
import Tinker.demo.dto.simulado.CriarSimuladoDTO;
import Tinker.demo.dto.simulado.SimuladoDetalheDTO;
import Tinker.demo.dto.simulado.SimuladoResumoDTO;
import Tinker.demo.dto.simulado.QuantidadeQuestoesSimuladoDTO;
import Tinker.demo.dto.simulado.QuestoesIdsDTO;
import Tinker.demo.dto.questao.QuestaoDTO;
import Tinker.demo.dto.simulado.GerarSimuladoDTO;
import Tinker.demo.dto.simulado.SimuladoGeradoDTO;
import Tinker.demo.security.UsuarioAutenticado;
import Tinker.demo.service.SimuladoService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/simulados")
public class SimuladoController {

    private final SimuladoService simuladoService;

    public SimuladoController(SimuladoService simuladoService) {
        this.simuladoService = simuladoService;
    }

    @GetMapping
    public List<SimuladoResumoDTO> listar(@AuthenticationPrincipal UsuarioAutenticado usuario) {
        return simuladoService.listar(usuario);
    }

    @PostMapping
    public ResponseEntity<SimuladoDetalheDTO> criar(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @Valid @RequestBody CriarSimuladoDTO dados) {
        return ResponseEntity.status(201).body(simuladoService.criar(usuario, dados));
    }

    @PostMapping("/geracoes")
    public ResponseEntity<SimuladoGeradoDTO> gerar(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @Valid @RequestBody GerarSimuladoDTO dados) {
        return ResponseEntity.status(201).body(simuladoService.gerar(usuario, dados));
    }

    @GetMapping("/{id}")
    public SimuladoDetalheDTO detalhar(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @PathVariable Integer id) {
        return simuladoService.detalhar(usuario, id);
    }

    @GetMapping("/{id}/questoes")
    public List<QuestaoDTO> listarQuestoes(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @PathVariable Integer id) {
        return simuladoService.listarQuestoes(usuario, id);
    }

    @PostMapping("/{id}/questoes")
    public QuantidadeQuestoesSimuladoDTO adicionarQuestoes(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @PathVariable Integer id,
            @Valid @RequestBody QuestoesIdsDTO dados) {
        return simuladoService.adicionarQuestoes(usuario, id, dados);
    }

    @DeleteMapping("/{id}/questoes/{questaoId}")
    public ResponseEntity<Void> removerQuestao(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @PathVariable Integer id,
            @PathVariable Integer questaoId) {
        simuladoService.removerQuestao(usuario, id, questaoId);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}")
    public SimuladoDetalheDTO atualizar(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @PathVariable Integer id,
            @Valid @RequestBody AtualizarSimuladoDTO dados) {
        return simuladoService.atualizar(usuario, id, dados);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> excluir(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @PathVariable Integer id) {
        simuladoService.excluir(usuario, id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/conclusoes")
    public ConclusaoSimuladoDTO concluir(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @PathVariable Integer id,
            @Valid @RequestBody ConcluirSimuladoDTO dados) {
        return simuladoService.concluir(usuario, id, dados);
    }
}
