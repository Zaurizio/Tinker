package Tinker.demo.security;

import org.junit.jupiter.api.Test;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class JwtServiceTest {

    private static final String SEGREDO_TESTE = "segredo-ficticio-apenas-para-testes-123456789";
    private static final Instant AGORA = Instant.parse("2026-01-01T12:00:00Z");

    @Test
    void geraEValidaToken() {
        JwtService service = service(AGORA, 60_000);

        String token = service.gerarToken("aluno@tinker.com", TipoUsuario.ALUNO);
        UsuarioAutenticado usuario = service.validarToken(token).orElseThrow();

        assertEquals("aluno@tinker.com", usuario.email());
        assertEquals(TipoUsuario.ALUNO, usuario.tipoUsuario());
    }

    @Test
    void rejeitaTokenInvalidoOuExpirado() {
        JwtService emissor = service(AGORA, 1_000);
        String token = emissor.gerarToken("professor@tinker.com", TipoUsuario.PROFESSOR);

        assertTrue(emissor.validarToken(token + "alterado").isEmpty());
        assertTrue(service(AGORA.plusSeconds(2), 1_000).validarToken(token).isEmpty());
    }

    private JwtService service(Instant instante, long expiracaoMs) {
        return new JwtService(SEGREDO_TESTE, expiracaoMs, Clock.fixed(instante, ZoneOffset.UTC));
    }
}
