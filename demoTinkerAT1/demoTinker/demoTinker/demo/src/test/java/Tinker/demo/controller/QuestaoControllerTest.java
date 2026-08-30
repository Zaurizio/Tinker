package Tinker.demo.controller;

import Tinker.demo.dto.questao.CorrigirQuestaoDTO;
import Tinker.demo.dto.questao.FiltrosQuestaoDTO;
import Tinker.demo.security.UsuarioAutenticado;
import Tinker.demo.service.QuestaoService;
import org.junit.jupiter.api.Test;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.lang.reflect.Method;
import java.util.Arrays;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

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

    @Test
    void endpointDeFiltrosEstaMapeadoEmGetSemParametros() throws Exception {
        Method filtros = QuestaoController.class.getDeclaredMethod("filtros");

        assertTrue(filtros.isAnnotationPresent(GetMapping.class));
        assertEquals("/filtros", filtros.getAnnotation(GetMapping.class).value()[0]);
        assertEquals(0, filtros.getParameterCount());
        assertEquals(FiltrosQuestaoDTO.class, filtros.getReturnType());
    }

    @Test
    void endpointDeFiltrosDelegaParaOService() {
        QuestaoService service = mock(QuestaoService.class);
        FiltrosQuestaoDTO resposta = new FiltrosQuestaoDTO(java.util.List.of(), java.util.List.of(), java.util.List.of());
        when(service.filtros()).thenReturn(resposta);

        QuestaoController controller = new QuestaoController(service);

        assertEquals(resposta, controller.filtros());
        verify(service).filtros();
    }

    @Test
    void rotasExistentesDeQuestoesContinuamMapeadas() throws Exception {
        assertTrue(QuestaoController.class.getDeclaredMethod("listar",
                        java.util.List.class, java.util.List.class, java.util.List.class,
                        java.util.List.class, String.class, int.class, int.class)
                .isAnnotationPresent(GetMapping.class));
        Method detalhar = QuestaoController.class.getDeclaredMethod("detalhar", Integer.class);
        assertTrue(detalhar.isAnnotationPresent(GetMapping.class));
        assertEquals("/{id}", detalhar.getAnnotation(GetMapping.class).value()[0]);
    }
}
