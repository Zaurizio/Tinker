import Skeleton from "../ui/Skeleton";
import estiloCard from "./CardSimuladoTurma.module.css";

function CardSimuladoTurmaSkeleton() {
  return (
    <article className={estiloCard.card} aria-hidden="true">
      <div className={estiloCard.conteudo}>
        <Skeleton height="1.05rem" width="65%" />
        <div className={estiloCard.informacoes}>
          <Skeleton height="0.84rem" width="55%" />
        </div>
      </div>
    </article>
  );
}

export default CardSimuladoTurmaSkeleton;
