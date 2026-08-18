import styles from "./CardQuestao.module.css";

export default function CardQuestao({ questao }) {
  return (
    <article className={styles.cardQuestao}>
      <div className={styles.cabecalho}>
        <span>{questao.disciplina}</span>
        <span>{questao.ano}</span>
      </div>

      <p className={styles.enunciado}>
        {questao.enunciado}
      </p>

      <div className={styles.alternativas}>
        {questao.alternativas.map((alternativa) => (
          <label key={alternativa.id}>
            <input
              type="radio"
              name={`questao-${questao.id}`}
              value={alternativa.id}
            />

            <span>{alternativa.texto}</span>
          </label>
        ))}
      </div>
    </article>
  );
}