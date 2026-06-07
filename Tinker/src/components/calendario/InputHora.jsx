import { useState, useRef, useEffect } from 'react';
import estilos from './InputHora.module.css';

function gerarHorarios() {
  const lista = [];
  for (let h = 0; h < 24; h++) {
    for (let m = 0; m < 60; m += 15) {
      const hora = String(h).padStart(2, '0'); 
      const min = String(m).padStart(2, '0');
      /*numero vira texto e garante 2 casas*/
      lista.push(`${hora}:${min}`); /*string*/
    }
  }
  return lista;
}
const horarios = gerarHorarios();

/*tenta achar padrão*/
function interpretarHora(texto) {
  const limpo = texto.trim().toLowerCase().replace(/\s/g, ''); /*remove espaços e minusculas*/

  //com dois pontos (HH:MM)
  const comDoisPontos = limpo.match(/(\d{1,2}):(\d{2})/);
  if (comDoisPontos) {
    const h = parseInt(comDoisPontos[1]); /*texto hora*/
    const m = parseInt(comDoisPontos[2]); /*texto minuto*/
    if (h >= 0 && h <= 23 && m >= 0 && m <= 59) {
      return `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`;
    }
    return null;
  }

  //se nao tiver dois pontos, pega os 4 primeiros numeros
  const soNumeros = limpo.match(/(\d{1,4})/);
  if (soNumeros) {
    const n = soNumeros[1];
    let h, m;
    /*08:00*/
    if (n.length <= 2) {
      h = parseInt(n);
      m = 0;
    /*08:30*/
    } else if (n.length === 3) {
      h = parseInt(n[0]);
      m = parseInt(n.slice(1));
    /*18:30*/
    } else {
      h = parseInt(n.slice(0, 2));
      m = parseInt(n.slice(2));
    }
    if (h >= 0 && h <= 23 && m >= 0 && m <= 59) {
      return `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`;
    }
    return null;
  }

  return null;
}

export default function InputHora({ value, onChange }) {
    /*value: hora inicial, onChange: muda hora (setHora)*/
    const [texto, setTexto] = useState(value || ''); /*guarda o que tá no input*/
    const [listaAberta, setListaAberta] = useState(false); /*lista de horarios fechada*/
    const [invalido, setInvalido] = useState(false); /*aviso de hora inválida*/
    const inputRef = useRef(null); /*onde ta o input*/
    const listaRef = useRef(null); /*onde ta a div da lista*/
    const containerRef = useRef(null); /*onde ta o container*/
    const ultimoValido = useRef(value || ''); /*guarda último valor válido*/

  /*rola até o horário selecionado quando abre a div*/
  useEffect(() => {
    if (listaAberta && listaRef.current && value) {
      const idx = horarios.indexOf(value);
      if (idx !== -1) {
        const item = listaRef.current.children[idx];
        if (item) item.scrollIntoView({ block: 'center' });
      }
    }
  }, [listaAberta, value]);

  /*?*/
  useEffect(() => {
    function handleClickFora(e) {
      if (containerRef.current && !containerRef.current.contains(e.target)) {
        setListaAberta(false);
        setInvalido(false);
      }
    }
    document.addEventListener('mousedown', handleClickFora);
    return () => document.removeEventListener('mousedown', handleClickFora);
  }, []);

    /*quando clica no input de hora*/
    function handleFocus() {
        setListaAberta(true); /*abre lista*/
        setInvalido(false); /*limpa erro anterior*/
    }

    /*quando digita no input de hora*/
    function handleChange(e) {
        setTexto(e.target.value); /*atualiza texto do input*/
        setInvalido(false); /*limpa erro (novo texto)*/
    }

    /*quando sai do campo*/
    function handleBlur() {
        if (texto === '') {
            const ultValorVal = ultimoValido.current;
            setTexto(ultValorVal); /*deixa texto no input*/
            onChange(ultValorVal); /*atualiza horário pro cardeventos*/
            setInvalido(false);
            return;
        }
        const interpretado = interpretarHora(texto);
        if (interpretado) {
            setTexto(interpretado); /*deixa texto no input*/
            onChange(interpretado); /*atualiza horário pro cardEventos*/
            ultimoValido.current = interpretado;
            setInvalido(false);
        } else {
            setInvalido(true);
        }
    }

    /*quando da enter chama blur*/
    function handleKeyDown(e) {
        if (e.key === 'Enter') {
        handleBlur();
    }
    }

    /*quando clica num item da lista*/
    function handleSelecionar(horario) {
        setTexto(horario);
        onChange(horario);
        ultimoValido.current = horario;
        setListaAberta(false);
        setInvalido(false);
    }

  return (
    <div className={estilos.container} ref={containerRef} data-inputhora>
      <div className={`${estilos.inputWrapper} ${invalido ? estilos.inputInvalido : ''}`}>
        <input
          ref={inputRef}
          className={estilos.input}
          value={texto}
          onChange={handleChange}
          onFocus={handleFocus}
          onBlur={handleBlur}
          onKeyDown={handleKeyDown}
        />
        {invalido && (
          <span className={estilos.tooltip}>Hora inválida</span>
        )}
      </div>

      {listaAberta && (
        <div className={estilos.dropdown} ref={listaRef}>
          {horarios.map(h => (
            <button
              key={h}
              className={`${estilos.item} ${value === h ? estilos.itemAtivo : ''}`}
              onMouseDown={(e) => {
                e.preventDefault(); // evita blur antes do click
                e.stopPropagation();
                handleSelecionar(h);
              }}
            >
              {h}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}