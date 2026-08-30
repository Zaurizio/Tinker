import { FaUsers } from "react-icons/fa";
import estiloConta from "../../pages/Conta.module.css";

const integrantes = [
  "Gustavo Zaurizio",
  "Rafael Abrahão",
  "Heitor Prieto",
  "Lucas Gabriel Matos",
];

function SecaoSobre() {
  return (
    <article className={estiloConta.card}>
      <div className={estiloConta.cabecalhoCard}>
        <h2 className={estiloConta.tituloCard}>Sobre o Tinker</h2>
        <p className={estiloConta.textoCard}>
          Plataforma de apoio a vestibulares, simulados e organização de estudos.
        </p>
      </div>

      <div className={estiloConta.integrantesGrid}>
        {integrantes.map((integrante) => (
          <div key={integrante} className={estiloConta.integrante}>
            <span className={estiloConta.iconeIntegrante}>
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
