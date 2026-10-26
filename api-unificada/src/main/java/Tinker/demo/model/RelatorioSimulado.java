package Tinker.demo.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;

@Entity
@Table(name = "Relatorio_Simulado")
@IdClass(RelatorioSimuladoid.class)
public class RelatorioSimulado {

    @Id
    @Column(name = "cod_simulado", nullable = false)
    private Integer codSimulado;

    @Id
    @Column(name = "email_aluno", length = 45, nullable = false)
    private String emailAluno;

    @Column(name = "acertos")
    private Integer acertos;

    @Column(name = "erros")
    private Integer erros;

    public RelatorioSimulado() {
    }

    public Integer getCodSimulado() { return codSimulado; }
    public void setCodSimulado(Integer codSimulado) { this.codSimulado = codSimulado; }
    public String getEmailAluno() { return emailAluno; }
    public void setEmailAluno(String emailAluno) { this.emailAluno = emailAluno; }
    public Integer getAcertos() { return acertos; }
    public void setAcertos(Integer acertos) { this.acertos = acertos; }
    public Integer getErros() { return erros; }
    public void setErros(Integer erros) { this.erros = erros; }
}
