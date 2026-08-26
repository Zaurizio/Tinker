package Tinker.demo.model;

import jakarta.persistence.*;
import java.util.Objects;

@Entity
@Table(name = "Simulado")
public class Simulado {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // AUTO_INCREMENT
    @Column(name = "cod_simulado")
    private Integer codSimulado;

    @Column(name = "nome", length = 20, nullable = false)
    private String nome;

    @Column(name = "descricao", length = 300)
    private String descricao;

    @Column(name = "conclusao", nullable = false)
    private Integer conclusao; // Exemplo: 0 = não concluído, 1 = concluído

    @Column(name = "tempo")
    private Float tempo;

    @Column(name = "email_aluno", length = 45)
    private String emailAluno;

    @Column(name = "email_prof", length = 45)
    private String emailProf;

    // Construtor vazio (obrigatório JPA)
    public Simulado() {
    }

    // Construtor com parâmetros (útil para testes)
    public Simulado(String nome, String descricao, Integer conclusao, Float tempo, String emailAluno, String emailProf) {
        this.nome = nome;
        this.descricao = descricao;
        this.conclusao = conclusao;
        this.tempo = tempo;
        this.emailAluno = emailAluno;
        this.emailProf = emailProf;
    }

    // Getters e Setters
    public Integer getCodSimulado() {
        return codSimulado;
    }

    public void setCodSimulado(Integer codSimulado) {
        this.codSimulado = codSimulado;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public Integer getConclusao() {
        return conclusao;
    }

    public void setConclusao(Integer conclusao) {
        this.conclusao = conclusao;
    }

    public Float getTempo() {
        return tempo;
    }

    public void setTempo(Float tempo) {
        this.tempo = tempo;
    }

    public String getEmailAluno() {
        return emailAluno;
    }

    public void setEmailAluno(String emailAluno) {
        this.emailAluno = emailAluno;
    }

    public String getEmailProf() {
        return emailProf;
    }

    public void setEmailProf(String emailProf) {
        this.emailProf = emailProf;
    }

    // equals e hashCode baseados na PK (codSimulado)
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Simulado simulado = (Simulado) o;
        return Objects.equals(codSimulado, simulado.codSimulado);
    }

    @Override
    public int hashCode() {
        return Objects.hash(codSimulado);
    }

    @Override
    public String toString() {
        return "Simulado{" +
                "codSimulado=" + codSimulado +
                ", nome='" + nome + '\'' +
                ", conclusao=" + conclusao +
                ", emailAluno='" + emailAluno + '\'' +
                '}';
    }
}