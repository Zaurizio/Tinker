import Skeleton from "../ui/Skeleton";
import estiloCard from "./CardTurma.module.css";

function CardTurmaSkeleton() {
  return (
    <div className={estiloCard.card} aria-hidden="true">
      <Skeleton width="52px" height="52px" radius="50%" style={{ flexShrink: 0 }} />
      <div className={estiloCard.infoTurma}>
        <Skeleton height="1.05rem" width="140px" />
        <Skeleton height="0.85rem" width="100px" />
      </div>
    </div>
  );
}

export default CardTurmaSkeleton;
