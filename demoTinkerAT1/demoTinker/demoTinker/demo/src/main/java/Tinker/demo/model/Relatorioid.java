package Tinker.demo.model;

import java.io.Serializable;
import java.util.Objects;

public class Relatorioid implements Serializable {
    private Integer codQuest;
    private String email;

    public Relatorioid() {}

    public Relatorioid(Integer codQuest, String email) {
        this.codQuest = codQuest;
        this.email = email;
    }

    public Integer getCodQuest() { return codQuest; }
    public void setCodQuest(Integer codQuest) { this.codQuest = codQuest; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Relatorioid that = (Relatorioid) o;
        return Objects.equals(codQuest, that.codQuest) && Objects.equals(email, that.email);
    }

    @Override
    public int hashCode() {
        return Objects.hash(codQuest, email);
    }
}