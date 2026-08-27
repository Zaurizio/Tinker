package Tinker.demo.controller;

import Tinker.demo.dto.perfil.AlterarSenhaDTO;
import Tinker.demo.dto.perfil.AtualizarPerfilDTO;
import Tinker.demo.dto.perfil.PerfilDTO;
import Tinker.demo.security.UsuarioAutenticado;
import Tinker.demo.service.PerfilService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/me")
public class PerfilController {

    private final PerfilService perfilService;

    public PerfilController(PerfilService perfilService) {
        this.perfilService = perfilService;
    }

    @GetMapping
    public PerfilDTO consultar(@AuthenticationPrincipal UsuarioAutenticado usuario) {
        return perfilService.consultar(usuario);
    }

    @PutMapping
    public PerfilDTO atualizar(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @Valid @RequestBody AtualizarPerfilDTO dados) {
        return perfilService.atualizar(usuario, dados);
    }

    @PutMapping("/senha")
    public ResponseEntity<Void> alterarSenha(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @Valid @RequestBody AlterarSenhaDTO dados) {
        perfilService.alterarSenha(usuario, dados);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping
    public ResponseEntity<Void> inativar(@AuthenticationPrincipal UsuarioAutenticado usuario) {
        perfilService.inativar(usuario);
        return ResponseEntity.noContent().build();
    }
}
