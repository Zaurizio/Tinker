package Tinker.demo.exception;

import Tinker.demo.dto.auth.LoginRequestDTO;
import jakarta.validation.Valid;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class GlobalExceptionHandlerTest {

    private MockMvc mockMvc;

    @BeforeEach
    void configurar() {
        mockMvc = MockMvcBuilders.standaloneSetup(new ControllerDeTeste())
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();
    }

    @Test
    void retornaCamposParaErroDeValidacao() throws Exception {
        mockMvc.perform(post("/teste/validacao")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"invalido\",\"senha\":\"\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.codigo").value("DADOS_INVALIDOS"))
                .andExpect(jsonPath("$.campos.email").exists())
                .andExpect(jsonPath("$.campos.senha").exists());
    }

    @Test
    void retornaErroUniformeParaExcecaoDeDominio() throws Exception {
        mockMvc.perform(post("/teste/conflito"))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.codigo").value("RECURSO_DUPLICADO"))
                .andExpect(jsonPath("$.mensagem").value("O recurso já existe."))
                .andExpect(jsonPath("$.campos").doesNotExist());
    }

    @Test
    void naoExpoeDetalhesDoErroInesperado() throws Exception {
        mockMvc.perform(post("/teste/erro"))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.codigo").value("ERRO_INTERNO"))
                .andExpect(jsonPath("$.mensagem").value("Ocorreu um erro interno inesperado."));
    }

    @RestController
    static class ControllerDeTeste {

        @PostMapping("/teste/validacao")
        void validar(@Valid @RequestBody LoginRequestDTO dto) {
        }

        @PostMapping("/teste/conflito")
        void conflito() {
            throw new ConflitoDominioException("RECURSO_DUPLICADO", "O recurso já existe.");
        }

        @PostMapping("/teste/erro")
        void erro() {
            throw new IllegalStateException("detalhe interno sensível");
        }
    }
}
