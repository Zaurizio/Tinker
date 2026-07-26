import { useNavigate } from "react-router";
import { useState } from "react";
import { IoIosArrowBack } from "react-icons/io";
import Card from "../../components/ui/Card";
import estiloLogin from "./Login.module.css";
import estiloCad from "./Cadastro.module.css";

import { fazerCadastro } from "../../services/autenticacaoService";

function Cadastro() {
    const [nome, setNome] = useState("");
    const [sobrenome, setSobrenome] = useState("");
    const [email, setEmail] = useState("");
    const [senha, setSenha] = useState("");
    const navigate = useNavigate();

    async function cadastrar(e) {
        e.preventDefault();
        const dados = new FormData()
        dados.append("nome", nome)
        dados.append("sobrenome", sobrenome)
        dados.append("email", email) 
        dados.append("senha", senha)

        //precisa startar o servidor PHP na pasta backend
        const result = await fetch("http://localhost:8000/cadastro.php", {
        method: "POST",
        body: dados
        })

        const resultado = await result.json();
        
        if (resultado.sucesso) {
            alert(resultado.mensagem);
            navigate("/login");
        } else {
            alert(resultado.mensagem);
        }
    }

    async function handleCadastro(e) {
        e.preventDefault();

        const resultado = await fazerCadastro(nome, sobrenome, email, senha);

        
    }

  
  return (
    <div className={estiloLogin.pagina}>
      <div className={estiloLogin.topo}>
        <button className={estiloLogin.voltar} onClick={() => navigate(-1)}>
            <span className={estiloLogin.icone}>
                <IoIosArrowBack />
            </span>
        </button>
        
      </div>

      <div className={estiloLogin.centro}>
        <Card className={estiloCad.card}>
            <div className={estiloLogin.logoContainer}>
                <img src="/logoCirc.png" alt="Logo Tinker" className={estiloLogin.logoImage} />
                <span className={estiloLogin.logotipo}>Tinker</span>
            </div>
          <h1 className={estiloLogin.titulo}>Cadastrar</h1>
          <p className={estiloLogin.subtitulo}>Crie sua conta para continuar</p>

          <form className={estiloLogin.formulario} onSubmit={cadastrar}>
            <div className={estiloCad.camposDuplos}>
                <div className={estiloCad.campoDuplo}>
                    <label className={estiloLogin.label}>Nome</label>
                    <input
                        className={estiloLogin.input}
                        type="text"
                        placeholder="seu nome"
                        value={nome}
                        onChange={(e) => setNome(e.target.value)}
                    />
                    </div>
                    <div className={estiloCad.campoDuplo}>
                    <label className={estiloLogin.label}>Sobrenome</label>
                    <input
                        className={estiloLogin.input}
                        type="text"
                        placeholder="seu sobrenome"
                        value={sobrenome}
                        onChange={(e) => setSobrenome(e.target.value)}
                    />
                </div>
            </div>

            <div className={estiloLogin.campo}>
                <label className={estiloLogin.label}>E-mail</label>
                <input
                    className={estiloLogin.input}
                    type="email"
                    placeholder="seu@email.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                />
            </div>

            <div className={estiloLogin.campo}>
                <label className={estiloLogin.label}>Senha</label>
                <input
                    className={estiloLogin.input}
                    type="password"
                    placeholder="sua senha"
                    value={senha}
                    onChange={(e) => setSenha(e.target.value)}
                />
            </div>

            <button type="submit" className={estiloLogin.botao}>
                Criar conta
            </button>
          </form>

          <p className={estiloLogin.rodape}>
                Já tem conta?{" "}
                <a href="/login" className={estiloLogin.link}>
                Fazer login
                </a>
          </p>
        </Card>
      </div>
    </div>
  );
}

export default Cadastro;