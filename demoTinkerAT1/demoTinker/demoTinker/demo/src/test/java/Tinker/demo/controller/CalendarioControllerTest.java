package Tinker.demo.controller;

import Tinker.demo.dto.calendario.CriarEventoDTO;
import Tinker.demo.dto.calendario.EventoCalendarioDTO;
import Tinker.demo.model.HorarioMult;
import Tinker.demo.repository.HorarioMultRepository;
import Tinker.demo.service.CalendarioService;
import Tinker.demo.security.TipoUsuario;
import Tinker.demo.security.UsuarioAutenticado;
import org.junit.jupiter.api.Test;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

import java.lang.reflect.Method;
import java.lang.reflect.Parameter;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

class CalendarioControllerTest {

    @Test
    void usaRotaSeguraESomenteService() {
        RequestMapping mapping = CalendarioController.class.getAnnotation(RequestMapping.class);
        assertEquals(List.of("/api/calendario/eventos"), Arrays.asList(mapping.value()));
        assertTrue(Arrays.stream(CalendarioController.class.getDeclaredFields())
                .anyMatch(campo -> campo.getType().equals(CalendarioService.class)));
        assertFalse(Arrays.stream(CalendarioController.class.getDeclaredFields())
                .anyMatch(campo -> campo.getType().equals(HorarioMultRepository.class)));
    }

    @Test
    void contratoNaoAceitaEmailNemExpoeEntidade() {
        assertFalse(Arrays.stream(CriarEventoDTO.class.getRecordComponents())
                .anyMatch(c -> c.getName().equals("email")));
        for (Method metodo : CalendarioController.class.getDeclaredMethods()) {
            assertFalse(metodo.getReturnType().equals(HorarioMult.class));
            assertFalse(Arrays.asList(metodo.getParameterTypes()).contains(HorarioMult.class));
        }
        assertEquals(7, EventoCalendarioDTO.class.getRecordComponents().length);
    }

    @Test
    void controllersLegadosNaoPermanecemMapeados() {
        assertAusente("Tinker.demo.controller.CronogramaController");
        assertAusente("Tinker.demo.controller.HorarioMultController");
    }

    @Test
    void getPostEDeleteRecebemUsuarioPorAuthenticationPrincipal() throws Exception {
        Method listar = CalendarioController.class.getDeclaredMethod("listar", UsuarioAutenticado.class);
        Method criar = CalendarioController.class.getDeclaredMethod(
                "criar", UsuarioAutenticado.class, CriarEventoDTO.class);
        Method excluir = CalendarioController.class.getDeclaredMethod(
                "excluir", UsuarioAutenticado.class, String.class);

        assertTrue(listar.getParameters()[0].isAnnotationPresent(AuthenticationPrincipal.class));
        assertTrue(criar.getParameters()[0].isAnnotationPresent(AuthenticationPrincipal.class));
        assertTrue(excluir.getParameters()[0].isAnnotationPresent(AuthenticationPrincipal.class));
    }

    @Test
    void listagemEncaminhaUsuarioAutenticadoAoService() {
        CalendarioService service = mock(CalendarioService.class);
        CalendarioController controller = new CalendarioController(service);
        UsuarioAutenticado usuario = new UsuarioAutenticado("aluno@teste.com", TipoUsuario.ALUNO);

        controller.listar(usuario);

        verify(service).listar(usuario);
    }

    @Test
    void criacaoEncaminhaUsuarioAutenticadoAoService() {
        CalendarioService service = mock(CalendarioService.class);
        CalendarioController controller = new CalendarioController(service);
        UsuarioAutenticado usuario = new UsuarioAutenticado("professor@teste.com", TipoUsuario.PROFESSOR);
        CriarEventoDTO entrada = new CriarEventoDTO(
                "Prova", LocalDate.of(2026, 9, 10), LocalTime.of(14, 0), LocalTime.of(15, 0),
                false, "#2F80ED", Tinker.demo.dto.calendario.RecorrenciaEvento.NENHUMA, null);

        controller.criar(usuario, entrada);

        verify(service).criar(usuario, entrada);
    }

    @Test
    void rotasNaoPossuemParametroDeEmail() {
        for (Method metodo : CalendarioController.class.getDeclaredMethods()) {
            assertFalse(Arrays.stream(metodo.getParameters())
                    .map(Parameter::getName)
                    .anyMatch(nome -> nome.equalsIgnoreCase("email")));
            assertFalse(Arrays.stream(metodo.getParameters())
                    .filter(parametro -> parametro.isAnnotationPresent(RequestBody.class)
                            || parametro.isAnnotationPresent(RequestParam.class))
                    .anyMatch(parametro -> parametro.getType().equals(String.class)));
        }
    }

    @Test
    void exclusaoEncaminhaSomenteUsuarioAutenticadoEIdAoService() {
        CalendarioService service = mock(CalendarioService.class);
        CalendarioController controller = new CalendarioController(service);
        UsuarioAutenticado usuario = new UsuarioAutenticado("aluno@teste.com", TipoUsuario.ALUNO);

        controller.excluir(usuario, "2026-09-10|14:00");

        verify(service).excluir(usuario, "2026-09-10|14:00");
    }

    private void assertAusente(String classe) {
        try {
            Class.forName(classe);
            throw new AssertionError("Controller legado ainda existe: " + classe);
        } catch (ClassNotFoundException esperado) {
            // esperado
        }
    }
}
