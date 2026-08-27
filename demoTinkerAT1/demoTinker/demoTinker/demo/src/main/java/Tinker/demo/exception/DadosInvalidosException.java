package Tinker.demo.exception;

import org.springframework.http.HttpStatus;

public class DadosInvalidosException extends DominioException {

    public DadosInvalidosException(String codigo, String mensagem) {
        super(codigo, mensagem, HttpStatus.BAD_REQUEST);
    }
}
