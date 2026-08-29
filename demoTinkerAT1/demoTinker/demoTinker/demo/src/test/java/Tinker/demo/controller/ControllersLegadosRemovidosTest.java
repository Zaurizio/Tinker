package Tinker.demo.controller;

import org.junit.jupiter.api.Test;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;

import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ControllersLegadosRemovidosTest {

    private static final List<Class<?>> CONTROLLERS_RESTANTES = List.of(
            CalendarioController.class,
            DesempenhoController.class,
            LoginController.class,
            PerfilController.class,
            QuestaoController.class,
            SimuladoController.class,
            TurmaController.class);

    @Test
    void controllersLegadosNaoExistemMais() {
        assertClasseAusente("Tinker.demo.controller.RelatorioController");
        assertClasseAusente("Tinker.demo.controller.QuestaoSimuController");
        assertClasseAusente("Tinker.demo.controller.CronogramaController");
        assertClasseAusente("Tinker.demo.controller.HorarioMultController");
        assertClasseAusente("Tinker.demo.controller.AlunoController");
        assertClasseAusente("Tinker.demo.controller.ProfessorController");
        assertClasseAusente("Tinker.demo.controller.AdmController");
        assertClasseAusente("Tinker.demo.controller.ConteudoQuestController");
    }

    @Test
    void nenhumControllerRestanteExpoeEntidadesOuRepositoriesInternos() {
        for (Class<?> controller : CONTROLLERS_RESTANTES) {
            assertFalse(Arrays.stream(controller.getDeclaredFields())
                    .anyMatch(campo -> campo.getType().getSimpleName().endsWith("Repository")));
            assertFalse(Arrays.stream(controller.getDeclaredMethods())
                    .map(Method::getReturnType)
                    .anyMatch(tipo -> tipo.isAnnotationPresent(jakarta.persistence.Entity.class)));
            assertFalse(Arrays.stream(controller.getDeclaredMethods())
                    .flatMap(metodo -> Arrays.stream(metodo.getParameterTypes()))
                    .anyMatch(tipo -> tipo.isAnnotationPresent(jakarta.persistence.Entity.class)));
        }
    }

    @Test
    void todoParametroDeUsuarioAutenticadoVemDoPrincipalJwt() {
        for (Class<?> controller : CONTROLLERS_RESTANTES) {
            for (Method metodo : controller.getDeclaredMethods()) {
                Arrays.stream(metodo.getParameters())
                        .filter(parametro -> parametro.getType().equals(
                                Tinker.demo.security.UsuarioAutenticado.class))
                        .forEach(parametro -> assertTrue(
                                parametro.isAnnotationPresent(AuthenticationPrincipal.class),
                                controller.getSimpleName() + "." + metodo.getName()
                                        + " não usa @AuthenticationPrincipal"));
            }
        }
    }

    @Test
    void rotasSegurasDeSimuladosPermanecem() throws Exception {
        Method adicionar = SimuladoController.class.getDeclaredMethod(
                "adicionarQuestoes",
                Tinker.demo.security.UsuarioAutenticado.class,
                Integer.class,
                Tinker.demo.dto.simulado.QuestoesIdsDTO.class);
        Method remover = SimuladoController.class.getDeclaredMethod(
                "removerQuestao",
                Tinker.demo.security.UsuarioAutenticado.class,
                Integer.class,
                Integer.class);
        Method corrigirPublicada = TurmaController.class.getDeclaredMethod(
                "corrigirQuestaoSimuladoPublicado",
                Tinker.demo.security.UsuarioAutenticado.class,
                String.class,
                String.class,
                Integer.class,
                Tinker.demo.dto.turma.CorrigirQuestaoPublicadaDTO.class);
        Method listarPublicada = TurmaController.class.getDeclaredMethod(
                "listarQuestoesSimuladoPublicado",
                Tinker.demo.security.UsuarioAutenticado.class,
                String.class,
                String.class);
        Method concluirPublicada = TurmaController.class.getDeclaredMethod(
                "concluirSimuladoPublicado",
                Tinker.demo.security.UsuarioAutenticado.class,
                String.class,
                String.class,
                Tinker.demo.dto.turma.ConcluirSimuladoPublicadoDTO.class);
        Method consultarResultado = TurmaController.class.getDeclaredMethod(
                "consultarResultadoSimuladoPublicado",
                Tinker.demo.security.UsuarioAutenticado.class,
                String.class,
                String.class);

        assertTrue(adicionar.isAnnotationPresent(PostMapping.class));
        assertTrue(remover.isAnnotationPresent(DeleteMapping.class));
        assertTrue(corrigirPublicada.isAnnotationPresent(PostMapping.class));
        assertTrue(listarPublicada.isAnnotationPresent(GetMapping.class));
        assertTrue(concluirPublicada.isAnnotationPresent(PostMapping.class));
        assertTrue(consultarResultado.isAnnotationPresent(GetMapping.class));
    }

    private void assertClasseAusente(String nome) {
        try {
            Class.forName(nome);
            throw new AssertionError("O controller inseguro ainda existe: " + nome);
        } catch (ClassNotFoundException esperado) {
            // comportamento esperado
        }
    }
}
