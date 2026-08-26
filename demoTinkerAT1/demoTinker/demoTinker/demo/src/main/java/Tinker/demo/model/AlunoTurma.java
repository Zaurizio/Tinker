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
    @Column(name = "cod_turma")
    private Integer codTurma;

    @Column(name = "ativo")
    private Integer ativo = 1;

    public AlunoTurma() {}

    public String getEmailAluno() { return emailAluno; }
    public void setEmailAluno(String emailAluno) { this.emailAluno = emailAluno; }

    public Integer getCodTurma() { return codTurma; }
    public void setCodTurma(Integer codTurma) { this.codTurma = codTurma; }

    public Integer getAtivo() { return ativo; }
    public void setAtivo(Integer ativo) { this.ativo = ativo; }
}