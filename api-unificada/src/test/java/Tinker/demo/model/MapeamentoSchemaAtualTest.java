package Tinker.demo.model;

import Tinker.demo.repository.TurmaRepository;
import Tinker.demo.repository.AlunoTurmaRepository;
import jakarta.persistence.Column;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;
import org.junit.jupiter.api.Test;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.lang.reflect.Field;
import java.lang.reflect.ParameterizedType;
import java.util.Arrays;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

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
    void alunoTurmaPreservaCodigoTextualComZeroAEsquerda() throws Exception {
        Field campoEntidade = AlunoTurma.class.getDeclaredField("codTurma");
        Field campoId = AlunoTurmaid.class.getDeclaredField("codTurma");
        AlunoTurma alunoTurma = new AlunoTurma();
        alunoTurma.setCodTurma("00182745");

        assertEquals(String.class, campoEntidade.getType());
        assertEquals(String.class, campoId.getType());
        assertEquals(8, campoEntidade.getAnnotation(Column.class).length());
        assertEquals("00182745", alunoTurma.getCodTurma());

        ParameterizedType repository =
                (ParameterizedType) AlunoTurmaRepository.class.getGenericInterfaces()[0];
        assertEquals(AlunoTurmaid.class, repository.getActualTypeArguments()[1]);
    }

    @Test
    void relatorioEstaPreparadoParaTipoProfessorNaChaveFutura() throws Exception {
        Field tipoSimulado = Simulado.class.getDeclaredField("tipoUsu");
        Field tipoRelatorio = Relatorio.class.getDeclaredField("tipoUsu");

        assertEquals("tipo_usu", tipoSimulado.getAnnotation(Column.class).name());
        assertEquals(8, tipoSimulado.getAnnotation(Column.class).length());
        assertFalse(tipoSimulado.getAnnotation(Column.class).nullable());
        assertEquals("tipo_usu", tipoRelatorio.getAnnotation(Column.class).name());
        assertEquals(9, tipoRelatorio.getAnnotation(Column.class).length());
        assertFalse(tipoRelatorio.getAnnotation(Column.class).nullable());
        assertTrue(tipoRelatorio.isAnnotationPresent(jakarta.persistence.Id.class));
        assertEquals(3, quantidadeDeIds(Relatorio.class));
        assertEquals("ALUNO", Simulado.TIPO_USUARIO_ALUNO);
        assertEquals("PROF", Simulado.TIPO_USUARIO_PROFESSOR);
    }

    @Test
    void relatorioApontaParaTabelaAtual() {
        assertEquals("Relatorio_Questao", Relatorio.class.getAnnotation(Table.class).name());
    }

    @Test
    void chaveFuturaSeparaMesmoEmailPorTipo() {
        Relatorioid aluno = new Relatorioid(10, "mesmo@teste.com", "ALUNO");
        Relatorioid professor = new Relatorioid(10, "mesmo@teste.com", "PROFESSOR");

        assertFalse(aluno.equals(professor));
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
        Field diaInteiro = HorarioMult.class.getDeclaredField("diaInteiro");
        assertEquals("dia_inteiro", diaInteiro.getAnnotation(Column.class).name());
        assertEquals(Boolean.class, diaInteiro.getType());
        assertEquals(SqlTypes.TINYINT, diaInteiro.getAnnotation(JdbcTypeCode.class).value());
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
