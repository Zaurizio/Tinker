package Tinker.demo.model;

import jakarta.persistence.*;

@Entity
@IdClass(QuestaoSimuid.class)
@Table(name = "Quest_Simu")
public class QuestaoSimu {

    @Id
    @Column(name = "cod_simulado")
    private Integer codSimulado;

    @Id
    @Column(name = "cod_quest")
    private Integer codQuestao;

    public QuestaoSimu() {
    }

    public QuestaoSimu(Integer codSimulado, Integer codQuestao) {
        this.codSimulado = codSimulado;
        this.codQuestao = codQuestao;
    }

    public Integer getCodSimulado() {
        return codSimulado;
    }

    public void setCodSimulado(Integer codSimulado) {
        this.codSimulado = codSimulado;
    }

    public Integer getCodQuestao() {
        return codQuestao;
    }

    public void setCodQuestao(Integer codQuestao) {
        this.codQuestao = codQuestao;
    }
}
