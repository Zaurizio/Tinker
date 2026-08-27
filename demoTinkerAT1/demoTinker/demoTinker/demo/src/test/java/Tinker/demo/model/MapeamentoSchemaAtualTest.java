package Tinker.demo.model;

import Tinker.demo.repository.TurmaRepository;
import jakarta.persistence.Column;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Field;
import java.lang.reflect.ParameterizedType;
import java.util.Arrays;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;

class MapeamentoSchemaAtualTest {

    @Test
    void turmaUsaIdTextualSemGeracaoAutomatica() throws Exception {
        Field campo = Turma.class.getDeclaredField("codTurma");

        assertEquals(String.class, campo.getType());
        assertFalse(campo.isAnnotationPresent(GeneratedValue.class));

        ParameterizedType repository = (ParameterizedType) TurmaRepository.class.getGenericInterfaces()[0];
        assertEquals(String.class, repository.getActualTypeArguments()[1]);
    }

    @Test
    void relatorioApontaParaTabelaAtual() {
        assertEquals("Relatorio_Questao", Relatorio.class.getAnnotation(Table.class).name());
    }

    @Test
    void relatorioSimuladoUsaChaveCompostaDoDump() throws Exception {
        IdClass idClass = RelatorioSimulado.class.getAnnotation(IdClass.class);

        assertNotNull(idClass);
        assertEquals(RelatorioSimuladoid.class, idClass.value());
        assertEquals(2, quantidadeDeIds(RelatorioSimulado.class));
        assertEquals("cod_simulado", coluna(RelatorioSimulado.class, "codSimulado"));
        assertEquals("email_aluno", coluna(RelatorioSimulado.class, "emailAluno"));
    }

    @Test
    void turmaSimuladoUsaSomenteIdPublicacaoComoChave() throws Exception {
        assertEquals(1, quantidadeDeIds(TurmaSimulado.class));
        assertEquals("id_publicacao", coluna(TurmaSimulado.class, "idPublicacao"));
        assertEquals(String.class, TurmaSimulado.class.getDeclaredField("idPublicacao").getType());
    }

    @Test
    void horarioMultMapeiaColunasAdicionadasNoDump() throws Exception {
        assertEquals("titulo", coluna(HorarioMult.class, "titulo"));
        assertEquals("dia_inteiro", coluna(HorarioMult.class, "diaInteiro"));
        assertEquals("cor", coluna(HorarioMult.class, "cor"));
    }

    private long quantidadeDeIds(Class<?> tipo) {
        return Arrays.stream(tipo.getDeclaredFields())
                .filter(campo -> campo.isAnnotationPresent(Id.class))
                .count();
    }

    private String coluna(Class<?> tipo, String campo) throws Exception {
        return tipo.getDeclaredField(campo).getAnnotation(Column.class).name();
    }
}
