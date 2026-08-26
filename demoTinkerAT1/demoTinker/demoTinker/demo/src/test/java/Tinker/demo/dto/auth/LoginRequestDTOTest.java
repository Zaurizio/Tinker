package Tinker.demo.dto.auth;

import jakarta.validation.Validation;
import jakarta.validation.Validator;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class LoginRequestDTOTest {

    private static Validator validator;

    @BeforeAll
    static void configurarValidator() {
        validator = Validation.buildDefaultValidatorFactory().getValidator();
    }

    @Test
    void aceitaCredenciaisSintaticamenteValidas() {
        LoginRequestDTO dto = criar("usuario@example.com", "senha");

        assertTrue(validator.validate(dto).isEmpty());
    }

    @Test
    void rejeitaEmailInvalidoESenhaVazia() {
        LoginRequestDTO dto = criar("email-invalido", " ");

        assertEquals(2, validator.validate(dto).size());
    }

    private LoginRequestDTO criar(String email, String senha) {
        LoginRequestDTO dto = new LoginRequestDTO();
        dto.setEmail(email);
        dto.setSenha(senha);
        return dto;
    }
}
