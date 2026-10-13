package Tinker.demo.exception;

import org.springframework.http.HttpStatus;

public class AcessoNegadoException extends DominioException {

    public AcessoNegadoException(String codigo, String mensagem) {
        super(codigo, mensagem, HttpStatus.FORBIDDEN);
    }
}
