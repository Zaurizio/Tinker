import { Link } from "react-router";
import estiloCard from "./CardSimuladoTurma.module.css";

function CardSimuladoTurma({
  codigo,
  simulado,
  usuarioAdministrador,
  usuarioAluno,
  onRemover,
}) {
  const textoQuestoes = `${simulado.quantidadeQuestoes} ${
    simulado.quantidadeQuestoes === 1 ? "questão" : "questões"
  }`;
  const destino = `/turma/${codigo}/simulados/${encodeURIComponent(simulado.idPublicacao)}`;
  const concluido = usuarioAluno && simulado.concluido;

  const conteudo = (
    <article
      className={`${estiloCard.card} ${concluido ? estiloCard.cardConcluido : ""}`}
    >
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

  if (!usuarioAluno) return conteudo;

  return (
    <Link
      to={destino}
      state={{ publicacao: simulado }}
      className={estiloCard.linkCard}
      aria-label={`Abrir simulado ${simulado.titulo}`}
    >
      {conteudo}
    </Link>
  );
}

export default CardSimuladoTurma;
