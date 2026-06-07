// CardDesempenhoGeral.jsx
import React from 'react';
import AcertosRing from './AcertosRing';
import styles from './CardDesempenhoGeral.module.css';

const CardDesempenhoGeral = ({ taxaAcertos = 0 }) => {
  // mensagem simples baseada na taxa
  const getMensagem = () => {
    if (taxaAcertos >= 80) return 'Excelente evolução!';
    if (taxaAcertos >= 60) return 'Bom caminho, continue!';
    if (taxaAcertos >= 40) return 'Dá pra melhorar, foco nas revisões.';
    return 'Vamos construir sua base aos poucos.';
  };

  return (
    <div className={styles.card}>
      <h3 className={styles.titulo}>Taxa geral de acertos</h3> {/* Título no topo */}

      <div className={styles.graficoContainer}> {/* Container para o gráfico */}
        <AcertosRing value={taxaAcertos} />
      </div>

      <p className={styles.mensagem}>{getMensagem()}</p> {/* Frase motivacional embaixo */}
    </div>
  );
};

export default CardDesempenhoGeral;