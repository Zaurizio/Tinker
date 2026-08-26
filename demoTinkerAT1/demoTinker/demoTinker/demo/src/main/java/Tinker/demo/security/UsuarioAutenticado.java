package Tinker.demo.security;

import java.security.Principal;

public record UsuarioAutenticado(String email, TipoUsuario tipoUsuario) implements Principal {

    @Override
    public String getName() {
        return email;
    }
}
