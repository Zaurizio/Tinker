import { useState, useRef, useEffect } from 'react';
import estilos from './MiniCalendario.module.css';

export default function MiniCalendario({ dataSelecionada, onSelecionar, onFechar, anchorRef }) {
  const hoje = new Date();
  const [mes, setMes] = useState(new Date(dataSelecionada + 'T12:00:00'));
  const ref = useRef(null);

  useEffect(() => {
    if (anchorRef?.current && ref.current) {
      const rect = anchorRef.current.getBoundingClientRect();
      ref.current.style.top = `${rect.bottom + 6}px`;
      ref.current.style.left = `${rect.left}px`;
    }
  }, [anchorRef]);

  useEffect(() => {
    function handleClickFora(e) {
      if (ref.current && !ref.current.contains(e.target) &&
          anchorRef?.current && !anchorRef.current.contains(e.target)) {
        onFechar();
      }
    }
    document.addEventListener('mousedown', handleClickFora);
    return () => document.removeEventListener('mousedown', handleClickFora);
  }, [anchorRef, onFechar]);

  function diasDoMes() {
    const ano = mes.getFullYear();
    const mesIdx = mes.getMonth();
    const primeiroDia = new Date(ano, mesIdx, 1).getDay();
    const totalDias = new Date(ano, mesIdx + 1, 0).getDate();
    const diasMesAnterior = new Date(ano, mesIdx, 0).getDate();

    const dias = [];

    // dias do mês anterior
    for (let i = primeiroDia - 1; i >= 0; i--) {
      dias.push({ dia: diasMesAnterior - i, mesAtual: false });
    }

    // dias do mês atual
    for (let i = 1; i <= totalDias; i++) {
      dias.push({ dia: i, mesAtual: true });
    }

    // dias do próximo mês pra completar a grade
    const restante = 42 - dias.length;
    for (let i = 1; i <= restante; i++) {
      dias.push({ dia: i, mesAtual: false });
    }

    return dias;
  }

  function handleDia(dia, mesAtual) {
    if (!mesAtual) return;
    const ano = mes.getFullYear();
    const mesIdx = String(mes.getMonth() + 1).padStart(2, '0');
    const diaStr = String(dia).padStart(2, '0');
    onSelecionar(`${ano}-${mesIdx}-${diaStr}`);
    onFechar();
  }

  function ehHoje(dia, mesAtual) {
    if (!mesAtual) return false;
    return (
      dia === hoje.getDate() &&
      mes.getMonth() === hoje.getMonth() &&
      mes.getFullYear() === hoje.getFullYear()
    );
  }

  function ehSelecionado(dia, mesAtual) {
    if (!mesAtual) return false;
    const ano = mes.getFullYear();
    const mesIdx = String(mes.getMonth() + 1).padStart(2, '0');
    const diaStr = String(dia).padStart(2, '0');
    return `${ano}-${mesIdx}-${diaStr}` === dataSelecionada;
  }

  const nomeMes = mes.toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' });
  const semana = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

  return (
    <div className={estilos.mini} ref={ref}>
      <div className={estilos.cabecalho}>
        <span className={estilos.nomeMes}>{nomeMes}</span>
        <div className={estilos.setas}>
          <button onClick={() => setMes(new Date(mes.getFullYear(), mes.getMonth() - 1, 1))}>‹</button>
          <button onClick={() => setMes(new Date(mes.getFullYear(), mes.getMonth() + 1, 1))}>›</button>
        </div>
      </div>

      <div className={estilos.grade}>
        {semana.map((s, i) => (
          <span key={i} className={estilos.labelSemana}>{s}</span>
        ))}
        {diasDoMes().map((item, i) => (
          <button
            key={i}
            className={`
              ${estilos.dia}
              ${!item.mesAtual ? estilos.diaForaMes : ''}
              ${ehHoje(item.dia, item.mesAtual) ? estilos.hoje : ''}
              ${ehSelecionado(item.dia, item.mesAtual) ? estilos.selecionado : ''}
            `}
            onClick={() => handleDia(item.dia, item.mesAtual)}
          >
            {item.dia}
          </button>
        ))}
      </div>
    </div>
  );
}
