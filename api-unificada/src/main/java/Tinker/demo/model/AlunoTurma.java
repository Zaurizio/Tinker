package Tinker.demo.model;

import jakarta.persistence.*;

@Entity
@IdClass(AlunoTurmaid.class)
@Table(name = "Aluno_Turma")
public class AlunoTurma {

    @Id
    @Column(name = "email_aluno")
    private String emailAluno;

    @Id
    @Column(name = "cod_turma", length = 8)
    private String codTurma;

    @Column(name = "ativo")
    private Integer ativo = 1;

    public AlunoTurma() {}

    public String getEmailAluno() { return emailAluno; }
    public void setEmailAluno(String emailAluno) { this.emailAluno = emailAluno; }

    public String getCodTurma() { return codTurma; }
    public void setCodTurma(String codTurma) { this.codTurma = codTurma; }

    public Integer getAtivo() { return ativo; }
    public void setAtivo(Integer ativo) { this.ativo = ativo; }
}
