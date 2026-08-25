import { useEffect, useRef, useState } from "react";
import estiloCard from "./CardSimuladoTurma.module.css";

function formatarData(dataPublicacao) {
  const data = new Date(`${dataPublicacao}T12:00:00`);

  if (Number.isNaN(data.getTime())) return dataPublicacao;

  return new Intl.DateTimeFormat("pt-BR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  }).format(data);
}

function CardSimuladoTurma({ simulado, onAdicionar }) {
  const [salvando, setSalvando] = useState(false);
  const [erro, setErro] = useState("");
  const salvamentoEmAndamentoRef = useRef(false);
  const componenteMontadoRef = useRef(true);
  const textoQuestoes = `${simulado.quantidadeQuestoes} ${
    simulado.quantidadeQuestoes === 1 ? "questão" : "questões"
  }`;

  useEffect(() => {
    componenteMontadoRef.current = true;

    return () => {
      componenteMontadoRef.current = false;
    };
  }, []);

  async function handleAdicionar() {
    if (simulado.salvoPeloUsuario || salvamentoEmAndamentoRef.current) return;

    salvamentoEmAndamentoRef.current = true;
    setSalvando(true);
    setErro("");

    try {
      await onAdicionar(simulado.idPublicacao);
    } catch (erroSalvamento) {
      if (!componenteMontadoRef.current) return;

      setErro(
        erroSalvamento instanceof Error
          ? erroSalvamento.message
          : "Não foi possível adicionar o simulado."
      );
    } finally {
      salvamentoEmAndamentoRef.current = false;
      if (componenteMontadoRef.current) setSalvando(false);
    }
  }

  return (
    <article className={estiloCard.card}>
      <div className={estiloCard.conteudo}>
        <h3 className={estiloCard.titulo}>{simulado.titulo}</h3>
        <div className={estiloCard.informacoes}>
          <span>Publicado em {formatarData(simulado.dataPublicacao)}</span>
          <span aria-hidden="true">•</span>
          <span>{textoQuestoes}</span>
        </div>
      </div>

      <div className={estiloCard.acao}>
        <button
          type="button"
          onClick={handleAdicionar}
          disabled={simulado.salvoPeloUsuario || salvando}
        >
          {salvando
            ? "Salvando..."
            : simulado.salvoPeloUsuario
              ? "Salvo"
              : "Adicionar a Meus Simulados"}
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

export default CardSimuladoTurma;
