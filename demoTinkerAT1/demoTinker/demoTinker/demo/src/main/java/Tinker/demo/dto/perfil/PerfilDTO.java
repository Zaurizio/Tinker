package Tinker.demo.dto.perfil;

import Tinker.demo.security.TipoUsuario;

import java.time.LocalDate;

public record PerfilDTO(
        String email,
        String nome,
        String sobrenome,
        TipoUsuario tipoUsuario,
        LocalDate nascimento,
        Integer ativo) {
}
