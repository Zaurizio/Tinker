package Tinker.demo.controller;

import Tinker.demo.dto.turma.MembroTurmaDTO;
import Tinker.demo.dto.turma.TurmaDTO;
import Tinker.demo.model.AlunoTurma;
import Tinker.demo.model.Turma;
import Tinker.demo.service.TurmaService;
import org.junit.jupiter.api.Test;
import org.springframework.web.bind.annotation.RequestMapping;

import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;

class TurmaControllerTest {

    @Test
    void usaSomenteBasePluralAutenticadaEService() {
        RequestMapping mapping = TurmaController.class.getAnnotation(RequestMapping.class);

        assertEquals(List.of("/api/turmas"), Arrays.asList(mapping.value()));
        assertTrue(Arrays.stream(TurmaController.class.getDeclaredFields())
                .anyMatch(campo -> campo.getType().equals(TurmaService.class)));
        assertFalse(Arrays.stream(TurmaController.class.getDeclaredFields())
                .anyMatch(campo -> campo.getType().getSimpleName().endsWith("Repository")));
    }

    @Test
    void nenhumaRotaRetornaEntity() {
        for (Method metodo : TurmaController.class.getDeclaredMethods()) {
            assertFalse(metodo.getReturnType().equals(Turma.class));
            assertFalse(metodo.getReturnType().equals(AlunoTurma.class));
        }
        assertEquals(List.of("codigo", "nome", "criadorNome"), componentes(TurmaDTO.class));
        assertEquals(List.of("email", "nome", "sobrenome"), componentes(MembroTurmaDTO.class));
    }

    @Test
    void crudAntigoDeMembershipNaoExiste() throws Exception {
        assertThrowsClassNotFound("Tinker.demo.controller.AlunoTurmaController");
        assertFalse(Arrays.stream(TurmaController.class.getDeclaredMethods())
                .map(Method::getName)
                .anyMatch(nome -> nome.equals("atualizar")));
    }

    private List<String> componentes(Class<?> tipo) {
        return Arrays.stream(tipo.getRecordComponents()).map(c -> c.getName()).toList();
    }

    private void assertThrowsClassNotFound(String nome) throws Exception {
        try {
            Class.forName(nome);
            throw new AssertionError("O controller inseguro ainda existe: " + nome);
        } catch (ClassNotFoundException esperado) {
            // comportamento esperado
        }
    }
}
