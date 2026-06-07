// src/pages/Home.jsx
import React, { useState, useEffect } from 'react';
import { useNavigate } from "react-router";
import WelcomeMessage from '../components/home/WelcomeMessage';
import CardsContainer from '../components/home/CardsContainer';
import styles from './Home.module.css'; // Importa o CSS Module


/*calendario*/ import { TbCalendarEvent } from "react-icons/tb"; //<TbCalendarEvent />
import { LuFilter } from "react-icons/lu";
import { TbFileText } from "react-icons/tb";
import { FaUsers, FaUserCircle } from 'react-icons/fa';


const Home = () => {
  const [userName, setUserName] = useState("estudante"); //estado pra nome do usuario
  //const [allEvents, setAllEvents] = useState([]); // Todos os eventos
  const [eventsToday, setEventsToday] = useState([]); //estado pros eventos de hoje
  const navigate = useNavigate();

  useEffect(() => {
    // Tenta carregar o objeto de usuário do localStorage
    const storedUser = localStorage.getItem('usuario');
    if (storedUser) {
      try {
        const userObject = JSON.parse(storedUser);
        // Verifica se o objeto de usuário tem a propriedade 'nome'
        if (userObject && userObject.nome) {
          setUserName(userObject.nome);
        }
      } catch (error) {
        console.error("Erro ao parsear o objeto de usuário do localStorage:", error);
        // Opcional: Limpar item inválido do localStorage
        localStorage.removeItem('usuario');
      }
    }
  }, []); // O array vazio garante que isso rode apenas uma vez ao montar

  const cardsData = [
    { icon: LuFilter, title: "Filtro de Questões", to: "/questoes" },
    { icon: TbFileText, title: "Simulados", to: "/simulados" },
    { icon: TbCalendarEvent, title: "Calendário", to: "/calendario" },
    { icon: FaUsers, title: "Turma", to: "/turma" },
    { icon: FaUserCircle, title: "Conta", to: "/conta" },
  ];

  return (
    <div className={styles.paginaHome}>
      <div className={styles.HomeContainer}>
        <WelcomeMessage userName={userName} eventsToday={eventsToday} /> {/*n tem nada em events today pq não salva eventos, só marca*/}

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

          {/* Linha com "Hoje" e "Resumo rápido" */}
          <div className={styles.bottomRow}>
            {/* Bloco Hoje (maior) */}
            <section className={styles.cardHoje}>
              <h2 className={styles.cardHojeTitulo}>Hoje</h2>

              {/* aqui depois você coloca a lógica dos eventos */}
              <p className={styles.cardHojeEmpty}>
                Nenhum evento marcado pra hoje
              </p>
            </section>

            {/* Bloco Resumo rápido (menor) */}
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