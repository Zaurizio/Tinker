package Tinker.demo.dto.simulado;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.util.List;

public class QuestoesIdsDTO {

    @NotEmpty(message = "Informe ao menos uma questao.")
    private List<@NotNull(message = "O ID da questao e obrigatorio.") Integer> questoesIds;

    public List<Integer> getQuestoesIds() { return questoesIds; }
    public void setQuestoesIds(List<Integer> questoesIds) { this.questoesIds = questoesIds; }
}
