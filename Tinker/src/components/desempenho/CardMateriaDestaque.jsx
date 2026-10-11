import styles from './CardMateriaDestaque.module.css';

const CardMateriaDestaque = ({
  titulo,
  materia,
  taxa,
  corDestaque,
  corFundoDestaque,
  corBordaDestaque,
}) => {
  return (
    <div className={styles.card}>
      <p className={styles.titulo}>{titulo}</p>
      <div
        className={styles.materiaContainer}
        style={{
          backgroundColor: corFundoDestaque,
          borderColor: corBordaDestaque,
        }}
      >
        <h4 className={styles.materia} style={{ color: corDestaque }}>
          {materia}
        </h4>
        {taxa !== null && (
          <span className={styles.taxa} style={{ color: corDestaque }}>
            {taxa}%
          </span>
        )}
      </div>
    </div>
  );
};

export default CardMateriaDestaque;
