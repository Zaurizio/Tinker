package Tinker.demo.model;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.Objects;

public class AlunoTurmaid implements Serializable {
    private String emailAluno;
    private String codTurma;

    public AlunoTurmaid() {}

    public AlunoTurmaid(String emailAluno, String codTurma) {
        this.emailAluno = emailAluno;
        this.codTurma = codTurma;
    }

    public String getEmailAluno() { return emailAluno; }
    public void setEmailAluno(String emailAluno) { this.emailAluno = emailAluno; }
    public String getCodTurma() { return codTurma; }
    public void setCodTurma(String codTurma) { this.codTurma = codTurma; }

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
