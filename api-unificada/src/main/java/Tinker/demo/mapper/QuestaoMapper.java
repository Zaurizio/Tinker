package Tinker.demo.mapper;

import Tinker.demo.dto.questao.AlternativaQuestaoDTO;
import Tinker.demo.dto.questao.QuestaoDTO;
import Tinker.demo.model.Questao;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Component
public class QuestaoMapper {

    public QuestaoDTO paraDTO(Questao questao) {
        List<AlternativaQuestaoDTO> alternativas = new ArrayList<>();
        adicionar(alternativas, "A", questao.getAlternativaA());
        adicionar(alternativas, "B", questao.getAlternativaB());
        adicionar(alternativas, "C", questao.getAlternativaC());
        adicionar(alternativas, "D", questao.getAlternativaD());
        adicionar(alternativas, "E", questao.getAlternativaE());

        return new QuestaoDTO(
                questao.getCodQuestao(),
                questao.getVestibular(),
                questao.getAno(),
                questao.getFase(),
                questao.getDisciplina(),
                questao.getConteudo(),
                questao.getEnunciado(),
                List.copyOf(alternativas));
    }

    private void adicionar(List<AlternativaQuestaoDTO> alternativas, String id, String texto) {
        if (texto != null && !texto.isBlank()) {
            alternativas.add(new AlternativaQuestaoDTO(id, texto));
        }
    }
}
