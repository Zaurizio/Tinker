package Tinker.demo.dto.error;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.Map;

@JsonInclude(JsonInclude.Include.NON_EMPTY)
public record ErroDTO(String codigo, String mensagem, Map<String, String> campos) {

    public ErroDTO(String codigo, String mensagem) {
        this(codigo, mensagem, null);
    }

    public ErroDTO {
        campos = campos == null || campos.isEmpty() ? null : Map.copyOf(campos);
    }
}
