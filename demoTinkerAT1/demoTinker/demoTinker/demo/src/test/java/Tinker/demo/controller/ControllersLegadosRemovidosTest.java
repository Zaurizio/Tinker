package Tinker.demo.controller;

import Tinker.demo.model.QuestaoSimu;
import Tinker.demo.model.Relatorio;
import Tinker.demo.repository.QuestaoSimuRepository;
import Tinker.demo.repository.RelatorioRepository;
import org.junit.jupiter.api.Test;
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
            AdmController.class,
            AlunoController.class,
            ConteudoQuestController.class,
            CronogramaController.class,
            HorarioMultController.class,
            LoginController.class,
            PerfilController.class,
            ProfessorController.class,
            QuestaoController.class,
            SimuladoController.class,
            TurmaController.class);

    @Test
    void controllersLegadosNaoExistemMais() {
        assertClasseAusente("Tinker.demo.controller.RelatorioController");
        assertClasseAusente("Tinker.demo.controller.QuestaoSimuController");
    }

    @Test
    void nenhumControllerRestanteExpoeEntidadesOuRepositoriesInternos() {
        for (Class<?> controller : CONTROLLERS_RESTANTES) {
            assertFalse(Arrays.stream(controller.getDeclaredFields())
                    .anyMatch(campo -> campo.getType().equals(RelatorioRepository.class)
                            || campo.getType().equals(QuestaoSimuRepository.class)));
            assertFalse(Arrays.stream(controller.getDeclaredMethods())
                    .map(Method::getReturnType)
                    .anyMatch(tipo -> tipo.equals(Relatorio.class)
                            || tipo.equals(QuestaoSimu.class)));
            assertFalse(Arrays.stream(controller.getDeclaredMethods())
                    .flatMap(metodo -> Arrays.stream(metodo.getParameterTypes()))
                    .anyMatch(tipo -> tipo.equals(Relatorio.class)
                            || tipo.equals(QuestaoSimu.class)));
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

        assertTrue(adicionar.isAnnotationPresent(PostMapping.class));
        assertTrue(remover.isAnnotationPresent(DeleteMapping.class));
        assertTrue(corrigirPublicada.isAnnotationPresent(PostMapping.class));
        assertTrue(listarPublicada.isAnnotationPresent(GetMapping.class));
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
