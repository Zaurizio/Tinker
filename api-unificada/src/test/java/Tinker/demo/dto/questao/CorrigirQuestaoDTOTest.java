package Tinker.demo.dto.questao;

import com.fasterxml.jackson.annotation.JsonAlias;
import org.junit.jupiter.api.Test;

import java.lang.reflect.RecordComponent;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.junit.jupiter.api.Assertions.assertEquals;

class CorrigirQuestaoDTOTest {

    @Test
    void aceitaOsDoisNomesDeCampoDosClientes() throws Exception {
        RecordComponent[] componentes = CorrigirQuestaoDTO.class.getRecordComponents();
        assertEquals(1, componentes.length);
        assertEquals("alternativa", componentes[0].getName());

        // o campo do record carrega o alias usado pelo app mobile
        JsonAlias alias = CorrigirQuestaoDTO.class
                .getDeclaredField("alternativa")
                .getAnnotation(JsonAlias.class);
        assertArrayEquals(new String[] {"alternativaSelecionadaId"}, alias.value());
    }
}
