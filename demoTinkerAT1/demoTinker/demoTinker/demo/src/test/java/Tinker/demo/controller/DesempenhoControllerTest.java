package Tinker.demo.controller;

import Tinker.demo.dto.desempenho.DesempenhoDTO;
import Tinker.demo.security.TipoUsuario;
import Tinker.demo.security.UsuarioAutenticado;
import Tinker.demo.service.DesempenhoService;
import org.junit.jupiter.api.Test;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.lang.reflect.Method;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class DesempenhoControllerTest {

    @Test
    void rotaGetUsaSomenteUsuarioAutenticado() throws Exception {
        assertArrayEquals(new String[]{"/api/desempenho"},
                DesempenhoController.class.getAnnotation(RequestMapping.class).value());
        Method consultar = DesempenhoController.class.getDeclaredMethod(
                "consultar", UsuarioAutenticado.class);
        assertTrue(consultar.isAnnotationPresent(GetMapping.class));
        assertTrue(consultar.getParameters()[0].isAnnotationPresent(AuthenticationPrincipal.class));
    }

    @Test
    void controllerDelegaAoServiceSemReceberEmail() {
        DesempenhoService service = mock(DesempenhoService.class);
        DesempenhoController controller = new DesempenhoController(service);
        UsuarioAutenticado usuario = new UsuarioAutenticado("aluno@tinker.com", TipoUsuario.ALUNO);
        DesempenhoDTO esperado = new DesempenhoDTO(0, 0, 0, null, null, List.of(), 0);
        when(service.consultar(usuario)).thenReturn(esperado);

        assertEquals(esperado, controller.consultar(usuario));
        verify(service).consultar(usuario);
    }
}
