package Tinker.demo.model;

import java.time.LocalDate;
import java.io.Serializable;
import java.util.Objects;

public class Cronogramaid implements Serializable {
    private LocalDate data;
    private String email;

    public Cronogramaid() {}

    public Cronogramaid(LocalDate data, String email) {
        this.data = data;
        this.email = email;
    }

    public LocalDate getData() { return data; }
    public void setData(LocalDate data) { this.data = data; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Cronogramaid that = (Cronogramaid) o;
        return Objects.equals(data, that.data) && Objects.equals(email, that.email);
    }

    @Override
    public int hashCode() {
        return Objects.hash(data, email);
    }
}
