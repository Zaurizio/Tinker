import { useEffect, useState } from "react";
import SecaoConta from "../components/suporte/SecaoConta";
import SecaoAparencia from "../components/suporte/SecaoAparencia";
import SecaoContato from "../components/suporte/SecaoContato";
import SecaoSobre from "../components/suporte/SecaoSobre";
import estiloSuporte from "./Suporte.module.css";

function Suporte() {
  const [tema, setTema] = useState("claro");

  useEffect(() => {
    document.body.classList.toggle("dark-mode", tema === "escuro");

    return () => {
      document.body.classList.remove("dark-mode");
    };
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
