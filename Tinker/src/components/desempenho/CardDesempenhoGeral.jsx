import AcertosRing from "./AcertosRing";
import styles from "./CardDesempenhoGeral.module.css";

function CardDesempenhoGeral({ taxaAcertos = 0, mensagem = "" }) {
  return (
    <div className={styles.card}>
      <h3 className={styles.titulo}>Taxa geral de acertos</h3>

      <div className={styles.graficoContainer}>
        <AcertosRing value={taxaAcertos} />
      </div>

      <p className={styles.mensagem}>{mensagem}</p>
    </div>
  );
}

export default CardDesempenhoGeral;
