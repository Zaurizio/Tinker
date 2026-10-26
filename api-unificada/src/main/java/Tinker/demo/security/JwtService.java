package Tinker.demo.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.util.Date;
import java.util.Optional;

@Service
public class JwtService {

    private final SecretKey chave;
    private final long expiracaoMs;
    private final Clock clock;

    @Autowired
    public JwtService(
            @Value("${app.jwt.secret}") String segredo,
            @Value("${app.jwt.expiration-ms}") long expiracaoMs) {
        this(segredo, expiracaoMs, Clock.systemUTC());
    }

    JwtService(String segredo, long expiracaoMs, Clock clock) {
        if (segredo == null || segredo.length() < 32) {
            throw new IllegalArgumentException("O segredo JWT deve ter pelo menos 32 caracteres");
        }
        this.chave = Keys.hmacShaKeyFor(segredo.getBytes(StandardCharsets.UTF_8));
        this.expiracaoMs = expiracaoMs;
        this.clock = clock;
    }

    public String gerarToken(String email, TipoUsuario tipoUsuario) {
        Date emissao = Date.from(clock.instant());
        Date expiracao = new Date(emissao.getTime() + expiracaoMs);

        return Jwts.builder()
                .subject(email)
                .claim("tipoUsuario", tipoUsuario.name())
                .issuedAt(emissao)
                .expiration(expiracao)
                .signWith(chave)
                .compact();
    }

    public Optional<UsuarioAutenticado> validarToken(String token) {
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(chave)
                    .clock(() -> Date.from(clock.instant()))
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();

            String email = claims.getSubject();
            TipoUsuario tipo = TipoUsuario.valueOf(claims.get("tipoUsuario", String.class));
            if (email == null || email.isBlank()) {
                return Optional.empty();
            }
            return Optional.of(new UsuarioAutenticado(email, tipo));
        } catch (Exception exception) {
            return Optional.empty();
        }
    }
}
