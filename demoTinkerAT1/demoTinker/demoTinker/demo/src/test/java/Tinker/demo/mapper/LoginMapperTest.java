package Tinker.demo.mapper;

import Tinker.demo.dto.auth.LoginResponseDTO;
import Tinker.demo.model.Aluno;
import org.junit.jupiter.api.Test;
import tools.jackson.databind.ObjectMapper;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;

class LoginMapperTest {

    private final LoginMapper mapper = new LoginMapper();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Test
    void respostaNaoExpoeSenhaHashFotoOuEntidadeCompleta() throws Exception {
        Aluno aluno = new Aluno();
        aluno.setEmail("usuario@example.com");
        aluno.setNome("Nome");
        aluno.setSobrenome("Sobrenome");
        aluno.setSenha("segredo");
        aluno.setFoto(new byte[]{1, 2, 3});

        LoginResponseDTO resposta = mapper.paraResposta(aluno);
        String json = objectMapper.writeValueAsString(resposta);

        assertEquals("usuario@example.com", resposta.email());
        assertFalse(json.contains("senha"));
        assertFalse(json.contains("segredo"));
        assertFalse(json.contains("foto"));
        assertFalse(json.contains("ativo"));
    }
}
