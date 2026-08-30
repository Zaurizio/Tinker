import { useCallback, useEffect, useRef, useState } from "react";
import { buscarOpcoesFiltrosQuestoes } from "../services/questoesService";

const OPCOES_VAZIAS = { disciplinas: [], vestibulares: [], anos: [] };

export function useOpcoesFiltrosQuestoes(ativo = true) {
  const [opcoes, setOpcoes] = useState(OPCOES_VAZIAS);
  const [carregando, setCarregando] = useState(ativo);
  const [erro, setErro] = useState(null);
  const [tentativa, setTentativa] = useState(0);
  const idCarregamentoRef = useRef(0);

  useEffect(() => {
    if (!ativo) {
      idCarregamentoRef.current += 1;
      return;
    }

    idCarregamentoRef.current += 1;
    const idCarregamento = idCarregamentoRef.current;

    buscarOpcoesFiltrosQuestoes()
      .then((resposta) => {
        if (idCarregamento !== idCarregamentoRef.current) return;
        setErro(null);
        setOpcoes({
          disciplinas: Array.isArray(resposta?.disciplinas)
            ? resposta.disciplinas
            : [],
          vestibulares: Array.isArray(resposta?.vestibulares)
            ? resposta.vestibulares
            : [],
          anos: Array.isArray(resposta?.anos) ? resposta.anos : [],
        });
      })
      .catch((erroCarregar) => {
        if (idCarregamento !== idCarregamentoRef.current) return;
        setOpcoes(OPCOES_VAZIAS);
        setErro(erroCarregar);
      })
      .finally(() => {
        if (idCarregamento === idCarregamentoRef.current) setCarregando(false);
      });

    return () => {
      idCarregamentoRef.current += 1;
    };
  }, [ativo, tentativa]);

  const recarregar = useCallback(() => {
    setCarregando(true);
    setErro(null);
    setTentativa((valorAtual) => valorAtual + 1);
  }, []);

  if (!ativo) {
    return { ...OPCOES_VAZIAS, carregando: false, erro: null, recarregar };
  }

  return { ...opcoes, carregando, erro, recarregar };
}
