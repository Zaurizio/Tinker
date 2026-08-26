package Tinker.demo.model;

import java.io.Serializable;
import java.util.Objects;

public class QuestaoSimuid implements Serializable {
    private Integer codSimulado;
    private Integer codQuestao;

    public QuestaoSimuid() {}

    public QuestaoSimuid(Integer codSimulado, Integer codQuestao) {
        this.codSimulado = codSimulado;
        this.codQuestao = codQuestao;
    }

    public Integer getCodSimulado() { return codSimulado; }
    public void setCodSimulado(Integer codSimulado) { this.codSimulado = codSimulado; }
    public Integer getCodQuestao() { return codQuestao; }
    public void setCodQuestao(Integer codQuestao) { this.codQuestao = codQuestao; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        QuestaoSimuid that = (QuestaoSimuid) o;
        return Objects.equals(codSimulado, that.codSimulado) && Objects.equals(codQuestao, that.codQuestao);
    }

    @Override
    public int hashCode() {
        return Objects.hash(codSimulado, codQuestao);
    }
}