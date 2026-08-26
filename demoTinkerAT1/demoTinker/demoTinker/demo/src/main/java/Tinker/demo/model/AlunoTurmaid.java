package Tinker.demo.model;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.Objects;

public class AlunoTurmaid implements Serializable {
    private String emailAluno;
    private Integer codTurma;

    public AlunoTurmaid() {}

    public AlunoTurmaid(String emailAluno, Integer codTurma) {
        this.emailAluno = emailAluno;
        this.codTurma = codTurma;
    }

    public String getEmailAluno() { return emailAluno; }
    public void setEmailAluno(String emailAluno) { this.emailAluno = emailAluno; }
    public Integer getCodTurma() { return codTurma; }
    public void setCodTurma(Integer codTurma) { this.codTurma = codTurma; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        AlunoTurmaid that = (AlunoTurmaid) o;
        return Objects.equals(emailAluno, that.emailAluno) && Objects.equals(codTurma, that.codTurma);
    }

    @Override
    public int hashCode() {
        return Objects.hash(emailAluno, codTurma);
    }
}