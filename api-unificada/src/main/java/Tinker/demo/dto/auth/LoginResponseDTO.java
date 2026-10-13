package Tinker.demo.dto.auth;

import Tinker.demo.security.TipoUsuario;

public record LoginResponseDTO(
        String token,
        String tipo,
        String email,
        String nome,
        String sobrenome,
        TipoUsuario tipoUsuario) {
}
