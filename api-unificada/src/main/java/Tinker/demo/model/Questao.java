package Tinker.demo.model;

import jakarta.persistence.*;
import java.util.Arrays;
import java.util.Objects;

@Entity
@Table(name = "Questao") // Nome da tabela no banco
public class Questao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // AUTO_INCREMENT
    @Column(name = "cod_questao")
    private Integer codQuestao;

    @Column(name = "vestibular", length = 10)
    private String vestibular;

    @Column(name = "ano", nullable = false, columnDefinition = "YEAR")
    private Integer ano; // O tipo YEAR do MySQL mapeia bem para Integer

    @Column(name = "fase", length = 15)
    private String fase;

    @Column(name = "disciplina", length = 20)
    private String disciplina;

    @Column(name = "conteudo", length = 25, nullable = false)
    private String conteudo;

    // Usamos columnDefinition para garantir que o DDL crie como MEDIUMTEXT e não TEXT
    @Lob
    @Column(name = "enunciado", nullable = false, columnDefinition = "MEDIUMTEXT")
    private String enunciado;

    @Lob
    @Column(name = "imagem", columnDefinition = "LONGBLOB")
    private byte[] imagem;

    @Lob
    @Column(name = "alternativaA", columnDefinition = "MEDIUMTEXT")
    private String alternativaA;

    @Lob
    @Column(name = "alternativaB", columnDefinition = "MEDIUMTEXT")
    private String alternativaB;

    @Lob
    @Column(name = "alternativaC", columnDefinition = "MEDIUMTEXT")
    private String alternativaC;

    @Lob
    @Column(name = "alternativaD", columnDefinition = "MEDIUMTEXT")
    private String alternativaD;

    @Lob
    @Column(name = "alternativaE", columnDefinition = "MEDIUMTEXT")
    private String alternativaE;

    @Lob
    @Column(name = "resposta", nullable = false, columnDefinition = "MEDIUMTEXT")
    private String resposta;

    @Column(name = "ativo", nullable = false)
    private Integer ativo; // Pode ser usado como 0 ou 1 para booleano

    // Construtor vazio (obrigatório para JPA)
    public Questao() {
    }

    // Construtor com parâmetros (útil para testes, se desejar)
    public Questao(String vestibular, Integer ano, String fase, String disciplina, String conteudo,
                   String enunciado, byte[] imagem, String alternativaA, String alternativaB,
                   String alternativaC, String alternativaD, String alternativaE, String resposta,
                   Integer ativo) {
        this.vestibular = vestibular;
        this.ano = ano;
        this.fase = fase;
        this.disciplina = disciplina;
        this.conteudo = conteudo;
        this.enunciado = enunciado;
        this.imagem = imagem;
        this.alternativaA = alternativaA;
        this.alternativaB = alternativaB;
        this.alternativaC = alternativaC;
        this.alternativaD = alternativaD;
        this.alternativaE = alternativaE;
        this.resposta = resposta;
        this.ativo = ativo;
    }

    // Getters e Setters
    public Integer getCodQuestao() {
        return codQuestao;
    }

    public void setCodQuestao(Integer codQuestao) {
        this.codQuestao = codQuestao;
    }

    public String getVestibular() {
        return vestibular;
    }

    public void setVestibular(String vestibular) {
        this.vestibular = vestibular;
    }

    public Integer getAno() {
        return ano;
    }

    public void setAno(Integer ano) {
        this.ano = ano;
    }

    public String getFase() {
        return fase;
    }

    public void setFase(String fase) {
        this.fase = fase;
    }

    public String getDisciplina() {
        return disciplina;
    }

    public void setDisciplina(String disciplina) {
        this.disciplina = disciplina;
    }

    public String getConteudo() {
        return conteudo;
    }

    public void setConteudo(String conteudo) {
        this.conteudo = conteudo;
    }

    public String getEnunciado() {
        return enunciado;
    }

    public void setEnunciado(String enunciado) {
        this.enunciado = enunciado;
    }

    public byte[] getImagem() {
        return imagem;
    }

    public void setImagem(byte[] imagem) {
        this.imagem = imagem;
    }

    public String getAlternativaA() {
        return alternativaA;
    }

    public void setAlternativaA(String alternativaA) {
        this.alternativaA = alternativaA;
    }

    public String getAlternativaB() {
        return alternativaB;
    }

    public void setAlternativaB(String alternativaB) {
        this.alternativaB = alternativaB;
    }

    public String getAlternativaC() {
        return alternativaC;
    }

    public void setAlternativaC(String alternativaC) {
        this.alternativaC = alternativaC;
    }

    public String getAlternativaD() {
        return alternativaD;
    }

    public void setAlternativaD(String alternativaD) {
        this.alternativaD = alternativaD;
    }

    public String getAlternativaE() {
        return alternativaE;
    }

    public void setAlternativaE(String alternativaE) {
        this.alternativaE = alternativaE;
    }

    public String getResposta() {
        return resposta;
    }

    public void setResposta(String resposta) {
        this.resposta = resposta;
    }

    public Integer getAtivo() {
        return ativo;
    }

    public void setAtivo(Integer ativo) {
        this.ativo = ativo;
    }

    // equals e hashCode baseados no ID (codQuestao)
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Questao questao = (Questao) o;
        return Objects.equals(codQuestao, questao.codQuestao);
    }

    @Override
    public int hashCode() {
        return Objects.hash(codQuestao);
    }

    // toString (evitamos imprimir a imagem e o enunciado enorme por questões de log)
    @Override
    public String toString() {
        return "Questao{" +
                "codQuestao=" + codQuestao +
                ", vestibular='" + vestibular + '\'' +
                ", ano=" + ano +
                ", fase='" + fase + '\'' +
                ", disciplina='" + disciplina + '\'' +
                ", conteudo='" + conteudo + '\'' +
                ", ativo=" + ativo +
                '}';
    }
}