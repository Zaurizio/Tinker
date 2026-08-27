package Tinker.demo.model;

import jakarta.persistence.*;
import java.util.Objects;

@Entity
@Table(name = "Relatorio_Questao")
@IdClass(Relatorioid.class)
public class Relatorio {

    @Id
    @Column(name = "cod_quest", nullable = false)
    private Integer codQuest;

    @Id
    @Column(name = "email", length = 45, nullable = false)
    private String email;

    @Column(name = "acertou/errou", nullable = false)
    private Integer acertouErrou;

    public Relatorio() {
    }

    public Relatorio(Integer codQuest, String email, Integer acertouErrou) {
        this.codQuest = codQuest;
        this.email = email;
        this.acertouErrou = acertouErrou;
    }

    public Integer getCodQuest() {
        return codQuest;
    }

    public void setCodQuest(Integer codQuest) {
        this.codQuest = codQuest;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Integer getAcertouErrou() {
        return acertouErrou;
    }

    public void setAcertouErrou(Integer acertouErrou) {
        this.acertouErrou = acertouErrou;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Relatorio relatorio = (Relatorio) o;
        return Objects.equals(codQuest, relatorio.codQuest) && Objects.equals(email, relatorio.email);
    }

    @Override
    public int hashCode() {
        return Objects.hash(codQuest, email);
    }

    @Override
    public String toString() {
        return "Relatorio{" +
                "codQuest=" + codQuest +
                ", email='" + email + '\'' +
                ", acertouErrou=" + acertouErrou +
                '}';
    }
}
