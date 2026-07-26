// src/pages/Home.jsx
import React, { useState } from 'react';
import { useNavigate } from "react-router";
import WelcomeMessage from '../components/home/WelcomeMessage';
import CardsContainer from '../components/home/CardsContainer';
import styles from './Home.module.css';

import { TbCalendarEvent } from "react-icons/tb";
import { LuFilter } from "react-icons/lu";
import { TbFileText } from "react-icons/tb";
import { FaUsers, FaUserCircle } from 'react-icons/fa';

const Home = () => {
  const [userName] = useState(() => {
    const storedUser = localStorage.getItem('usuario');

    if (!storedUser) {
      return "estudante";
    }

    try {
      const userObject = JSON.parse(storedUser);
      return userObject?.nome || "estudante";
    } catch (error) {
      console.error("Erro ao parsear o objeto de usuario do localStorage:", error);
      localStorage.removeItem('usuario');
      return "estudante";
    }
  });
  const eventsToday = [];
  const navigate = useNavigate();

  const cardsData = [
    { icon: LuFilter, title: "Filtro de Questões", to: "/questoes" },
    { icon: TbFileText, title: "Simulados", to: "/simulados" },
    { icon: TbCalendarEvent, title: "Calendário", to: "/calendario" },
    { icon: FaUsers, title: "Turma", to: "/turma" },
    { icon: FaUserCircle, title: "Conta", to: "/conta" },
  ];

  return (
    <div className={styles.paginaHome}>
      <div className={styles.homeContainer}>
        <WelcomeMessage userName={userName} eventsToday={eventsToday} />

        <div className={styles.contentWrapper}>
          <div className={styles.cardsRow}>
            {cardsData.map((card, index) => (
              <CardsContainer
                key={index}
                icon={card.icon}
                title={card.title}
                to={card.to}
              />
            ))}
          </div>

          <div className={styles.bottomRow}>
            <section className={styles.cardHoje}>
              <h2 className={styles.cardHojeTitulo}>Hoje</h2>

              <p className={styles.cardHojeEmpty}>
                Nenhum evento marcado pra hoje
              </p>
            </section>

            <section className={styles.cardResumo}>
              <h2 className={styles.cardResumoTitulo}>Resumo rápido</h2>

              <button
                type="button"
                className={styles.cardResumoInner}
                onClick={() => navigate('/desempenho')}
              >
                <div className={styles.cardResumoTaxa}>
                  Taxa de acertos: <span>67%</span>
                </div>
                <div className={styles.cardResumoTexto}>
                  Clique para ver desempenho
                </div>
              </button>
            </section>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Home;
