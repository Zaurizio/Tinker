import { FaBug, FaLightbulb } from "react-icons/fa";
import estiloConta from "../../pages/Conta.module.css";

function SecaoContato() {
  function handleRelatarProblema() {
    console.log("Relatar problema");
  }

  function handleEnviarSugestao() {
    console.log("Enviar sugestão");
  }

  return (
    <article className={estiloConta.card}>
      <div className={estiloConta.cabecalhoCard}>
        <h2 className={estiloConta.tituloCard}>Fale Conosco</h2>
        <p className={estiloConta.textoCard}>Queremos ouvir você!</p>
      </div>

      <div className={estiloConta.contatoGrid}>
        <div className={estiloConta.itemContato}>
          <span className={estiloConta.iconeContato}>
            <FaBug />
          </span>
          <div>
            <h3>Relatar problema</h3>
            <p>Encontrou algum bug ou erro?</p>
          </div>
          <button
            type="button"
            className={estiloConta.botaoContorno}
            onClick={handleRelatarProblema}
          >
            Relatar problema
          </button>
        </div>

        <div className={estiloConta.itemContato}>
          <span className={estiloConta.iconeContato}>
            <FaLightbulb />
          </span>
          <div>
            <h3>Enviar sugestão</h3>
            <p>Tem uma ideia para melhorar o Tinker?</p>
          </div>
          <button
            type="button"
            className={estiloConta.botaoContorno}
            onClick={handleEnviarSugestao}
          >
            Enviar sugestão
          </button>
        </div>
      </div>
    </article>
  );
}

export default SecaoContato;
