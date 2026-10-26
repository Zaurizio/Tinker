package Tinker.demo.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "Conteudo_Quest")
public class ConteudoQuest {

    @Id
    @Column(name = "idConteudo_Quest")
    private Integer idConteudoQuest;

    @Column(name = "cod_quest")
    private String codQuest;

    @Column(name = "conteudo")
    private String conteudo;

    // Construtor vazio
    public ConteudoQuest() {
    }

    // Getters e Setters
    public Integer getIdConteudoQuest() {
        return idConteudoQuest;
    }

    public void setIdConteudoQuest(Integer idConteudoQuest) {
        this.idConteudoQuest = idConteudoQuest;
    }

    public String getCodQuest() {
        return codQuest;
    }

    public void setCodQuest(String codQuest) {
        this.codQuest = codQuest;
    }

    public String getConteudo() {
        return conteudo;
    }

    public void setConteudo(String conteudo) {
        this.conteudo = conteudo;
    }
}
