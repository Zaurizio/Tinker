import { useCallback, useEffect, useRef, useState } from "react";
import { buscarOpcoesFiltrosQuestoes } from "../services/questoesService";
import { obterCache, definirCache } from "../services/cacheStore";
import { CHAVE_FILTROS_QUESTOES } from "../services/cacheChaves";

const OPCOES_VAZIAS = { disciplinas: [], vestibulares: [], anos: [] };

export function useOpcoesFiltrosQuestoes(ativo = true) {
  const cacheInicial = obterCache(CHAVE_FILTROS_QUESTOES);
  const [opcoes, setOpcoes] = useState(() => cacheInicial ?? OPCOES_VAZIAS);
  const [carregando, setCarregando] = useState(() => ativo && cacheInicial === undefined);
  const [erro, setErro] = useState(null);
  const [tentativa, setTentativa] = useState(0);
  const idCarregamentoRef = useRef(0);

  useEffect(() => {
    if (!ativo) {
      idCarregamentoRef.current += 1;
      return undefined;
    }

    idCarregamentoRef.current += 1;
    const idCarregamento = idCarregamentoRef.current;

    async function carregarOpcoes() {
      const emCache = obterCache(CHAVE_FILTROS_QUESTOES);
      setCarregando(emCache === undefined);

      try {
        const resposta = await buscarOpcoesFiltrosQuestoes();
        if (idCarregamento !== idCarregamentoRef.current) return;

        const opcoesCarregadas = {
          disciplinas: Array.isArray(resposta?.disciplinas)
            ? resposta.disciplinas
            : [],
          vestibulares: Array.isArray(resposta?.vestibulares)
            ? resposta.vestibulares
            : [],
          anos: Array.isArray(resposta?.anos) ? resposta.anos : [],
        };
        setErro(null);
        setOpcoes(opcoesCarregadas);
        definirCache(CHAVE_FILTROS_QUESTOES, opcoesCarregadas);
      } catch (erroCarregar) {
        if (idCarregamento !== idCarregamentoRef.current) return;
        if (emCache === undefined) {
          setOpcoes(OPCOES_VAZIAS);
          setErro(erroCarregar);
        }
      } finally {
        if (idCarregamento === idCarregamentoRef.current) setCarregando(false);
      }
    }

    carregarOpcoes();

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
