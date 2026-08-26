package Tinker.demo.security;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
class SecurityTestController {

    @PostMapping("/api/auth/login")
    Map<String, String> rotaPublica() {
        return Map.of("status", "publica");
    }

    @GetMapping("/teste/protegido")
    Map<String, String> rotaProtegida(@AuthenticationPrincipal UsuarioAutenticado usuario) {
        return Map.of("email", usuario.email(), "tipoUsuario", usuario.tipoUsuario().name());
    }
}
