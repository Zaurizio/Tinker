import { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router";
import WelcomeMessage from "../components/home/WelcomeMessage";
import CardsContainer from "../components/home/CardsContainer";
import Skeleton from "../components/ui/Skeleton";
import styles from "./Home.module.css";
import { obterSessao } from "../services/autenticacaoService";
import { listarEventosDoCalendario } from "../services/calendarioApiService";
import { obterResumoDesempenho } from "../services/desempenhoService";
import { abreviarParteData, interpretarDataLocal } from "../utils/dataEvento";
import { obterCache, definirCache } from "../services/cacheStore";
import { CHAVE_EVENTOS, CHAVE_DESEMPENHO } from "../services/cacheChaves";
import { useEsqueletoAtrasado } from "../hooks/useEsqueletoAtrasado";

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

function EventosSemanaSkeleton() {
  return (
    <div className={styles.listaEventosSemana} aria-hidden="true">
      {[0, 1, 2].map((indice) => (
        <article className={styles.eventoSemana} key={indice}>
          <div className={styles.dataEventoSemana}>
            <Skeleton width="26px" height="0.65rem" />
            <Skeleton width="22px" height="1.3rem" style={{ margin: "4px 0" }} />
            <Skeleton width="30px" height="0.65rem" />
          </div>
          <div className={styles.informacoesEventoSemana} style={{ flex: 1 }}>
            <Skeleton height="0.98rem" width="70%" style={{ marginBottom: 6 }} />
            <Skeleton height="0.85rem" width="45%" />
          </div>
        </article>
      ))}
    </div>
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
  const [eventos, setEventos] = useState(() => obterCache(CHAVE_EVENTOS) ?? []);
  const [carregandoEventos, setCarregandoEventos] = useState(
    () => obterCache(CHAVE_EVENTOS) === undefined,
  );
  const [erroEventos, setErroEventos] = useState("");
  const [resumoDesempenho, setResumoDesempenho] = useState(
    () => obterCache(CHAVE_DESEMPENHO) ?? null,
  );
  const [carregandoDesempenho, setCarregandoDesempenho] = useState(
    () => obterCache(CHAVE_DESEMPENHO) === undefined,
  );
  const [erroDesempenho, setErroDesempenho] = useState("");
  const userName = obterSessao()?.nome?.trim() ?? "";
  const navigate = useNavigate();
  const mostrarEsqueletoEventos = useEsqueletoAtrasado(carregandoEventos);
  const mostrarEsqueletoDesempenho = useEsqueletoAtrasado(carregandoDesempenho);

  useEffect(() => {
    let componenteMontado = true;

    async function carregarEventos() {
      const eventosEmCache = obterCache(CHAVE_EVENTOS);
      setCarregandoEventos(eventosEmCache === undefined);
      setErroEventos("");

      try {
        const eventosCarregados = await listarEventosDoCalendario();
        if (componenteMontado) {
          setEventos(eventosCarregados);
          definirCache(CHAVE_EVENTOS, eventosCarregados);
        }
      } catch (erroCarregamento) {
        if (componenteMontado && eventosEmCache === undefined) {
          setErroEventos(
            erroCarregamento instanceof Error
              ? `${erroCarregamento.message}${erroCarregamento.codigo ? ` (${erroCarregamento.codigo})` : ""}`
              : "Não foi possível carregar os eventos.",
          );
        }
      } finally {
        if (componenteMontado) setCarregandoEventos(false);
      }
    }

    async function carregarDesempenho() {
      const desempenhoEmCache = obterCache(CHAVE_DESEMPENHO);
      setCarregandoDesempenho(desempenhoEmCache === undefined);
      setErroDesempenho("");

      try {
        const resumo = await obterResumoDesempenho();
        if (componenteMontado) {
          setResumoDesempenho(resumo);
          definirCache(CHAVE_DESEMPENHO, resumo);
        }
      } catch (erroCarregamento) {
        if (componenteMontado && desempenhoEmCache === undefined) {
          setErroDesempenho(
            erroCarregamento instanceof Error
              ? `${erroCarregamento.message}${erroCarregamento.codigo ? ` (${erroCarregamento.codigo})` : ""}`
              : "Não foi possível carregar o desempenho.",
          );
        }
      } finally {
        if (componenteMontado) setCarregandoDesempenho(false);
      }
    }

    carregarEventos();
    carregarDesempenho();
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

              {carregandoEventos ? (
                mostrarEsqueletoEventos ? <EventosSemanaSkeleton /> : null
              ) : erroEventos ? (
                <p className={styles.cardHojeEmpty} role="alert">
                  {erroEventos}
                </p>
              ) : eventosDaSemana.length === 0 ? (
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
                  {carregandoDesempenho ? (
                    mostrarEsqueletoDesempenho ? <Skeleton height="1.1rem" width="65%" /> : null
                  ) : erroDesempenho ? (
                    <span role="alert">{erroDesempenho}</span>
                  ) : resumoDesempenho?.possuiRespostas ? (
                    <>
                      Taxa de acertos:{" "}
                      <span>{resumoDesempenho.taxaAcertosGeral}%</span>
                    </>
                  ) : (
                    "Nenhuma questão respondida"
                  )}
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
