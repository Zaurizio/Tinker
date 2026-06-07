// src/components/desempenho/AcertosRing.jsx
import React, { useState, useEffect } from 'react';
import {
  CircularProgressbar,
  buildStyles,
} from 'react-circular-progressbar';
import 'react-circular-progressbar/dist/styles.css';

const AcertosRing = ({ value = 0, animationDuration = 800 }) => { // Adicionamos animationDuration como prop
  const [displayValue, setDisplayValue] = useState(0);

  useEffect(() => {
    // Se o valor final for 0, não anima, apenas mostra 0
    if (value === 0) {
      setDisplayValue(0);
      return;
    }

    let start = 0;
    const end = value;
    const increment = end / (animationDuration / 16); // Aproximadamente 60fps (1000ms / 16ms)

    const timer = setInterval(() => {
      start += increment;
      if (start >= end) {
        start = end;
        clearInterval(timer);
      }
      setDisplayValue(Math.round(start)); // Arredonda para não ter números decimais
    }, 16); // A cada 16ms (aproximadamente 60fps)

    return () => clearInterval(timer); // Limpa o timer quando o componente desmonta ou o valor muda
  }, [value, animationDuration]); // Roda a animação sempre que 'value' ou 'animationDuration' mudar

  return (
    <div style={{ width: 120, height: 120 }}>
      <CircularProgressbar
        value={displayValue} // Usamos o valor animado aqui
        text={`${displayValue}%`}
        strokeWidth={10}
        styles={buildStyles({
          trailColor: '#e6edf7',
          pathColor: '#2F5D8A',
          textColor: '#142033',
          textSize: '20px',
          strokeLinecap: 'round',
          transition: 'stroke-dashoffset 0.5s ease 0s', // Transição suave para o preenchimento do círculo
        })}
      />
    </div>
  );
};

export default AcertosRing;