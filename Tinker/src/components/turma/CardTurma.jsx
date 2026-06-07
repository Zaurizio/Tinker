import { MdGroups } from "react-icons/md";
import estiloCard from "./CardTurma.module.css";

function CardTurma({ turma }) {
  return (
    <div className={estiloCard.card}>
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
    </div>
  );
}

export default CardTurma;