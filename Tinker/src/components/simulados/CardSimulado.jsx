import styles from "./CardSimulado.module.css";

function CardSimulado({ simulado, onAbrir, onRenomear, onExcluir }) {
  function abrirSimulado() {
    onAbrir(simulado);
  }

  function handleKeyDown(event) {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      abrirSimulado();
    }
  }

  function executarSemAbrir(event, acao) {
    event.stopPropagation();
    acao(simulado);
  }

  return (
    <article className={styles.cardSimulado}>
      <div
        className={styles.conteudo}
        role="button"
        tabIndex={0}
        aria-label={`Abrir simulado ${simulado.titulo}`}
        onClick={abrirSimulado}
        onKeyDown={handleKeyDown}
      >
        <h3 className={styles.titulo}>{simulado.titulo}</h3>
        {simulado.descricao && (
          <p className={styles.descricao}>{simulado.descricao}</p>
        )}
        <p className={styles.metadados}>
          {simulado.quantidadeQuestoes} questões
          {simulado.tempo !== null && ` · ${simulado.tempo} min`}
        </p>
      </div>

      <div className={styles.acoes}>
        <button
          type="button"
          className={styles.botaoRenomear}
          onClick={(event) => executarSemAbrir(event, onRenomear)}
        >
          Renomear
        </button>
        <button
          type="button"
          className={styles.botaoExcluir}
          onClick={(event) => executarSemAbrir(event, onExcluir)}
        >
          Excluir
        </button>
      </div>
    </article>
  );
}

export default CardSimulado;
