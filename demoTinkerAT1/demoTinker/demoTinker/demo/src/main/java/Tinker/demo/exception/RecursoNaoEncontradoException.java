package Tinker.demo.exception;

import org.springframework.http.HttpStatus;

public class RecursoNaoEncontradoException extends DominioException {

    public RecursoNaoEncontradoException(String codigo, String mensagem) {
        super(codigo, mensagem, HttpStatus.NOT_FOUND);
    }
}
