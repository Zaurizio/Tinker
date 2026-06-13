import { FaUsers } from "react-icons/fa";
import estiloSuporte from "../../pages/Suporte.module.css";

const integrantes = [
  "Gustavo Zaurizio",
  "Rafael Abrahão",
  "Heitor Prieto",
  "Lucas Gabriel Matos",
];

function SecaoSobre() {
  return (
    <article className={estiloSuporte.card}>
      <div className={estiloSuporte.cabecalhoCard}>
        <h2 className={estiloSuporte.tituloCard}>Sobre o Tinker</h2>
        <p className={estiloSuporte.textoCard}>
          Plataforma de apoio a vestibulares, simulados e organização de estudos.
        </p>
      </div>

      <div className={estiloSuporte.integrantesGrid}>
        {integrantes.map((integrante) => (
          <div key={integrante} className={estiloSuporte.integrante}>
            <span className={estiloSuporte.iconeIntegrante}>
              <FaUsers />
            </span>
            <strong>{integrante}</strong>
          </div>
        ))}
      </div>
    </article>
  );
}

export default SecaoSobre;
