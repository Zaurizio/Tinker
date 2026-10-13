// src/components/CardsContainer.jsx
import React from 'react';
import { Link } from 'react-router-dom'; // Supondo que você use React Router para navegação
import styles from './CardsContainer.module.css'; // Importa o CSS Module

const CardsContainer = ({ icon: IconComponent, title, to }) => {
  return (
    <Link to={to} className={styles.cardLink}>
      <div className={styles.card}>
        {IconComponent && <IconComponent className={styles.cardIcon} />}
        <h2 className={styles.cardTitle}>{title}</h2>
      </div>
    </Link>
  );
};

export default CardsContainer;