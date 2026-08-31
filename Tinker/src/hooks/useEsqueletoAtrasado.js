import { useEffect, useState } from "react";

const ATRASO_PADRAO_MS = 200;

export function useEsqueletoAtrasado(estaCarregando, atrasoMs = ATRASO_PADRAO_MS) {
  const [liberado, setLiberado] = useState(false);

  useEffect(() => {
    if (!estaCarregando) return undefined;

    const temporizador = setTimeout(() => setLiberado(true), atrasoMs);
    return () => {
      clearTimeout(temporizador);
      setLiberado(false);
    };
  }, [estaCarregando, atrasoMs]);

  return estaCarregando && liberado;
}
