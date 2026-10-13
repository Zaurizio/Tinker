package Tinker.demo.exception;

import org.springframework.http.HttpStatus;

public abstract class DominioException extends RuntimeException {

    private final String codigo;
    private final HttpStatus status;

    protected DominioException(String codigo, String mensagem, HttpStatus status) {
        super(mensagem);
        this.codigo = codigo;
        this.status = status;
    }

    public String getCodigo() {
        return codigo;
    }

    public HttpStatus getStatus() {
        return status;
    }
}
