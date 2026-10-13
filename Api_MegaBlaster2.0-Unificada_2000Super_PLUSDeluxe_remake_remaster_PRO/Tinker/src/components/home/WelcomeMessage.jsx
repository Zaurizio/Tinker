import React from "react";
import styles from "./WelcomeMessage.module.css";

const WelcomeMessage = ({ userName, eventsToday = [] }) => {
  const statusText = eventsToday.length > 0
    ? eventsToday.join(", ")
    : "Nada marcado pra hoje.";

  return (
    <div className={styles.welcomeContainer}>
      <h1 className={styles.welcomeTitle}>
        {userName ? `Olá, ${userName}!` : "Olá!"}
      </h1>

      <p className={styles.welcomeSubtitle}>
        Veja suas próximas atividades e atalhos rápidos.
      </p>

      <p className={styles.statusLine}>Hoje: {statusText}</p>
    </div>
  );
};

export default WelcomeMessage;
