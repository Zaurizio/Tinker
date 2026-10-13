package Tinker.demo.model;

import java.io.Serializable;
import java.util.Objects;

public class Relatorioid implements Serializable {
    private Integer codQuest;
    private String email;
    private String tipoUsu;

    public Relatorioid() {}

    public Relatorioid(Integer codQuest, String email, String tipoUsu) {
        this.codQuest = codQuest;
        this.email = email;
        this.tipoUsu = tipoUsu;
    }

    public Integer getCodQuest() { return codQuest; }
    public void setCodQuest(Integer codQuest) { this.codQuest = codQuest; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getTipoUsu() { return tipoUsu; }
    public void setTipoUsu(String tipoUsu) { this.tipoUsu = tipoUsu; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Relatorioid that = (Relatorioid) o;
        return Objects.equals(codQuest, that.codQuest)
                && Objects.equals(email, that.email)
                && Objects.equals(tipoUsu, that.tipoUsu);
    }

    @Override
    public int hashCode() {
        return Objects.hash(codQuest, email, tipoUsu);
    }
}
