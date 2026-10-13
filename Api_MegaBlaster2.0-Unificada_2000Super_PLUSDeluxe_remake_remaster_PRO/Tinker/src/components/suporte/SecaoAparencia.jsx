import { FaMoon, FaRegCircle, FaRegDotCircle, FaSun } from "react-icons/fa";
import estiloConta from "../../pages/Conta.module.css";

const opcoesTema = [
  { valor: "claro", label: "Modo claro", icone: FaSun },
  { valor: "escuro", label: "Modo escuro", icone: FaMoon },
];

function SecaoAparencia({ temaSelecionado, onAlterarTema }) {
  return (
    <article className={estiloConta.card}>
      <div className={estiloConta.cabecalhoCard}>
        <h2 className={estiloConta.tituloCard}>Aparência</h2>
        <p className={estiloConta.textoCard}>
          Escolha como você deseja usar o Tinker.
        </p>
      </div>

      <div className={estiloConta.opcoesTema}>
        {opcoesTema.map(({ valor, label, icone }) => {
          const selecionado = temaSelecionado === valor;
          const IconeTema = icone;

          return (
            <button
              type="button"
              key={valor}
              className={`${estiloConta.opcaoTema} ${
                selecionado ? estiloConta.opcaoTemaAtiva : ""
              }`}
              onClick={() => onAlterarTema(valor)}
              aria-pressed={selecionado}
            >
              <span className={estiloConta.iconeTema}>
                <IconeTema />
              </span>
              <span>{label}</span>
              <span className={estiloConta.radioTema}>
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
