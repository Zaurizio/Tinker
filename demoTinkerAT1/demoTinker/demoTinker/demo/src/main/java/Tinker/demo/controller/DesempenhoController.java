package Tinker.demo.controller;

import Tinker.demo.dto.desempenho.DesempenhoDTO;
import Tinker.demo.security.UsuarioAutenticado;
import Tinker.demo.service.DesempenhoService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/desempenho")
public class DesempenhoController {

    private final DesempenhoService desempenhoService;

    public DesempenhoController(DesempenhoService desempenhoService) {
        this.desempenhoService = desempenhoService;
    }

    @GetMapping
    public DesempenhoDTO consultar(@AuthenticationPrincipal UsuarioAutenticado usuario) {
        return desempenhoService.consultar(usuario);
    }
}
