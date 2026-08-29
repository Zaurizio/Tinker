import estiloCard from "./CardSimuladoTurma.module.css";

function CardSimuladoTurma({ simulado, usuarioAdministrador, onRemover }) {
  const textoQuestoes = `${simulado.quantidadeQuestoes} ${
    simulado.quantidadeQuestoes === 1 ? "questão" : "questões"
  }`;

  return (
    <article className={estiloCard.card}>
      <div className={estiloCard.conteudo}>
        <h3 className={estiloCard.titulo}>{simulado.titulo}</h3>
        {simulado.descricao && (
          <p className={estiloCard.descricao}>{simulado.descricao}</p>
        )}
        <div className={estiloCard.informacoes}>
          <span>Publicado em {simulado.dataPublicacaoFormatada}</span>
          <span aria-hidden="true">•</span>
          <span>{textoQuestoes}</span>
        </div>
      </div>

      {usuarioAdministrador && (
        <div className={estiloCard.acao}>
          <button type="button" onClick={onRemover}>
            Retirar da turma
          </button>
        </div>
      )}
    </article>
  );
}

export default CardSimuladoTurma;
