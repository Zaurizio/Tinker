import { useState, useRef, useEffect } from 'react';
/*seta baixo*/ import { IoIosArrowDown } from "react-icons/io"; //<IoIosArrowDown />
import Checkbox from "@mui/material/Checkbox";
import MiniCalendario from './MiniCalendario';
import InputHora from './InputHora';
import estilos from './CardEvento.module.css';

export default function CardEvento({ onFechar, onSalvar, dataSelecionada, anchorRef }) {
/*onfechar: fecha card, onSalvar: salva evento, dataSelecionada: data navegador, anchorRef: botao evento*/
    const cardRef = useRef(null); /*onde fica o card*/
    const botaoDataRef = useRef(null); /*onde fica o botÃ£o de data*/
    /*estados*/
    const [miniCalAberto, setMiniCalAberto] = useState(false); /*minicalendario fechado*/
    const [dataAtual, setDataAtual] = useState(dataSelecionada); /*data que ta no botÃ£o*/
    const [recorrenciaAberta, setRecorrenciaAberta] = useState(false); /*botÃ£o frequencia fechado*/
    const [recorrencia, setRecorrencia] = useState('NÃ£o se repete'); /*guarda frequencia selecionada*/
    const [nomeEvento, setNomeEvento] = useState(''); /*nome do evento*/
    const [corEvento, setCorEvento] = useState('#2f5d8a');
    const [seletorCorAberto, setSeletorCorAberto] = useState(false);
    const [diaInteiro, setDiaInteiro] = useState(false);

    const cores = ['#2f5d8a','#8e44ad','#d35400','#2c3e50','#2894F6','#e74c3c','#f39c12', '#16a085'];

    const opcoesRecorrencia = [
    'NÃ£o se repete',
    'Todos os dias',
    'Semanal',
    'Mensal',
    'Anual'
    ];

function proximaHora() {
  const agora = new Date();
  const h = agora.getHours() + 1; /*hora atual + 1*/
  return `${String(h > 23 ? 0 : h).padStart(2, '0')}:00`; /*nÃ£o retorna 24h e garante dois dÃ­gitos*/
}

const inicioDefault = proximaHora(); /*h botao 1*/
const fimDefault = `${String((parseInt(inicioDefault) + 1) > 23 ? 0 : parseInt(inicioDefault) + 1).padStart(2, '0')}:00`; /*h botao 2*/

/*estados com h definidos*/
const [horaInicio, setHoraInicio] = useState(inicioDefault);
const [horaFim, setHoraFim] = useState(fimDefault);

/*data escrita*/
function formatarData() {
  const diasSemana = ['Domingo','Segunda','TerÃ§a','Quarta','Quinta','Sexta','SÃ¡bado']
  const meses = ['Janeiro','Fevereiro','MarÃ§o','Abril','Maio','Junho','Julho','Agosto','Setembro','Outubro','Novembro','Dezembro']

  const data = new Date(dataAtual + 'T12:00:00')
  const diaSemana = diasSemana[data.getDay()]
  const dia = data.getDate()
  const mes = meses[data.getMonth()]

  return `${diaSemana}, ${dia} de ${mes}`
}

/*salva evento*/
function handleSalvar() {
    if (!nomeEvento.trim()) return;

    const eventos = [];
    const dataBase = new Date(dataAtual + 'T12:00:00');

    const config = {
        'NÃ£o se repete': { total: 1 },
        'Todos os dias': { total: 365, avancar: (d) => d.setDate(d.getDate() + 1) },
        'Semanal':       { total: 52,  avancar: (d) => d.setDate(d.getDate() + 7) },
        'Mensal':        { total: 12,  avancar: (d) => d.setMonth(d.getMonth() + 1) },
        'Anual':         { total: 5,   avancar: (d) => d.setFullYear(d.getFullYear() + 1) },
    };

    const { total, avancar } = config[recorrencia] || config['NÃ£o se repete'];
    const dataLoop = new Date(dataBase);

    for (let i = 0; i < total; i++) {
        const dateStr = dataLoop.toISOString().split('T')[0];
        eventos.push({
            title: nomeEvento,
            start: diaInteiro ? dateStr : `${dateStr}T${horaInicio}:00`,
            end: diaInteiro ? dateStr : `${dateStr}T${horaFim}:00`,
            color: corEvento,
            allDay: diaInteiro,
        });
        if (avancar) avancar(dataLoop);
    }

    onSalvar(eventos);
    onFechar();
}
    
/*?*/
useEffect(() => {
    if (anchorRef?.current && cardRef.current) {
      const rect = anchorRef.current.getBoundingClientRect();
      cardRef.current.style.top = `${rect.bottom + 8}px`;
      cardRef.current.style.left = `${rect.left}px`;
    }
}, [anchorRef]);

/*fecha se clicar fora do card*/
useEffect(() => {
    function handleClickFora(e) {
        const dentroDoCard = cardRef.current && cardRef.current.contains(e.target);
        const dentroDeInputHora = e.target.closest('[data-inputhora]');
        if (!dentroDoCard && !dentroDeInputHora) {
        onFechar();
        }
    }
    document.addEventListener('mousedown', handleClickFora);
    return () => document.removeEventListener('mousedown', handleClickFora);
}, [onFechar]);

  return (
    <div className={estilos.overlay}> {/*div que ve clique na tela*/}
      <div className={estilos.card} ref={cardRef}>

        {/*linha 1*/}
        <div className={estilos.linha}>
          <input
            className={estilos.inputEvento}
            placeholder="Nome do Evento"
            value={nomeEvento}
            onChange={(e) => setNomeEvento(e.target.value)}
          />
        </div>

        {/*linha 2*/}
        <div className={estilos.linha}>
            <button 
                ref={botaoDataRef}
                className={estilos.botaoData}
                onClick={() => setMiniCalAberto(!miniCalAberto)} /*inverte true e false*/
            >
                {formatarData()}
            </button>
            {!diaInteiro && (
                <>
                    <InputHora value={horaInicio} onChange={setHoraInicio} />
                    <span style={{ color: "var(--cor-texto-principal)" }}>—</span>
                    <InputHora value={horaFim} onChange={setHoraFim} />
                </>
            )}
        </div>

        {miniCalAberto && (
        <MiniCalendario
            dataSelecionada={dataAtual}
            onSelecionar={(novaData) => setDataAtual(novaData)}
            onFechar={() => setMiniCalAberto(false)}
            anchorRef={botaoDataRef}
        />
        )}

        {/*linha 3*/}
        <div className={estilos.linha}>
            <div className={estilos.menuOpcao}>
                <button
                className={estilos.botaoOpcao}
                onClick={() => setRecorrenciaAberta(!recorrenciaAberta)}
                >
                {recorrencia}
                <IoIosArrowDown size={12} color="var(--cor-texto-principal)" />
                </button>
                {recorrenciaAberta && (
                <div className={estilos.dropdownOpcao}>
                    {opcoesRecorrencia.map(op => (
                    <button
                        key={op}
                        className={`${estilos.itemOpcao} ${recorrencia === op ? estilos.itemAtivo : ''}`}
                        onClick={() => { setRecorrencia(op); setRecorrenciaAberta(false); }}
                    >
                        {op}
                    </button>
                    ))}
                </div>
                )}
            </div>

            <div className={estilos.menuOpcao}>
            <button
                className={estilos.botaoCor}
                onClick={() => setSeletorCorAberto(!seletorCorAberto)}
                >
                <span className={estilos.circuloCor} style={{ backgroundColor: corEvento }} />
                <IoIosArrowDown size={12} color="var(--cor-texto-principal)" />
            </button>
            {seletorCorAberto && (
            <div className={estilos.dropdownCor}>
                {cores.map(c => (
                <button
                    key={c}
                    className={estilos.bolinhaOpcao}
                    style={{ backgroundColor: c, outline: c === corEvento ? '2px solid var(--cor-texto-principal)' : 'none' }}
                    onClick={() => { setCorEvento(c); setSeletorCorAberto(false); }}
                />
                ))}
            </div>
            )}
        </div>

        <label className={estilos.labelCheck}>
            <Checkbox
              checked={diaInteiro}
              onChange={(e) => setDiaInteiro(e.target.checked)}
              className={estilos.checkboxCustom}
              disableRipple
            />
            Dia inteiro
        </label>
    </div>


        {/*rodapÃ©*/}
        <div className={estilos.rodape}>
          <button className={estilos.botaoSecundario} onClick={onFechar}>Cancelar</button>
          <button className={estilos.botaoPrimario} onClick={handleSalvar}>Salvar</button>
        </div>

      </div>
    </div>
  );
}
