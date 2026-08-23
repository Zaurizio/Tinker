import { useEffect, useState, useRef } from "react";
import CardEvento from "../components/calendario/CardEvento";
import CardDetalhesEvento from "../components/calendario/CardDetalhesEvento";
import {
  criarEvento,
  excluirEvento,
  excluirSerieEventos,
  listarEventosDoUsuario,
  obterEventoPorId,
  possuiOutrasOcorrenciasDaSerie,
} from "../services/calendarioService";

/*seta esquerda*/ import { IoIosArrowBack } from "react-icons/io"; //<IoIosArrowBack />
/*seta direita*/ import { IoIosArrowForward } from "react-icons/io"; //<IoIosArrowForward />
/*mais*/ import { FaPlus } from "react-icons/fa6"; //<FaPlus />

import FullCalendar from "@fullcalendar/react";
import dayGridPlugin from "@fullcalendar/daygrid";
import interactionPlugin from "@fullcalendar/interaction";
import timeGridPlugin from "@fullcalendar/timegrid";

import estiloCalendario from "./Calendario.module.css";
import './CalendarioGlobal.css';

function Calendario() {
  const [visualizacao, setVisualizacao] = useState("dayGridMonth");
  const [dataAtual, setDataAtual] = useState(new Date());
  const [menuAberto, setMenuAberto] = useState(false);
  const [cardAberto, setCardAberto] = useState(false);
  const [animacao, setAnimacao] = useState('') /*transição*/
  const [dataVisivel, setDataVisivel] = useState(new Date())
  const calendarRef = useRef(null);
  const componenteMontadoRef = useRef(true);
  const criacaoEmAndamentoRef = useRef(false);
  const remocaoEmAndamentoRef = useRef(false);
  const requisicaoDetalhesRef = useRef(0);

  const [eventos, setEventos] = useState([]);
  const [carregandoEventos, setCarregandoEventos] = useState(true);
  const [erroEventos, setErroEventos] = useState("");
  const [salvandoEvento, setSalvandoEvento] = useState(false);
  const [erroCriacaoEvento, setErroCriacaoEvento] = useState("");
  const [eventoSelecionado, setEventoSelecionado] = useState(null);
  const [carregandoDetalhesEvento, setCarregandoDetalhesEvento] = useState(false);
  const [erroDetalhesEvento, setErroDetalhesEvento] = useState("");
  const [etapaRemocao, setEtapaRemocao] = useState("detalhes");
  const [removendoEvento, setRemovendoEvento] = useState(false);
  const [erroRemocaoEvento, setErroRemocaoEvento] = useState("");

  useEffect(() => {
    let componenteMontado = true;
    componenteMontadoRef.current = true;

    async function carregarEventos() {
      setCarregandoEventos(true);
      setErroEventos("");

      try {
        const eventosCarregados = await listarEventosDoUsuario();
        if (componenteMontado) {
          setEventos((eventosAtuais) => {
            const eventosPorId = new Map(
              eventosCarregados.map((evento) => [evento.id, evento])
            );

            eventosAtuais.forEach((evento) => eventosPorId.set(evento.id, evento));
            return Array.from(eventosPorId.values());
          });
        }
      } catch {
        if (componenteMontado) {
          setErroEventos("Não foi possível carregar os eventos. Tente novamente.");
        }
      } finally {
        if (componenteMontado) setCarregandoEventos(false);
      }
    }

    carregarEventos();
    return () => {
      componenteMontado = false;
      componenteMontadoRef.current = false;
    };
  }, []);

/*conta quantos eventos allDay tem no dia visível*/
  const qtdAllDay = eventos.filter(event => {
    if (!event.allDay) return false
    const eventoData = new Date(event.start + 'T12:00:00').toDateString()
    return eventoData === dataVisivel.toDateString()
  }).length

  const opcoes = [
    { valor: "timeGridDay", label: "Dia" },
    { valor: "timeGridWeek", label: "Semana" },
    { valor: "dayGridMonth", label: "Mês" }
  ];

  const labelVisualizacao = opcoes.find(opcao => opcao.valor === visualizacao)?.label || "Mês";
  const botaoCriarRef = useRef(null);

  function handleCriar() {
    if (carregandoEventos || erroEventos || salvandoEvento || removendoEvento) return;

    const dataLocal = new Date();
    const hoje = [
      dataLocal.getFullYear(),
      String(dataLocal.getMonth() + 1).padStart(2, "0"),
      String(dataLocal.getDate()).padStart(2, "0"),
    ].join("-");
    setErroCriacaoEvento("");
    setEventoSelecionado(null);
    setCardAberto(hoje);
  }

  async function handleAbrirEvento(info) {
    info.jsEvent?.stopPropagation();
    if (carregandoEventos || erroEventos || salvandoEvento || removendoEvento) return;

    const numeroRequisicao = requisicaoDetalhesRef.current + 1;
    requisicaoDetalhesRef.current = numeroRequisicao;
    setCardAberto(false);
    setEventoSelecionado(null);
    setEtapaRemocao("detalhes");
    setErroDetalhesEvento("");
    setErroRemocaoEvento("");
    setCarregandoDetalhesEvento(true);

    try {
      const evento = await obterEventoPorId(info.event.id);
      if (
        componenteMontadoRef.current
        && requisicaoDetalhesRef.current === numeroRequisicao
      ) setEventoSelecionado(evento);
    } catch (erro) {
      if (
        componenteMontadoRef.current
        && requisicaoDetalhesRef.current === numeroRequisicao
      ) {
        setErroDetalhesEvento(
          erro instanceof Error ? erro.message : "Não foi possível carregar o evento."
        );
      }
    } finally {
      if (
        componenteMontadoRef.current
        && requisicaoDetalhesRef.current === numeroRequisicao
      ) setCarregandoDetalhesEvento(false);
    }
  }

  function handleFecharDetalhes() {
    if (removendoEvento || carregandoDetalhesEvento) return;
    requisicaoDetalhesRef.current += 1;
    setEventoSelecionado(null);
    setErroDetalhesEvento("");
    setErroRemocaoEvento("");
    setEtapaRemocao("detalhes");
  }

  async function executarRemocao(removerSerie) {
    if (!eventoSelecionado || removendoEvento || remocaoEmAndamentoRef.current) return;

    remocaoEmAndamentoRef.current = true;
    setRemovendoEvento(true);
    setErroRemocaoEvento("");

    try {
      if (removerSerie) {
        await excluirSerieEventos(eventoSelecionado.serieId);
      } else {
        await excluirEvento(eventoSelecionado.id);
      }

      if (componenteMontadoRef.current) {
        setEventos((eventosAtuais) => eventosAtuais.filter((evento) => {
          if (removerSerie) {
            return String(evento.extendedProps?.serieId ?? "")
              !== String(eventoSelecionado.serieId);
          }
          return String(evento.id) !== String(eventoSelecionado.id);
        }));
        setEventoSelecionado(null);
        setEtapaRemocao("detalhes");
      }
    } catch (erro) {
      if (componenteMontadoRef.current) {
        setErroRemocaoEvento(
          erro instanceof Error ? erro.message : "Não foi possível remover o evento."
        );
      }
    } finally {
      remocaoEmAndamentoRef.current = false;
      if (componenteMontadoRef.current) setRemovendoEvento(false);
    }
  }

  async function handleContinuarRemocao() {
    if (!eventoSelecionado || removendoEvento) return;

    setErroRemocaoEvento("");
    setCarregandoDetalhesEvento(true);
    try {
      const possuiOutras = await possuiOutrasOcorrenciasDaSerie(eventoSelecionado.id);
      if (!componenteMontadoRef.current) return;

      if (possuiOutras) {
        setEtapaRemocao("escolhaSerie");
      } else {
        setCarregandoDetalhesEvento(false);
        await executarRemocao(false);
      }
    } catch (erro) {
      if (componenteMontadoRef.current) {
        setErroRemocaoEvento(
          erro instanceof Error ? erro.message : "Não foi possível verificar a sequência."
        );
      }
    } finally {
      if (componenteMontadoRef.current) setCarregandoDetalhesEvento(false);
    }
  }

  function handleMudarVisualizacao(novaVisualizacao) {
    setMenuAberto(false);
    if (carregandoEventos || erroEventos || !calendarRef.current) return;

    setVisualizacao(novaVisualizacao);
    calendarRef.current.getApi().changeView(novaVisualizacao);
  }

  function handleHoje() {
    if (carregandoEventos || erroEventos || !calendarRef.current) return;

    aplicarAnimacao('fc-fade-enter', () => {
      calendarRef.current.getApi().today()
    })
  }

  function handleProximo() {
    if (carregandoEventos || erroEventos || !calendarRef.current) return;

    aplicarAnimacao('fc-slide-enter', () => calendarRef.current.getApi().next())
  }

  function handleAnterior() {
    if (carregandoEventos || erroEventos || !calendarRef.current) return;

    aplicarAnimacao('fc-slide-enter-back', () => calendarRef.current.getApi().prev())
  }

  /*adiciona evento novo*/
  async function handleSalvarEvento(dadosEvento) {
    if (
      carregandoEventos
      || erroEventos
      || salvandoEvento
      || criacaoEmAndamentoRef.current
    ) return;

    criacaoEmAndamentoRef.current = true;
    setSalvandoEvento(true);
    setErroCriacaoEvento("");

    try {
      const novosEventos = await criarEvento(dadosEvento);

      if (componenteMontadoRef.current) {
        setEventos((eventosAtuais) => [...eventosAtuais, ...novosEventos]);
        setCardAberto(false);
      }
    } catch (erro) {
      if (componenteMontadoRef.current) {
        setErroCriacaoEvento(
          erro instanceof Error
            ? erro.message
            : "Não foi possível salvar o evento. Tente novamente."
        );
      }
    } finally {
      criacaoEmAndamentoRef.current = false;
      if (componenteMontadoRef.current) setSalvandoEvento(false);
    }
  }

  function handleFecharCardEvento() {
    if (salvandoEvento) return;
    setCardAberto(false);
    setErroCriacaoEvento("");
  }

/*data escrita*/
function formatarData() {
  const meses = ['Janeiro','Fevereiro','Março','Abril','Maio','Junho','Julho','Agosto','Setembro','Outubro','Novembro','Dezembro']
  const mes = meses[dataAtual.getMonth()]
  const ano = dataAtual.getFullYear()
  const dia = dataAtual.getDate()

  if (visualizacao === 'timeGridDay') {
    return `${dia} de ${mes} de ${ano}`
  }
  return `${mes} de ${ano}`
}

/*transição de pagina*/
function aplicarAnimacao(tipo, callback) {
  callback()
  setAnimacao('')
  requestAnimationFrame(() => {
    requestAnimationFrame(() => {
      setAnimacao(tipo)
    })
  })
}

  return (
    <div className={estiloCalendario.container}>
      <div className={estiloCalendario.topo}>

        {/*lado esquerdo do topo*/}
        <div className={estiloCalendario.topoEsquerda}>
          <button 
            ref={botaoCriarRef}
            className={estiloCalendario.botaoCriar}
            onClick={handleCriar}
            disabled={carregandoEventos || Boolean(erroEventos) || salvandoEvento || removendoEvento}
          >
            <FaPlus size={20}/> Marcar
          </button>

          <span className={estiloCalendario.dataGrande}>
            {formatarData()}
          </span>
        </div>

        {/*lado direito do topo*/}
        <div className={estiloCalendario.controles}>
          <button className={estiloCalendario.botaoHoje} onClick={handleHoje}>
            Hoje
          </button>

          <div className={estiloCalendario.menuVisualizacao}>
            <button
              className={estiloCalendario.botaoMenu}
              onClick={() => setMenuAberto(!menuAberto)}
            >
              {labelVisualizacao}
            </button>
            {menuAberto && (
              <div className={estiloCalendario.dropdown}>
                {opcoes.map(opcao => (
                  <button
                    key={opcao.valor}
                    className={`${estiloCalendario.opcao} ${visualizacao === opcao.valor ? estiloCalendario.ativo : ''}`}
                    onClick={() => handleMudarVisualizacao(opcao.valor)}
                  >
                    {opcao.label}
                  </button>
                ))}
              </div>
            )}
          </div>

          <button className={estiloCalendario.seta} onClick={handleAnterior}>
            <IoIosArrowBack />
          </button>
          <button className={estiloCalendario.seta} onClick={handleProximo}>
            <IoIosArrowForward />
          </button>
        </div>
      </div>


      <div className={`${estiloCalendario.calendarioContainer} ${qtdAllDay >= 2 ? 'allday-multiplo' : ''}`}>
        <div className={`${animacao} ${estiloCalendario.areaCalendario}`}>
          {carregandoEventos && (
            <p className={estiloCalendario.estadoEventos}>Carregando eventos...</p>
          )}
          {erroEventos && !carregandoEventos && (
            <p className={estiloCalendario.erroEventos} role="alert">
              {erroEventos}
            </p>
          )}
          <FullCalendar
            key="Calendar-instance"
            dateClick={(info) => {
              if (!carregandoEventos && !erroEventos && !salvandoEvento && !removendoEvento) {
                setErroCriacaoEvento("");
                setEventoSelecionado(null);
                setCardAberto(info.dateStr);
              }
            }}
            eventClick={handleAbrirEvento}
            ref={calendarRef}
            //allDaySlot={hasAllDayEvents}
            allDaySlot={true} //sempre mostra, na teoria
            datesSet={(info) => {
              setDataVisivel(info.start)
              setDataAtual(info.view.currentStart)
            }}

            plugins={[dayGridPlugin, interactionPlugin, timeGridPlugin]}
            initialView={visualizacao}
            locale="pt-br"
            events={carregandoEventos || erroEventos ? [] : eventos}
            headerToolbar={false}
            height="100%"
            allDayText=""


            /*ativa am-pm*/
            slotLabelContent={(args) => {
              const hora = args.date.getHours()
              const periodo = hora < 12 ? 'AM' : 'PM'
              const hora12 = hora % 12 === 0 ? 12 : hora % 12
              return (
                <span style={{
                  display: 'block',
                  textAlign: 'right',
                  paddingRight: '8px',
                  fontSize: '0.75rem',
                  color: 'var(--cor-texto-calendario)',
                  fontFamily: 'Poppins, sans-serif'
                }}>
                  {hora12} {periodo}
                </span>
              )
            }}


            dayHeaderContent={(args) => {
              const diaSemana = args.date.toLocaleDateString('pt-BR', { weekday: 'short' })
                .replace('.', '')
                .toUpperCase()
              const diaMes = args.date.getDate()

              if (visualizacao === 'dayGridMonth') {
                return (
                  <span style={{ fontSize: '0.7rem', color: 'var(--cor-texto-calendario)', letterSpacing: '0.5px' }}>
                    {diaSemana}
                  </span>
                )
              }

              return (
                <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '4px' }}>
                  <span style={{ fontSize: '0.7rem', color: 'var(--cor-texto-calendario)', letterSpacing: '0.5px' }}>
                    {diaSemana}
                  </span>
                  <span style={{ fontSize: '1.8rem', fontWeight: '400', color: 'var(--cor-texto-calendario-escuro)', lineHeight: 1 }}>
                    {diaMes}
                  </span>
                </div>
              )
            }}


            eventContent={(arg) => {
              const view = arg.view.type;
              const start = arg.event.start;
              const end = arg.event.end;
              const allDay = arg.event.allDay;
              const eventColor = arg.event.backgroundColor || arg.event.borderColor || '#2f5d8a'; // Pega a cor do evento ou um padrão

              function formatHora(date) {
                if (!date) return '';
                const h = date.getHours();
                const m = date.getMinutes();
                const periodo = h >= 12 ? 'pm' : 'am';
                const h12 = h % 12 === 0 ? 12 : h % 12;
                const minutos = m > 0 ? `:${String(m).padStart(2, '0')}` : '';
                return `${h12}${minutos}${periodo}`;
              }

              if (view === 'dayGridMonth') {
                return (
                  <div
                    className="conteudo-evento-calendario"
                    style={{ display: 'flex', alignItems: 'center', gap: 4, padding: '0 4px', overflow: 'hidden', color: 'var(--cor-texto-claro)' }}
                  >
                    {/* Bolinha colorida */}
                    <span
                      style={{
                        display: 'inline-block',
                        width: '8px',
                        height: '8px',
                        borderRadius: '50%',
                        backgroundColor: eventColor,
                        flexShrink: 0, // Garante que a bolinha não encolha
                      }}
                    />
                    {!allDay && (
                      <span style={{ fontSize: '0.75rem', fontWeight: 500, whiteSpace: 'nowrap' }}>
                        {formatHora(start)}
                      </span>
                    )}
                    <span style={{ fontSize: '0.8rem', fontWeight: 600, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                      {arg.event.title}
                    </span>
                  </div>
                );
              }

              if (view === 'timeGridWeek' || view === 'timeGridDay') {
                return (
                  <div
                    className="conteudo-evento-calendario"
                    style={{ padding: '2px 4px', overflow: 'hidden', color: 'var(--cor-texto-claro)' }}
                  >
                    {!allDay && (
                      <div style={{ fontSize: '0.75rem', fontWeight: 500, whiteSpace: 'nowrap' }}>
                        {formatHora(start)} – {formatHora(end)}
                      </div>
                    )}
                    <div style={{ fontSize: '0.85rem', fontWeight: 600, overflow: 'hidden', textOverflow: 'ellipsis' }}>
                      {arg.event.title}
                    </div>
                  </div>
                );
              }

              return null;
            }}
          />
        </div>

        {cardAberto && (
          <CardEvento
            dataSelecionada={cardAberto}
            onFechar={handleFecharCardEvento}
            onSalvar={handleSalvarEvento}
            anchorRef={botaoCriarRef}
            salvando={salvandoEvento}
            erro={erroCriacaoEvento}
          />
        )}
        {(carregandoDetalhesEvento || erroDetalhesEvento || eventoSelecionado) && (
          <CardDetalhesEvento
            evento={eventoSelecionado}
            etapa={etapaRemocao}
            carregando={carregandoDetalhesEvento}
            erroDetalhes={erroDetalhesEvento}
            removendo={removendoEvento}
            erroRemocao={erroRemocaoEvento}
            onFechar={handleFecharDetalhes}
            onRemover={() => {
              setErroRemocaoEvento("");
              setEtapaRemocao("confirmacao");
            }}
            onContinuar={handleContinuarRemocao}
            onRemoverOcorrencia={() => executarRemocao(false)}
            onRemoverSerie={() => executarRemocao(true)}
          />
        )}
      </div>
    </div>
  );
}

export default Calendario;
