package Tinker.demo.controller;

import Tinker.demo.dto.calendario.CriarEventoDTO;
import Tinker.demo.dto.calendario.EventoCalendarioDTO;
import Tinker.demo.security.UsuarioAutenticado;
import Tinker.demo.service.CalendarioService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/calendario/eventos")
public class CalendarioController {

    private final CalendarioService service;

    public CalendarioController(CalendarioService service) {
        this.service = service;
    }

    @GetMapping
    public List<EventoCalendarioDTO> listar(
            @AuthenticationPrincipal UsuarioAutenticado usuario) {
        return service.listar(usuario);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public List<EventoCalendarioDTO> criar(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @Valid @RequestBody CriarEventoDTO entrada) {
        return service.criar(usuario, entrada);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void excluir(
            @AuthenticationPrincipal UsuarioAutenticado usuario,
            @PathVariable String id) {
        service.excluir(usuario, id);
    }
}
