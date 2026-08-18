import { useState, useRef } from "react";
import CardEvento from "../components/calendario/CardEvento";

/*seta esquerda*/ import { IoIosArrowBack } from "react-icons/io"; //<IoIosArrowBack />
/*seta direita*/ import { IoIosArrowForward } from "react-icons/io"; //<IoIosArrowForward />
/*mais*/ import { FaPlus } from "react-icons/fa6"; //<FaPlus />

import FullCalendar from "@fullcalendar/react";
import dayGridPlugin from "@fullcalendar/daygrid";
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

  const [eventos, setEventos] = useState([
    //{ title: "Prova de Matemática", start: "2026-05-03", allDay: true},
    //{ title: "Prova de fisica", start: "2026-05-03", allDay: true}
  ]);

  /*ve se tem evento allday nos dias mostrados*/
  const hasAllDayEvents = eventos.some(event => {
    if (!event.allDay) return false
    const eventoData = new Date(event.start + 'T12:00:00').toDateString()
    return eventoData === dataVisivel.toDateString()
  })

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
    const hoje = new Date().toISOString().split('T')[0];
    setCardAberto(hoje);
  }

  function handleMudarVisualizacao(novaVisualizacao) {
    setVisualizacao(novaVisualizacao);
    setMenuAberto(false);
    if (calendarRef.current) {
        calendarRef.current.getApi().changeView(novaVisualizacao);
    }
  }

  function handleHoje() {
    aplicarAnimacao('fc-fade-enter', () => {
      calendarRef.current.getApi().today()
    })
  }

  function handleProximo() {
    aplicarAnimacao('fc-slide-enter', () => calendarRef.current.getApi().next())
  }

  function handleAnterior() {
    aplicarAnimacao('fc-slide-enter-back', () => calendarRef.current.getApi().prev())
  }

  /*adiciona evento novo*/
  function handleSalvarEvento(novosEventos) {
    //const eventos = gerarEventos(novoEvento);
    setEventos(prev => [...prev, ...novosEventos]);
  }

  /*gera o mesmo evento em vários dias*/
  function gerarEventos(evento) {
    const { title, date, horaInicio, horaFim, recorrencia } = evento;
    const lista = [];
    const dataInicio = new Date(date + 'T12:00:00');

    // quantas repetições e como avançar a data
    const config = {
        'Não se repete':  { total: 1 },
        'Todos os dias':  { total: 365, avancar: (d) => d.setDate(d.getDate() + 1) },
        'Semanal':        { total: 52,  avancar: (d) => d.setDate(d.getDate() + 7) },
        'Mensal':         { total: 12,  avancar: (d) => d.setMonth(d.getMonth() + 1) },
        'Anual':          { total: 5,   avancar: (d) => d.setFullYear(d.getFullYear() + 1) },
    };

    const { total, avancar } = config[recorrencia] || config['Não se repete'];
    const dataAtual = new Date(dataInicio);

    for (let i = 0; i < total; i++) {
        const dataStr = dataAtual.toISOString().split('T')[0];
        lista.push({ title, date: dataStr, horaInicio, horaFim });
        if (avancar) avancar(dataAtual);
    }

    return lista;
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
        <div className={animacao} style={{ height: '100%' }}>
          <FullCalendar
            key="Calendar-instance"
            dateClick={(info) => setCardAberto(info.dateStr)}
            ref={calendarRef}
            //allDaySlot={hasAllDayEvents}
            allDaySlot={true} //sempre mostra, na teoria
            datesSet={(info) => {
              setDataVisivel(info.start)
              setDataAtual(info.view.currentStart)
            }}

            plugins={[dayGridPlugin, timeGridPlugin]}
            initialView={visualizacao}
            locale="pt-br"
            events={eventos}
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
                  <div style={{ display: 'flex', alignItems: 'center', gap: 4, padding: '0 4px', overflow: 'hidden', color: 'var(--cor-texto-claro)' }}>
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
                  <div style={{ padding: '2px 4px', overflow: 'hidden', color: 'var(--cor-texto-claro)' }}>
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
            onFechar={() => setCardAberto(false)}
            onSalvar={handleSalvarEvento}
            anchorRef={botaoCriarRef}
          />
        )}
      </div>
    </div>
  );
}

export default Calendario;
