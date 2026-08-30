import { useEffect, useState } from "react";
import SecaoConta from "../components/suporte/SecaoConta";
import SecaoAparencia from "../components/suporte/SecaoAparencia";
import SecaoContato from "../components/suporte/SecaoContato";
import SecaoSobre from "../components/suporte/SecaoSobre";
import estiloConta from "./Conta.module.css";

function obterTemaInicial() {
  return localStorage.getItem("tema") === "escuro" ? "escuro" : "claro";
}

function Conta() {
  const [tema, setTema] = useState(obterTemaInicial);

  useEffect(() => {
    const modoEscuroAtivo = tema === "escuro";
    document.body.classList.toggle("dark-mode", modoEscuroAtivo);
    localStorage.setItem("tema", tema);
  }, [tema]);

  return (
    <section className={estiloConta.pagina}>
      <div className={estiloConta.conteudo}>
        <header className={estiloConta.topo}>
          <h1 className={estiloConta.titulo}>Conta</h1>
          <p className={estiloConta.subtitulo}>
            Gerencie seus dados e preferências.
          </p>
        </header>

        <SecaoConta />
        <SecaoAparencia temaSelecionado={tema} onAlterarTema={setTema} />
        <SecaoContato />
        <SecaoSobre />
      </div>
    </section>
  );
}

export default Conta;
