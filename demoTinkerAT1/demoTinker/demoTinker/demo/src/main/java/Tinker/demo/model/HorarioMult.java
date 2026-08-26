package Tinker.demo.model;

import java.time.LocalDate;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;

@Entity
@IdClass(HorarioMultid.class)
@Table(name = "HorarioMult")
public class HorarioMult {

    @Id
    @Column(name = "email")
    private String email;

    @Id
    @Column(name = "data")
    private LocalDate data;

    @Id
    @Column(name = "horario_inicio")
    private Float horarioInicio;

    @Column(name = "horario_fim")
    private String horarioFim;

    @Column(name = "disciplina")
    private String disciplina;

    @Column(name = "conteudo")
    private String conteudo;

    @Column(name = "descricao")
    private String descricao;

    public HorarioMult() {
    }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public LocalDate getData() { return data; }
    public void setData(LocalDate data) { this.data = data; }

    public Float getHorarioInicio() { return horarioInicio; }
    public void setHorarioInicio(Float horarioInicio) { this.horarioInicio = horarioInicio; }

    public String getHorarioFim() { return horarioFim; }
    public void setHorarioFim(String horarioFim) { this.horarioFim = horarioFim; }

    public String getDisciplina() { return disciplina; }
    public void setDisciplina(String disciplina) { this.disciplina = disciplina; }

    public String getConteudo() { return conteudo; }
    public void setConteudo(String conteudo) { this.conteudo = conteudo; }

    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }
}