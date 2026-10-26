package Tinker.demo.model;

import java.time.LocalDate;
import java.io.Serializable;
import java.util.Objects;

public class HorarioMultid implements Serializable {
    private String email;
    private LocalDate data;
    private Float horarioInicio;

    public HorarioMultid() {}

    public HorarioMultid(String email, LocalDate data, Float horarioInicio) {
        this.email = email;
        this.data = data;
        this.horarioInicio = horarioInicio;
    }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public LocalDate getData() { return data; }
    public void setData(LocalDate data) { this.data = data; }
    public Float getHorarioInicio() { return horarioInicio; }
    public void setHorarioInicio(Float horarioInicio) { this.horarioInicio = horarioInicio; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        HorarioMultid that = (HorarioMultid) o;
        return Objects.equals(email, that.email) && Objects.equals(data, that.data) && Objects.equals(horarioInicio, that.horarioInicio);
    }

    @Override
    public int hashCode() {
        return Objects.hash(email, data, horarioInicio);
    }
}
