package Tinker.demo.controller;

import Tinker.demo.dto.auth.CadastroRequestDTO;
import Tinker.demo.dto.auth.CadastroResponseDTO;
import Tinker.demo.dto.auth.LoginRequestDTO;
import Tinker.demo.dto.auth.LoginResponseDTO;
import Tinker.demo.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class LoginController {

    private final AuthService authService;

    public LoginController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponseDTO> login(@Valid @RequestBody LoginRequestDTO dados) {
        return ResponseEntity.ok(authService.login(dados));
    }

    @PostMapping("/cadastros")
    public ResponseEntity<CadastroResponseDTO> cadastrar(@Valid @RequestBody CadastroRequestDTO dados) {
        return ResponseEntity.status(201).body(authService.cadastrar(dados));
    }
}
