package Tinker.demo.mapper;

import Tinker.demo.dto.questao.QuestaoDTO;
import Tinker.demo.model.Questao;
import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;

class QuestaoMapperTest {

    private final QuestaoMapper mapper = new QuestaoMapper();

    @Test
    void mapeiaQuatroAlternativas() {
        QuestaoDTO dto = mapper.paraDTO(questao(null));

        assertEquals(List.of("A", "B", "C", "D"),
                dto.alternativas().stream().map(alternativa -> alternativa.id()).toList());
    }

    @Test
    void mapeiaCincoAlternativas() {
        QuestaoDTO dto = mapper.paraDTO(questao("Alternativa E"));

        assertEquals(5, dto.alternativas().size());
        assertEquals("E", dto.alternativas().get(4).id());
        assertEquals("Alternativa E", dto.alternativas().get(4).texto());
    }

    @Test
    void omiteAlternativaENulaOuVazia() {
        assertEquals(4, mapper.paraDTO(questao(null)).alternativas().size());
        assertEquals(4, mapper.paraDTO(questao("   ")).alternativas().size());
    }

    @Test
    void dtoNaoPossuiGabaritoOuCamposInternos() {
        List<String> campos = Arrays.stream(QuestaoDTO.class.getRecordComponents())
                .map(componente -> componente.getName())
                .toList();

        assertFalse(campos.contains("resposta"));
        assertFalse(campos.contains("alternativaCorretaId"));
        assertFalse(campos.contains("imagem"));
        assertFalse(campos.contains("ativo"));
    }

    private Questao questao(String alternativaE) {
        Questao questao = new Questao();
        questao.setCodQuestao(1);
        questao.setVestibular("ENEM");
        questao.setAno(2025);
        questao.setFase("Unica");
        questao.setDisciplina("Matematica");
        questao.setConteudo("Algebra");
        questao.setEnunciado("Enunciado seguro");
        questao.setAlternativaA("Alternativa A");
        questao.setAlternativaB("Alternativa B");
        questao.setAlternativaC("Alternativa C");
        questao.setAlternativaD("Alternativa D");
        questao.setAlternativaE(alternativaE);
        questao.setResposta("A");
        questao.setAtivo(1);
        return questao;
    }
}
