import React, { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router";
import WelcomeMessage from "../components/home/WelcomeMessage";
import CardsContainer from "../components/home/CardsContainer";
import styles from "./Home.module.css";
import { obterSessao } from "../services/autenticacaoService";
import { listarEventosDoUsuario } from "../services/calendarioService";
import { abreviarParteData, interpretarDataLocal } from "../utils/dataEvento";

import { TbCalendarEvent, TbFileText } from "react-icons/tb";
import { LuFilter } from "react-icons/lu";
import { FaUsers, FaUserCircle } from "react-icons/fa";

function obterDataDoEvento(evento) {
  return evento.extendedProps?.data ?? evento.start?.slice(0, 10) ?? "";
}

function obterHorarioInicio(evento) {
  return evento.extendedProps?.horarioInicio ?? null;
}

function obterHorarioFim(evento) {
  return evento.extendedProps?.horarioFim ?? null;
}

function compararEventos(eventoA, eventoB) {
  const dataA = obterDataDoEvento(eventoA);
  const dataB = obterDataDoEvento(eventoB);
  if (dataA !== dataB) return dataA.localeCompare(dataB);
  if (eventoA.allDay !== eventoB.allDay) return eventoA.allDay ? -1 : 1;

  return (obterHorarioInicio(eventoA) ?? "").localeCompare(
    obterHorarioInicio(eventoB) ?? ""
  );
}

function eEventoPassado(evento, agora) {
  const data = interpretarDataLocal(obterDataDoEvento(evento));
  if (!data || evento.allDay) return false;

  const horarioReferencia = obterHorarioFim(evento) ?? obterHorarioInicio(evento);
  if (!horarioReferencia) return false;

  const [horas, minutos] = horarioReferencia.split(":").map(Number);
  const fimDoEvento = new Date(
    data.getFullYear(),
    data.getMonth(),
    data.getDate(),
    horas,
    minutos
  );

  return fimDoEvento < agora;
}

const Home = () => {
  const [eventos, setEventos] = useState([]);
  const userName = obterSessao()?.nome?.trim() ?? "";
  const navigate = useNavigate();

  useEffect(() => {
    let componenteMontado = true;

    async function carregarEventos() {
      try {
        const eventosCarregados = await listarEventosDoUsuario();
        if (componenteMontado) setEventos(eventosCarregados);
      } catch {
        if (componenteMontado) setEventos([]);
      }
    }

    carregarEventos();
    return () => {
      componenteMontado = false;
    };
  }, []);

  const { eventsToday, eventosDaSemana } = useMemo(() => {
    const agora = new Date();
    const inicioHoje = new Date(agora.getFullYear(), agora.getMonth(), agora.getDate());
    const meioDiaHoje = new Date(
      agora.getFullYear(),
      agora.getMonth(),
      agora.getDate(),
      12
    );
    const fimSemana = new Date(inicioHoje);
    const diasDesdeSegunda = (inicioHoje.getDay() + 6) % 7;
    fimSemana.setDate(inicioHoje.getDate() + (6 - diasDesdeSegunda));
    fimSemana.setHours(23, 59, 59, 999);

    const eventosDeHoje = eventos
      .filter((evento) => interpretarDataLocal(obterDataDoEvento(evento))?.getTime() === meioDiaHoje.getTime())
      .sort(compararEventos);

    const eventosNoPeriodo = eventos
      .filter((evento) => {
        const data = interpretarDataLocal(obterDataDoEvento(evento));
        return data && data >= inicioHoje && data <= fimSemana && !eEventoPassado(evento, agora);
      })
      .sort(compararEventos);

    return {
      eventsToday: eventosDeHoje.map((evento) => (
        evento.allDay
          ? evento.title
          : `${evento.title} às ${obterHorarioInicio(evento)}`
      )),
      eventosDaSemana: eventosNoPeriodo,
    };
  }, [eventos]);

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
            {cardsData.map((card) => (
              <CardsContainer key={card.title} {...card} />
            ))}
          </div>

          <div className={styles.bottomRow}>
            <section className={styles.cardHoje}>
              <h2 className={styles.cardHojeTitulo}>Essa semana</h2>

              {eventosDaSemana.length === 0 ? (
                <p className={styles.cardHojeEmpty}>
                  Nenhum evento marcado essa semana.
                </p>
              ) : (
                <div className={styles.listaEventosSemana}>
                  {eventosDaSemana.map((evento) => {
                    const data = interpretarDataLocal(obterDataDoEvento(evento));
                    const mes = data ? abreviarParteData(data, "month") : "---";
                    const dia = data ? String(data.getDate()).padStart(2, "0") : "--";
                    const diaSemana = data ? abreviarParteData(data, "weekday") : "---";
                    const horario = evento.allDay
                      ? "Dia inteiro"
                      : `${obterHorarioInicio(evento)} – ${obterHorarioFim(evento)}`;

                    return (
                      <article className={styles.eventoSemana} key={evento.id}>
                        <div className={styles.dataEventoSemana} aria-label={obterDataDoEvento(evento)}>
                          <span className={styles.mesEventoSemana} style={{ color: evento.color }}>{mes}</span>
                          <strong>{dia}</strong>
                          <span className={styles.diaEventoSemana} style={{ color: evento.color }}>{diaSemana}</span>
                        </div>
                        <div className={styles.informacoesEventoSemana}>
                          <h3>{evento.title}</h3>
                          <p>{horario}</p>
                        </div>
                      </article>
                    );
                  })}
                </div>
              )}
            </section>

            <section className={styles.cardResumo}>
              <h2 className={styles.cardResumoTitulo}>Resumo rápido</h2>

              <button
                type="button"
                className={styles.cardResumoInner}
                onClick={() => navigate("/desempenho")}
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
