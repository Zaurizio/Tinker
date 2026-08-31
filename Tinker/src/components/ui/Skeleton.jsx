import styles from "./Skeleton.module.css";

function Skeleton({ className = "", width, height, radius, style, ...props }) {
  return (
    <span
      className={`${styles.skeleton} ${className}`}
      style={{ width, height, borderRadius: radius, ...style }}
      aria-hidden="true"
      {...props}
    />
  );
}

export default Skeleton;
