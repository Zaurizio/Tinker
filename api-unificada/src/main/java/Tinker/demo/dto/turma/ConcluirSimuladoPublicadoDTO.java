package Tinker.demo.dto.turma;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;

import java.util.List;

public class ConcluirSimuladoPublicadoDTO {

    @NotEmpty(message = "Informe todas as respostas do simulado.")
    private List<@Valid RespostaConclusaoSimuladoDTO> respostas;

    public List<RespostaConclusaoSimuladoDTO> getRespostas() {
        return respostas;
    }

    public void setRespostas(List<RespostaConclusaoSimuladoDTO> respostas) {
        this.respostas = respostas;
    }
}
