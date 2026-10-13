import Skeleton from "../ui/Skeleton";
import styles from "./CardSimulado.module.css";

function CardSimuladoSkeleton() {
  return (
    <article className={styles.cardSimulado} aria-hidden="true">
      <div className={styles.conteudo}>
        <Skeleton height="1.05rem" width="55%" />
        <Skeleton height="0.82rem" width="35%" />
      </div>
      <div className={styles.acoes}>
        <Skeleton width="88px" height="34px" radius="9px" />
        <Skeleton width="78px" height="34px" radius="9px" />
      </div>
    </article>
  );
}

export default CardSimuladoSkeleton;
