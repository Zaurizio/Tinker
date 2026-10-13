// CardMetrica.jsx
import React from 'react';
import styles from './CardMetrica.module.css';

const CardMetrica = ({ titulo, valor }) => {
  return (
    <div className={styles.card}>
      <p className={styles.titulo}>{titulo}</p>
      <p className={styles.valor}>{valor}</p>
    </div>
  );
};

export default CardMetrica;