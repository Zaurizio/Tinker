package Tinker.demo.dto;

public class LoginResponse {
    private String email;
    private String nome;
    private String sobrenome;

    public LoginResponse() {
    }

    public LoginResponse(String email, String nome, String sobrenome) {
        this.email = email;
        this.nome = nome;
        this.sobrenome = sobrenome;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getSobrenome() {
        return sobrenome;
    }

    public void setSobrenome(String sobrenome) {
        this.sobrenome = sobrenome;
    }
}