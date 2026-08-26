package Tinker.demo.exception;

import Tinker.demo.dto.error.ErroDTO;
import jakarta.validation.ConstraintViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.LinkedHashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(DominioException.class)
    public ResponseEntity<ErroDTO> tratarDominio(DominioException exception) {
        return ResponseEntity.status(exception.getStatus())
                .body(new ErroDTO(exception.getCodigo(), exception.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErroDTO> tratarValidacao(MethodArgumentNotValidException exception) {
        Map<String, String> campos = new LinkedHashMap<>();
        exception.getBindingResult().getFieldErrors().forEach(erro ->
                campos.putIfAbsent(erro.getField(), erro.getDefaultMessage()));

        return ResponseEntity.badRequest()
                .body(new ErroDTO("DADOS_INVALIDOS", "Verifique os campos informados.", campos));
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ErroDTO> tratarRestricao(ConstraintViolationException exception) {
        Map<String, String> campos = new LinkedHashMap<>();
        exception.getConstraintViolations().forEach(violacao ->
                campos.putIfAbsent(violacao.getPropertyPath().toString(), violacao.getMessage()));

        return ResponseEntity.badRequest()
                .body(new ErroDTO("DADOS_INVALIDOS", "Verifique os campos informados.", campos));
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ErroDTO> tratarJsonInvalido() {
        return ResponseEntity.badRequest()
                .body(new ErroDTO("JSON_INVALIDO", "O corpo da requisição é inválido."));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErroDTO> tratarErroInesperado() {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ErroDTO("ERRO_INTERNO", "Ocorreu um erro interno inesperado."));
    }
}
