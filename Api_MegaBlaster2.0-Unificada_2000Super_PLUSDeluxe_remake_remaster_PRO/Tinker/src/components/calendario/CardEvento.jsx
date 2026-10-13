import { useState, useRef, useEffect } from 'react';
/*seta baixo*/ import { IoIosArrowDown } from "react-icons/io"; //<IoIosArrowDown />
import Checkbox from "@mui/material/Checkbox";
import MiniCalendario from './MiniCalendario';
import InputHora from './InputHora';
import estilos from './CardEvento.module.css';

function formatarDataLocal(data) {
  return [
    data.getFullYear(),
    String(data.getMonth() + 1).padStart(2, '0'),
    String(data.getDate()).padStart(2, '0'),
  ].join('-');
}

function calcularHorarioInicial(dataSelecionada) {
  const agora = new Date();
  const hoje = formatarDataLocal(agora);
  const proximaHora = agora.getHours() + 1;

  if (dataSelecionada === hoje && proximaHora >= 23) {
    const amanha = new Date(
      agora.getFullYear(),
      agora.getMonth(),
      agora.getDate() + 1,
    );

    return {
      data: formatarDataLocal(amanha),
      inicio: '00:00',
      fim: '01:00',
    };
  }

  const inicio = proximaHora >= 23 ? 0 : proximaHora;
  return {
    data: dataSelecionada,
    inicio: `${String(inicio).padStart(2, '0')}:00`,
    fim: `${String(inicio + 1).padStart(2, '0')}:00`,
  };
}

export default function CardEvento({
  onFechar,
  onSalvar,
  dataSelecionada,
  anchorRef,
  salvando,
  erro,
}) {
/*onfechar: fecha card, onSalvar: salva evento, dataSelecionada: data navegador, anchorRef: botao evento*/
    const [valoresIniciais] = useState(() => calcularHorarioInicial(dataSelecionada));
    const cardRef = useRef(null); /*onde fica o card*/
    const botaoDataRef = useRef(null); /*onde fica o botão de data*/
    /*estados*/
    const [miniCalAberto, setMiniCalAberto] = useState(false); /*minicalendario fechado*/
    const [dataAtual, setDataAtual] = useState(valoresIniciais.data); /*data que ta no botão*/
    const [recorrenciaAberta, setRecorrenciaAberta] = useState(false); /*botão frequencia fechado*/
    const [recorrencia, setRecorrencia] = useState('Não se repete'); /*guarda frequencia selecionada*/
    const [nomeEvento, setNomeEvento] = useState(''); /*nome do evento*/
    const [corEvento, setCorEvento] = useState('#2f5d8a');
    const [seletorCorAberto, setSeletorCorAberto] = useState(false);
    const [diaInteiro, setDiaInteiro] = useState(false);
    const [horarioInicioValido, setHorarioInicioValido] = useState(true);
    const [horarioFimValido, setHorarioFimValido] = useState(true);
    const [erroHorario, setErroHorario] = useState('');

    const cores = ['#2f5d8a','#8e44ad','#d35400','#2c3e50','#2894F6','#e74c3c','#f39c12', '#16a085'];

    const opcoesRecorrencia = [
    'Não se repete',
    'Todos os dias',
    'Semanal',
    'Mensal'
    ];

/*estados com h definidos*/
const [horaInicio, setHoraInicio] = useState(valoresIniciais.inicio);
const [horaFim, setHoraFim] = useState(valoresIniciais.fim);

/*data escrita*/
function formatarData() {
  const diasSemana = ['Domingo','Segunda','Terça','Quarta','Quinta','Sexta','Sábado']
  const meses = ['Janeiro','Fevereiro','Março','Abril','Maio','Junho','Julho','Agosto','Setembro','Outubro','Novembro','Dezembro']

  const data = new Date(dataAtual + 'T12:00:00')
  const diaSemana = diasSemana[data.getDay()]
  const dia = data.getDate()
  const mes = meses[data.getMonth()]

  return `${diaSemana}, ${dia} de ${mes}`
}

/*salva evento*/
function handleSalvar() {
    if (salvando) return;
    if (!diaInteiro && (!horarioInicioValido || !horarioFimValido)) {
      setErroHorario('Corrija os horários inválidos antes de salvar.');
      return;
    }

    setErroHorario('');

    onSalvar({
      titulo: nomeEvento,
      data: dataAtual,
      horarioInicio: horaInicio,
      horarioFim: horaFim,
      diaInteiro,
      recorrencia,
      cor: corEvento,
    });
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
        if (!salvando) onFechar();
        }
    }
    document.addEventListener('mousedown', handleClickFora);
    return () => document.removeEventListener('mousedown', handleClickFora);
}, [onFechar, salvando]);

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
            disabled={salvando}
          />
        </div>

        {/*linha 2*/}
        <div className={estilos.linha}>
            <button 
                ref={botaoDataRef}
                className={estilos.botaoData}
                onClick={() => setMiniCalAberto(!miniCalAberto)} /*inverte true e false*/
                disabled={salvando}
            >
                {formatarData()}
            </button>
            <div
              className={`${estilos.horarios} ${diaInteiro ? estilos.horariosOcultos : ''}`}
              aria-hidden={diaInteiro}
            >
                    <InputHora
                      value={horaInicio}
                      onChange={setHoraInicio}
                      onValidityChange={(valido) => {
                        setHorarioInicioValido(valido);
                        setErroHorario('');
                      }}
                      disabled={salvando || diaInteiro}
                    />
                    <span style={{ color: "var(--cor-texto-principal)" }}>—</span>
                    <InputHora
                      value={horaFim}
                      onChange={setHoraFim}
                      onValidityChange={(valido) => {
                        setHorarioFimValido(valido);
                        setErroHorario('');
                      }}
                      disabled={salvando || diaInteiro}
                    />
            </div>
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
                disabled={salvando}
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
                        disabled={salvando}
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
                disabled={salvando}
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
                    disabled={salvando}
                />
                ))}
            </div>
            )}
        </div>

        <label className={estilos.labelCheck}>
            <Checkbox
              checked={diaInteiro}
              onChange={(e) => {
                const marcado = e.target.checked;
                setDiaInteiro(marcado);
                if (marcado) setErroHorario('');
              }}
              className={estilos.checkboxCustom}
              disableRipple
              disabled={salvando}
            />
            Dia inteiro
        </label>
    </div>


        <div className={estilos.areaMensagem} aria-live="polite">
          {(erroHorario || erro) && (
            <p className={estilos.mensagemErro} role="alert">{erroHorario || erro}</p>
          )}
        </div>

        {/*rodapé*/}
        <div className={estilos.rodape}>
          <button className={estilos.botaoSecundario} onClick={onFechar} disabled={salvando}>Cancelar</button>
          <button className={estilos.botaoPrimario} onClick={handleSalvar} disabled={salvando}>
            {salvando ? "Salvando..." : "Salvar"}
          </button>
        </div>

      </div>
    </div>
  );
}
