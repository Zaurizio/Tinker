package Tinker.demo.controller;

import Tinker.demo.dto.turma.CriarTurmaDTO;
import Tinker.demo.dto.turma.EntrarTurmaDTO;
import Tinker.demo.dto.turma.MembroTurmaDTO;
import Tinker.demo.dto.turma.TurmaDTO;
import Tinker.demo.dto.turma.PublicacaoSimuladoDTO;
import Tinker.demo.dto.turma.PublicarSimuladoDTO;
import Tinker.demo.security.UsuarioAutenticado;
import Tinker.demo.service.TurmaService;
import Tinker.demo.service.TurmaSimuladoService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Pattern;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Validated
@RestController
@RequestMapping("/api/turmas")
public class TurmaController {

    private static final String CODIGO_VALIDO = "^[0-9]{8}$";
    private final TurmaService turmaService;
    private final TurmaSimuladoService turmaSimuladoService;

    public TurmaController(TurmaService turmaService, TurmaSimuladoService turmaSimuladoService) {
        this.turmaService = turmaService;
        this.turmaSimuladoService = turmaSimuladoService;
    }

    @GetMapping
    public List<TurmaDTO> listar(@AuthenticationPrincipal UsuarioAutenticado usuario) {
        return turmaService.listar(usuario);
    }

    @PostMapping
    public ResponseEntity<TurmaDTO> criar(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @Valid @RequestBody CriarTurmaDTO dados) {
        return ResponseEntity.status(201).body(turmaService.criar(usuario, dados));
    }

    @PostMapping("/entradas")
    public TurmaDTO entrar(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @Valid @RequestBody EntrarTurmaDTO dados) {
        return turmaService.entrar(usuario, dados);
    }

    @GetMapping("/{codigo}")
    public TurmaDTO detalhar(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @PathVariable @Pattern(regexp = CODIGO_VALIDO) String codigo) {
        return turmaService.detalhar(usuario, codigo);
    }

    @GetMapping("/{codigo}/membros")
    public List<MembroTurmaDTO> listarMembros(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @PathVariable @Pattern(regexp = CODIGO_VALIDO) String codigo) {
        return turmaService.listarMembros(usuario, codigo);
    }

    @GetMapping("/{codigo}/simulados")
    public List<PublicacaoSimuladoDTO> listarSimulados(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @PathVariable @Pattern(regexp = CODIGO_VALIDO) String codigo) {
        return turmaSimuladoService.listar(usuario, codigo);
    }

    @PostMapping("/{codigo}/simulados")
    public ResponseEntity<PublicacaoSimuladoDTO> publicarSimulado(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @PathVariable @Pattern(regexp = CODIGO_VALIDO) String codigo,
            @Valid @RequestBody PublicarSimuladoDTO dados) {
        TurmaSimuladoService.ResultadoPublicacao resultado =
                turmaSimuladoService.publicar(usuario, codigo, dados);
        return ResponseEntity.status(resultado.nova() ? 201 : 200).body(resultado.publicacao());
    }

    @DeleteMapping("/{codigo}/simulados/{idPublicacao}")
    public ResponseEntity<Void> despublicarSimulado(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @PathVariable @Pattern(regexp = CODIGO_VALIDO) String codigo,
            @PathVariable String idPublicacao) {
        turmaSimuladoService.despublicar(usuario, codigo, idPublicacao);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{codigo}/membros/me")
    public ResponseEntity<Void> sair(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @PathVariable @Pattern(regexp = CODIGO_VALIDO) String codigo) {
        turmaService.sair(usuario, codigo);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{codigo}/membros/{emailAluno}")
    public ResponseEntity<Void> removerMembro(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @PathVariable @Pattern(regexp = CODIGO_VALIDO) String codigo,
            @PathVariable String emailAluno) {
        turmaService.removerMembro(usuario, codigo, emailAluno);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{codigo}")
    public ResponseEntity<Void> desativar(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @PathVariable @Pattern(regexp = CODIGO_VALIDO) String codigo) {
        turmaService.desativar(usuario, codigo);
        return ResponseEntity.noContent().build();
    }
}
