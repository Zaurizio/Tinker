package Tinker.demo.dto.turma;

import jakarta.validation.constraints.NotNull;

public class PublicarSimuladoDTO {

    @NotNull(message = "Informe o simulado.")
    private Integer simuladoId;

    public Integer getSimuladoId() {
        return simuladoId;
    }

    public void setSimuladoId(Integer simuladoId) {
        this.simuladoId = simuladoId;
    }
}
