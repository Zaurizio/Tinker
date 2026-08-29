package Tinker.demo.controller;

import Tinker.demo.dto.questao.CorrigirQuestaoDTO;
import Tinker.demo.security.UsuarioAutenticado;
import Tinker.demo.service.QuestaoService;
import org.junit.jupiter.api.Test;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.lang.reflect.Method;
import java.util.Arrays;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class QuestaoControllerTest {

    @Test
    void correcaoAvulsaUsaPrincipalJwtERecebeSomenteAlternativa() throws Exception {
        Method corrigir = QuestaoController.class.getDeclaredMethod(
                "corrigir", UsuarioAutenticado.class, Integer.class, CorrigirQuestaoDTO.class);

        assertTrue(corrigir.isAnnotationPresent(PostMapping.class));
        assertEquals("/{id}/correcoes", corrigir.getAnnotation(PostMapping.class).value()[0]);
        assertTrue(corrigir.getParameters()[0]
                .isAnnotationPresent(AuthenticationPrincipal.class));
        assertTrue(corrigir.getParameters()[2].isAnnotationPresent(RequestBody.class));
        assertEquals(1, CorrigirQuestaoDTO.class.getRecordComponents().length);
        assertEquals("alternativa", CorrigirQuestaoDTO.class.getRecordComponents()[0].getName());
    }

    @Test
    void endpointRemovidoDeCorrecaoDeSimuladoPessoalNaoVoltou() {
        assertFalse(Arrays.stream(SimuladoController.class.getDeclaredMethods())
                .anyMatch(metodo -> metodo.getName().equals("corrigirQuestao")));
    }
}
