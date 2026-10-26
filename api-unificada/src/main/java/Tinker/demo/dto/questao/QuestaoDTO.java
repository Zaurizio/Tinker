package Tinker.demo.dto.questao;

import java.util.List;

public record QuestaoDTO(
        Integer id,
        String vestibular,
        Integer ano,
        String fase,
        String disciplina,
        String conteudo,
        String enunciado,
        List<AlternativaQuestaoDTO> alternativas) {
}
