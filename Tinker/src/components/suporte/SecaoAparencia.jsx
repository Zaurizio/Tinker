import { FaMoon, FaRegCircle, FaRegDotCircle, FaSun } from "react-icons/fa";
import estiloSuporte from "../../pages/Suporte.module.css";

const opcoesTema = [
  { valor: "claro", label: "Modo claro", icone: FaSun },
  { valor: "escuro", label: "Modo escuro", icone: FaMoon },
];

function SecaoAparencia({ temaSelecionado, onAlterarTema }) {
  return (
    <article className={estiloSuporte.card}>
      <div className={estiloSuporte.cabecalhoCard}>
        <h2 className={estiloSuporte.tituloCard}>Aparência</h2>
        <p className={estiloSuporte.textoCard}>
          Escolha como você deseja usar o Tinker.
        </p>
      </div>

      <div className={estiloSuporte.opcoesTema}>
        {opcoesTema.map(({ valor, label, icone }) => {
          const selecionado = temaSelecionado === valor;
          const IconeTema = icone;

          return (
            <button
              type="button"
              key={valor}
              className={`${estiloSuporte.opcaoTema} ${
                selecionado ? estiloSuporte.opcaoTemaAtiva : ""
              }`}
              onClick={() => onAlterarTema(valor)}
              aria-pressed={selecionado}
            >
              <span className={estiloSuporte.iconeTema}>
                <IconeTema />
              </span>
              <span>{label}</span>
              <span className={estiloSuporte.radioTema}>
                {selecionado ? <FaRegDotCircle /> : <FaRegCircle />}
              </span>
            </button>
          );
        })}
      </div>
    </article>
  );
}

export default SecaoAparencia;
