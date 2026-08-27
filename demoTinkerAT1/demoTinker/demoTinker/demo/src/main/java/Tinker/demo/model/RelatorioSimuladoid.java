package Tinker.demo.model;

import java.io.Serializable;
import java.util.Objects;

public class RelatorioSimuladoid implements Serializable {
    private Integer codSimulado;
    private String emailAluno;

    public RelatorioSimuladoid() {
    }

    public RelatorioSimuladoid(Integer codSimulado, String emailAluno) {
        this.codSimulado = codSimulado;
        this.emailAluno = emailAluno;
    }

    public Integer getCodSimulado() { return codSimulado; }
    public void setCodSimulado(Integer codSimulado) { this.codSimulado = codSimulado; }
    public String getEmailAluno() { return emailAluno; }
    public void setEmailAluno(String emailAluno) { this.emailAluno = emailAluno; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        RelatorioSimuladoid that = (RelatorioSimuladoid) o;
        return Objects.equals(codSimulado, that.codSimulado)
                && Objects.equals(emailAluno, that.emailAluno);
    }

    @Override
    public int hashCode() {
        return Objects.hash(codSimulado, emailAluno);
    }
}
