import { useNavigate } from "react-router";

import { IoIosArrowBack } from "react-icons/io";
import Card from "../../components/ui/Card";
import estilo from "./Login.module.css";
import { fazerLogin } from "../../services/autenticacaoService";
import { useState } from "react";

function Login() {
  const [email, setEmail] = useState("");
  const [senha, setSenha] = useState("");
  const navigate = useNavigate();

  async function logar(e) {
        e.preventDefault();
        
        const dados = new FormData()
        dados.append("email", email) 
        dados.append("senha", senha)

        //precisa startar o servidor PHP na pasta backend
        const result = await fetch("http://localhost:8000/login.php", {
        method: "POST",
        body: dados
        })
        
        const resultado = await result.json();

        if (resultado.sucesso) {
          localStorage.setItem("usuario", JSON.stringify(resultado.nome));
          localStorage.setItem("sobrenome", JSON.stringify(resultado.sobrenome));
          localStorage.setItem("email", JSON.stringify(resultado.email));
          navigate("/home");
        } else {
          alert(resultado.mensagem);
        }
    }

  async function handleLogin(e) {
    e.preventDefault();

    const resultado = await fazerLogin(email, senha);

    
  }

  return (
    <div className={estilo.pagina}>
      <div className={estilo.topo}>
        <button className={estilo.voltar} onClick={() => navigate(-1)}>
            <span className={estilo.icone}>
                <IoIosArrowBack />
            </span>
        </button>
      </div>

      <div className={estilo.centro}>
        <Card className={estilo.card}>

          <div className={estilo.logoContainer}>
            <img src="/logoCirc.png" alt="Logo Tinker" className={estilo.logoImage} />
            <span className={estilo.logotipo}>Tinker</span>
          </div>

          <h1 className={estilo.titulo}>Entrar</h1>
          <p className={estilo.subtitulo}>Acesse sua conta para continuar</p>

          <form className={estilo.formulario} onSubmit={logar}>
            <div className={estilo.campo}>
              <label className={estilo.label}>E-mail</label>
              <input
                className={estilo.input}
                type="email"
                placeholder="seu@email.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </div>

            <div className={estilo.campo}>
              <label className={estilo.label}>Senha</label>
              <input
                className={estilo.input}
                type="password"
                placeholder="sua senha"
                value={senha}
                onChange={(e) => setSenha(e.target.value)}
              />
            </div>

            <button type="submit" className={estilo.botao}>
              Entrar
            </button>
          </form>

          <p className={estilo.rodape}>
            Não tem conta?{" "}
            <a href="/cadastro" className={estilo.link}>
              Criar conta
            </a>
          </p>
        </Card>
      </div>
    </div>
  );
}

export default Login;