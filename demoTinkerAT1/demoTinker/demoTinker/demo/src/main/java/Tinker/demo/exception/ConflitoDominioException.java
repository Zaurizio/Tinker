package Tinker.demo.exception;

import org.springframework.http.HttpStatus;

public class ConflitoDominioException extends DominioException {

    public ConflitoDominioException(String codigo, String mensagem) {
        super(codigo, mensagem, HttpStatus.CONFLICT);
    }
}
