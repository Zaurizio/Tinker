package Tinker.demo.dto.simulado;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;

import java.util.List;

public class ConcluirSimuladoDTO {

    @NotEmpty(message = "Informe todas as respostas do simulado.")
    private List<@Valid RespostaConclusaoDTO> respostas;

    public List<RespostaConclusaoDTO> getRespostas() {
        return respostas;
    }

    public void setRespostas(List<RespostaConclusaoDTO> respostas) {
        this.respostas = respostas;
    }
}
