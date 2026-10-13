import estiloCard from "./Card.module.css";

function Card({ children, className = "" }) {
  return (
  <div className={`${estiloCard.card} ${className}`}>
    {children}
  </div>
  );
}

export default Card;
