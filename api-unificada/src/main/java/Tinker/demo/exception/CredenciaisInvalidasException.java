package Tinker.demo.exception;

import org.springframework.http.HttpStatus;

public class CredenciaisInvalidasException extends DominioException {

    public CredenciaisInvalidasException() {
        super("CREDENCIAIS_INVALIDAS", "E-mail ou senha incorretos.", HttpStatus.UNAUTHORIZED);
    }
}
