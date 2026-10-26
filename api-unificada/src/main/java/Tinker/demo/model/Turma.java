package Tinker.demo.model;

import jakarta.persistence.*;
import java.util.Objects;

@Entity
@Table(name = "Turma")
public class Turma {

    @Id
    @Column(name = "cod_turma", length = 8)
    private String codTurma;

    @Column(name = "nome_turma", length = 45, nullable = false)
    private String nomeTurma;

    @Column(name = "email_prof", length = 45, nullable = false)
    private String emailProf;

    @Column(name = "ativo", nullable = false)
    private Integer ativo;

    // Construtor vazio (obrigatório para JPA)
    public Turma() {
    }

    // Construtor com parâmetros (útil para testes)
    public Turma(String nomeTurma, String emailProf, Integer ativo) {
        this.nomeTurma = nomeTurma;
        this.emailProf = emailProf;
        this.ativo = ativo;
    }

    // Getters e Setters
    public String getCodTurma() {
        return codTurma;
    }

    public void setCodTurma(String codTurma) {
        this.codTurma = codTurma;
    }

    public String getNomeTurma() {
        return nomeTurma;
    }

    public void setNomeTurma(String nomeTurma) {
        this.nomeTurma = nomeTurma;
    }

    public String getEmailProf() {
        return emailProf;
    }

    public void setEmailProf(String emailProf) {
        this.emailProf = emailProf;
    }

    public Integer getAtivo() {
        return ativo;
    }

    public void setAtivo(Integer ativo) {
        this.ativo = ativo;
    }

    // equals e hashCode baseados na PK (codTurma)
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Turma turma = (Turma) o;
        return Objects.equals(codTurma, turma.codTurma);
    }

    @Override
    public int hashCode() {
        return Objects.hash(codTurma);
    }

    @Override
    public String toString() {
        return "Turma{" +
                "codTurma=" + codTurma +
                ", nomeTurma='" + nomeTurma + '\'' +
                ", emailProf='" + emailProf + '\'' +
                ", ativo=" + ativo +
                '}';
    }
}
