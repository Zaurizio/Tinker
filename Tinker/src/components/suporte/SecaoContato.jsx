import { FaBug, FaLightbulb } from "react-icons/fa";
import estiloSuporte from "../../pages/Suporte.module.css";

function SecaoContato() {
  function handleRelatarProblema() {
    console.log("Relatar problema");
  }

  function handleEnviarSugestao() {
    console.log("Enviar sugestão");
  }

  return (
    <article className={estiloSuporte.card}>
      <div className={estiloSuporte.cabecalhoCard}>
        <h2 className={estiloSuporte.tituloCard}>Fale Conosco</h2>
        <p className={estiloSuporte.textoCard}>Queremos ouvir você!</p>
      </div>

      <div className={estiloSuporte.contatoGrid}>
        <div className={estiloSuporte.itemContato}>
          <span className={estiloSuporte.iconeContato}>
            <FaBug />
          </span>
          <div>
            <h3>Relatar problema</h3>
            <p>Encontrou algum bug ou erro?</p>
          </div>
          <button
            type="button"
            className={estiloSuporte.botaoContorno}
            onClick={handleRelatarProblema}
          >
            Relatar problema
          </button>
        </div>

        <div className={estiloSuporte.itemContato}>
          <span className={estiloSuporte.iconeContato}>
            <FaLightbulb />
          </span>
          <div>
            <h3>Enviar sugestão</h3>
            <p>Tem uma ideia para melhorar o Tinker?</p>
          </div>
          <button
            type="button"
            className={estiloSuporte.botaoContorno}
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
