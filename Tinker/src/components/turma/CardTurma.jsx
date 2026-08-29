import { MdGroups } from "react-icons/md";
import { Link } from "react-router";
import estiloCard from "./CardTurma.module.css";

function CardTurma({ turma }) {
  return (
    <Link
      to={`/turma/${turma.codigo}/simulados`}
      className={estiloCard.card}
      aria-label={`Abrir turma ${turma.nome}`}
    >
      <div
        className={estiloCard.imagemTurma}
        style={{ backgroundColor: turma.cor }}
      >
        {turma.imagem ? (
          <img src={turma.imagem} alt={turma.nome} />
        ) : (
          <MdGroups className={estiloCard.iconeGrupo} />
        )}
      </div>
      <div className={estiloCard.infoTurma}>
        <span className={estiloCard.nomeTurma}>{turma.nome}</span>
        <span className={estiloCard.criador}>{turma.criador}</span>
      </div>
    </Link>
  );
}

export default CardTurma;
