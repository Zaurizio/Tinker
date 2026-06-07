// src/components/WelcomeMessage.jsx
import React from 'react';
import styles from './WelcomeMessage.module.css'; // Importa o CSS Module

const WelcomeMessage = ({ userName, eventsToday = [] }) => {

  // monta a parte depois de "Hoje: ..."
  const statusText =
    eventsToday.length > 0
      ? eventsToday.join(' · ')
      : 'nada marcado pra hoje';

  return (
    <div className={styles.welcomeContainer}>
      <h1 className={styles.welcomeTitle}>
        Olá, {userName || 'estudante'}!
      </h1>

      <p className={styles.welcomeSubtitle}>
        Veja suas próximas atividades e atalhos rápidos.
      </p>

      <p className={styles.statusLine}>
        Hoje: {statusText}
      </p>
    </div>
  );
};

export default WelcomeMessage;