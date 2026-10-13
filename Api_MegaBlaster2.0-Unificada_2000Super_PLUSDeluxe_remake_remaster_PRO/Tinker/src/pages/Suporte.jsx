import { useEffect, useState } from "react";
import SecaoConta from "../components/suporte/SecaoConta";
import SecaoAparencia from "../components/suporte/SecaoAparencia";
import SecaoContato from "../components/suporte/SecaoContato";
import SecaoSobre from "../components/suporte/SecaoSobre";
import estiloSuporte from "./Suporte.module.css";

function obterTemaInicial() {
  return localStorage.getItem("tema") === "escuro" ? "escuro" : "claro";
}

function Suporte() {
  const [tema, setTema] = useState(obterTemaInicial);

  useEffect(() => {
    const modoEscuroAtivo = tema === "escuro";
    document.body.classList.toggle("dark-mode", modoEscuroAtivo);
    localStorage.setItem("tema", tema);
  }, [tema]);

  return (
    <section className={estiloSuporte.pagina}>
      <div className={estiloSuporte.conteudo}>
        <header className={estiloSuporte.topo}>
          <h1 className={estiloSuporte.titulo}>Suporte e Configurações</h1>
          <p className={estiloSuporte.subtitulo}>
            Gerencie sua conta, preferências e obtenha ajuda.
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

export default Suporte;
