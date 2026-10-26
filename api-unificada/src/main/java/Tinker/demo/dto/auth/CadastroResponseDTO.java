package Tinker.demo.dto.auth;

import Tinker.demo.security.TipoUsuario;

public record CadastroResponseDTO(
        String email,
        String nome,
        String sobrenome,
        TipoUsuario tipoUsuario) {
}
