package Tinker.demo.model;

import java.time.LocalDate;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;

@Entity
@IdClass(Cronogramaid.class)
@Table(name = "Cronograma")
public class Cronograma {

    @Id
    @Column(name = "data")
    private LocalDate data;

    @Id
    @Column(name = "email")
    private String email;

    @Column(name = "cod_simulado")
    private Integer codSimulado;

    public Cronograma() {
    }

    public LocalDate getData() {
        return data;
    }

    public void setData(LocalDate data) {
        this.data = data;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Integer getCodSimulado() {
        return codSimulado;
    }

    public void setCodSimulado(Integer codSimulado) {
        this.codSimulado = codSimulado;
    }
}