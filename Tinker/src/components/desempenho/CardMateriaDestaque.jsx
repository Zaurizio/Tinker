// CardMateriaDestaque.jsx
import React from 'react';
import styles from './CardMateriaDestaque.module.css';

const CardMateriaDestaque = ({ titulo, materia, taxa, corDestaque }) => {
  const getCorClara = (hex, opacity) => {
    // Função simples para converter HEX para RGBA com opacidade
    // Você pode usar uma lib como 'color' ou 'tinycolor2' para algo mais robusto
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);
    return `rgba(${r}, ${g}, ${b}, ${opacity})`;
  };

  const corFundoBlocoMateria = getCorClara(corDestaque, 0.1); // 10% de opacidade
  const corBordaBlocoMateria = getCorClara(corDestaque, 0.3); // 30% de opacidade

  return (
    <div className={styles.card}>
      <p className={styles.titulo}>{titulo}</p>
      <div className={styles.materiaContainer} style={{ backgroundColor: corFundoBlocoMateria, borderColor: corBordaBlocoMateria }}>
        <h4 className={styles.materia} style={{ color: corDestaque }}>{materia}</h4>
        <span className={styles.taxa} style={{ color: corDestaque }}>{taxa}%</span>
      </div>
    </div>
  );
};

export default CardMateriaDestaque;