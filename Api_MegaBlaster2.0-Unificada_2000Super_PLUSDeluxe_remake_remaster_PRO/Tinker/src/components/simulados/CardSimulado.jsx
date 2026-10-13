import styles from "./CardSimulado.module.css";

function CardSimulado({ simulado, onAbrir, onRenomear, onExcluir }) {
  const concluido = Boolean(simulado.concluido);

  function abrirSimulado() {
    if (concluido) return;
    onAbrir(simulado);
  }

  function handleKeyDown(event) {
    if (concluido) return;
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
    <article
      className={`${styles.cardSimulado} ${
        concluido ? styles.cardConcluido : ""
      }`}
    >
      <div
        className={`${styles.conteudo} ${
          concluido ? styles.conteudoDesabilitado : ""
        }`}
        role={concluido ? undefined : "button"}
        tabIndex={concluido ? undefined : 0}
        aria-label={concluido ? undefined : `Abrir simulado ${simulado.titulo}`}
        onClick={concluido ? undefined : abrirSimulado}
        onKeyDown={concluido ? undefined : handleKeyDown}
      >
        <h3 className={styles.titulo}>{simulado.titulo}</h3>
        {simulado.descricao && (
          <p className={styles.descricao}>{simulado.descricao}</p>
        )}
        <p className={styles.metadados}>
          {simulado.quantidadeQuestoes} questões
          {simulado.tempo !== null && ` · ${simulado.tempo} min`}
        </p>
        {concluido && (
          <span className={styles.seloConcluido}>
            Concluído
            {simulado.acertos !== null && ` · ${simulado.acertos} acertos`}
          </span>
        )}
      </div>

      <div className={styles.acoes}>
        {concluido && (
          <button
            type="button"
            className={styles.botaoRecomecar}
            onClick={(event) => executarSemAbrir(event, onAbrir)}
          >
            Recomeçar
          </button>
        )}
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
