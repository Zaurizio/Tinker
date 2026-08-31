import Skeleton from "../ui/Skeleton";
import styles from "./CardQuestao.module.css";

function CardQuestaoSkeleton() {
  return (
    <article className={styles.cardQuestao} aria-hidden="true">
      <div className={styles.cabecalho}>
        <div className={styles.metadados}>
          <Skeleton width="72px" height="0.85rem" />
          <Skeleton width="96px" height="0.85rem" />
          <Skeleton width="64px" height="0.85rem" />
          <Skeleton width="40px" height="0.85rem" />
        </div>
      </div>

      <div style={{ margin: "18px 0", display: "flex", flexDirection: "column", gap: 8 }}>
        <Skeleton height="1rem" width="100%" />
        <Skeleton height="1rem" width="92%" />
        <Skeleton height="1rem" width="55%" />
      </div>

      <div className={styles.alternativas}>
        {[0, 1, 2, 3].map((indice) => (
          <div className={styles.alternativa} key={indice}>
            <Skeleton width="18px" height="18px" radius="50%" style={{ flexShrink: 0 }} />
            <Skeleton height="0.9rem" width="70%" />
          </div>
        ))}
      </div>
    </article>
  );
}

export default CardQuestaoSkeleton;
