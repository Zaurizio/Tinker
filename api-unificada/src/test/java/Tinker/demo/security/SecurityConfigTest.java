package Tinker.demo.security;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(SecurityTestController.class)
@Import({SecurityConfig.class, JwtService.class})
@TestPropertySource(properties = {
        "app.jwt.secret=segredo-ficticio-apenas-para-testes-123456789",
        "app.jwt.expiration-ms=60000",
        "app.cors.frontend-url=http://localhost:5173"
})
class SecurityConfigTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JwtService jwtService;

    @Test
    void rotaPublicaAceitaAcessoSemToken() throws Exception {
        mockMvc.perform(post("/api/auth/login").contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk());
    }

    @Test
    void cadastroTipadoTambemEhPublico() throws Exception {
        mockMvc.perform(post("/api/auth/cadastros").contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk());
    }

    @Test
    void rotaProtegidaRejeitaAcessoSemToken() throws Exception {
        mockMvc.perform(get("/teste/protegido"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.codigo").value("NAO_AUTENTICADO"))
                .andExpect(jsonPath("$.mensagem").exists());
    }

    @Test
    void rotaProtegidaAceitaTokenValido() throws Exception {
        String token = jwtService.gerarToken("professor@tinker.com", TipoUsuario.PROFESSOR);

        mockMvc.perform(get("/teste/protegido")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value("professor@tinker.com"))
                .andExpect(jsonPath("$.tipoUsuario").value("PROFESSOR"));
    }
}
