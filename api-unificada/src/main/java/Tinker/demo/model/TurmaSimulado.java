package Tinker.demo.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "Turma_Simulado")
public class TurmaSimulado {

    @Id
    @Column(name = "id_publicacao", length = 45, nullable = false)
    private String idPublicacao;

    @Column(name = "cod_simulado", nullable = false)
    private Integer codSimulado;

    @Column(name = "cod_turma", length = 8, nullable = false)
    private String codTurma;

    @Column(name = "ativo")
    private Integer ativo;

    @Column(name = "data_publicacao", length = 45)
    private String dataPublicacao;

    public TurmaSimulado() {
    }

    public String getIdPublicacao() { return idPublicacao; }
    public void setIdPublicacao(String idPublicacao) { this.idPublicacao = idPublicacao; }
    public Integer getCodSimulado() { return codSimulado; }
    public void setCodSimulado(Integer codSimulado) { this.codSimulado = codSimulado; }
    public String getCodTurma() { return codTurma; }
    public void setCodTurma(String codTurma) { this.codTurma = codTurma; }
    public Integer getAtivo() { return ativo; }
    public void setAtivo(Integer ativo) { this.ativo = ativo; }
    public String getDataPublicacao() { return dataPublicacao; }
    public void setDataPublicacao(String dataPublicacao) { this.dataPublicacao = dataPublicacao; }
}
