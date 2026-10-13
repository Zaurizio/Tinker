import { useEffect, useRef, useState } from "react";
import estiloCard from "./CardEventoTurma.module.css";
import {
  abreviarParteData,
  formatarHorarioEvento,
  interpretarDataLocal,
} from "../../utils/dataEvento";

function CardEventoTurma({ evento, onAdicionar }) {
  const [adicionando, setAdicionando] = useState(false);
  const [erro, setErro] = useState("");
  const adicaoEmAndamentoRef = useRef(false);
  const componenteMontadoRef = useRef(true);
  const data = interpretarDataLocal(evento.data);
  const mes = data ? abreviarParteData(data, "month") : "---";
  const dia = data ? String(data.getDate()).padStart(2, "0") : "--";
  const diaSemana = data ? abreviarParteData(data, "weekday") : "---";
  const corEvento = { color: evento.cor };

  useEffect(() => {
    componenteMontadoRef.current = true;

    return () => {
      componenteMontadoRef.current = false;
    };
  }, []);

  async function handleAdicionar() {
    if (evento.salvoPeloUsuario || adicaoEmAndamentoRef.current) return;

    adicaoEmAndamentoRef.current = true;
    setAdicionando(true);
    setErro("");

    try {
      await onAdicionar(evento.idPublicacao);
    } catch (erroAdicao) {
      if (!componenteMontadoRef.current) return;

      setErro(
        erroAdicao instanceof Error
          ? erroAdicao.message
          : "Não foi possível adicionar o evento."
      );
    } finally {
      adicaoEmAndamentoRef.current = false;
      if (componenteMontadoRef.current) setAdicionando(false);
    }
  }

  return (
    <article className={estiloCard.card}>
      <div className={estiloCard.data} aria-label={evento.data}>
        <span className={estiloCard.mes} style={corEvento}>{mes}</span>
        <strong>{dia}</strong>
        <span className={estiloCard.diaSemana} style={corEvento}>{diaSemana}</span>
      </div>

      <div className={estiloCard.informacoes}>
        <h3>{evento.titulo}</h3>
        <p>{formatarHorarioEvento(evento)}</p>
      </div>

      <div className={estiloCard.acao}>
        <button
          type="button"
          onClick={handleAdicionar}
          disabled={evento.salvoPeloUsuario || adicionando}
        >
          {adicionando
            ? "Adicionando..."
            : evento.salvoPeloUsuario
              ? "Salvo"
              : "Adicionar evento"}
        </button>
        {erro && (
          <span className={estiloCard.erro} role="alert">
            {erro}
          </span>
        )}
      </div>
    </article>
  );
}

export default CardEventoTurma;
