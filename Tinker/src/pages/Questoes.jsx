import { useEffect, useRef, useState } from "react";
import estiloQuest from "./Questoes.module.css";
import PainelBuscaQuestoes from "../components/questoes/PainelBuscaQuestoes";
import CardQuestao from "../components/questoes/CardQuestao";
import CardQuestaoSkeleton from "../components/questoes/CardQuestaoSkeleton";
import {
  buscarQuestoes,
  responderQuestao,
} from "../services/questoesService";
import {
  adicionarQuestoesAoSimuladoDaConta,
  carregarSimuladosDaContaComQuestoes,
  removerQuestaoDoSimuladoDaConta,
} from "../services/simuladosApiService";
import { obterSessao } from "../services/autenticacaoService";
import { useOpcoesFiltrosQuestoes } from "../hooks/useOpcoesFiltrosQuestoes";
import { obterCache, definirCache } from "../services/cacheStore";
import { CHAVE_SIMULADOS_COM_QUESTOES } from "../services/cacheChaves";
import { useEsqueletoAtrasado } from "../hooks/useEsqueletoAtrasado";

const TAMANHO_LOTE = 10;

function construirAssociacoesPorQuestao(simulados) {
  const associacoes = {};

  simulados.forEach((simulado) => {
    (simulado.questoesIds ?? []).forEach((questaoId) => {
      associacoes[questaoId] = [
        ...(associacoes[questaoId] ?? []),
        simulado.id,
      ];
    });
  });

  return associacoes;
}

function Questoes() {
  const [resultados, setResultados] = useState(null); //busca por questoes
  const [simulados, setSimulados] = useState(
    () => obterCache(CHAVE_SIMULADOS_COM_QUESTOES) ?? [],
  );
  const tipoUsuario = String(obterSessao()?.tipoUsuario ?? "").toUpperCase();
  const podeAdministrarSimulados = ["ALUNO", "PROFESSOR"].includes(tipoUsuario);
  const [carregandoSimulados, setCarregandoSimulados] = useState(
    () => podeAdministrarSimulados && obterCache(CHAVE_SIMULADOS_COM_QUESTOES) === undefined,
  );
  const [erroSimulados, setErroSimulados] = useState("");
  const [versaoBusca, setVersaoBusca] = useState(0);
  const [simuladosPorQuestao, setSimuladosPorQuestao] = useState(() =>
    construirAssociacoesPorQuestao(obterCache(CHAVE_SIMULADOS_COM_QUESTOES) ?? []),
  );
  const [filtrosDaBusca, setFiltrosDaBusca] = useState(null);
  const [paginaAtual, setPaginaAtual] = useState(0);
  const [temMais, setTemMais] = useState(false);
  const [carregando, setCarregando] = useState(false);
  const [erro, setErro] = useState("");
  const buscaAtivaRef = useRef(0);
  const {
    disciplinas: disciplinasFiltros,
    vestibulares: vestibularesFiltros,
    anos: anosFiltros,
    carregando: carregandoOpcoesFiltros,
    erro: erroOpcoesFiltros,
    recarregar: recarregarOpcoesFiltros,
  } = useOpcoesFiltrosQuestoes();
  const opcoesFiltros = {
    disciplinas: disciplinasFiltros,
    vestibulares: vestibularesFiltros,
    anos: anosFiltros,
  };
  const mostrarEsqueletoBusca = useEsqueletoAtrasado(
    carregando && resultados !== null && resultados.length === 0,
  );

  useEffect(() => {
    let carregamentoAtivo = true;

    async function carregarSimulados() {
      if (!podeAdministrarSimulados) {
        setSimulados([]);
        setSimuladosPorQuestao({});
        setCarregandoSimulados(false);
        return;
      }

      const emCache = obterCache(CHAVE_SIMULADOS_COM_QUESTOES);
      setCarregandoSimulados(emCache === undefined);
      setErroSimulados("");

      try {
        const simuladosDoUsuario =
          await carregarSimuladosDaContaComQuestoes();

        if (carregamentoAtivo) {
          setSimulados(simuladosDoUsuario);
          setSimuladosPorQuestao(
            construirAssociacoesPorQuestao(simuladosDoUsuario),
          );
          definirCache(CHAVE_SIMULADOS_COM_QUESTOES, simuladosDoUsuario);
        }
      } catch {
        if (carregamentoAtivo && emCache === undefined) {
          setErroSimulados("Não foi possível carregar os simulados.");
        }
      } finally {
        if (carregamentoAtivo) {
          setCarregandoSimulados(false);
        }
      }
    }

    carregarSimulados();

    return () => {
      carregamentoAtivo = false;
    };
  }, [podeAdministrarSimulados]);

  async function handleBuscarQuestoes(filtros) {
    buscaAtivaRef.current += 1;
    const idBusca = buscaAtivaRef.current;
    const copiaFiltros = {
      ...filtros,
      disciplinas: [...filtros.disciplinas],
      conteudos: [...filtros.conteudos],
      instituicoes: [...filtros.instituicoes],
      anos: [...filtros.anos],
    };

    setFiltrosDaBusca(copiaFiltros);
    setResultados([]);
    setPaginaAtual(0);
    setTemMais(false);
    setErro("");
    setVersaoBusca((versaoAtual) => versaoAtual + 1);
    setCarregando(true);

    try {
      const resultadoBusca = await buscarQuestoes(copiaFiltros, {
        pagina: 0,
        tamanho: TAMANHO_LOTE,
      });

      if (idBusca !== buscaAtivaRef.current) return;

      setResultados(resultadoBusca.itens);
      setTemMais(resultadoBusca.temMais);
    } catch {
      if (idBusca !== buscaAtivaRef.current) return;

      setErro("Não foi possível buscar as questões. Tente novamente.");
    } finally {
      if (idBusca === buscaAtivaRef.current) {
        setCarregando(false);
      }
    }
  }

  async function handleCarregarMais() {
    if (!filtrosDaBusca || carregando) return;

    const idBusca = buscaAtivaRef.current;
    const proximaPagina = paginaAtual + 1;
    setErro("");
    setCarregando(true);

    try {
      const resultadoBusca = await buscarQuestoes(filtrosDaBusca, {
        pagina: proximaPagina,
        tamanho: TAMANHO_LOTE,
      });

      if (idBusca !== buscaAtivaRef.current) return;

      setResultados((resultadosAtuais) => [
        ...resultadosAtuais,
        ...resultadoBusca.itens,
      ]);
      setPaginaAtual(proximaPagina);
      setTemMais(resultadoBusca.temMais);
    } catch {
      if (idBusca !== buscaAtivaRef.current) return;

      setErro("Não foi possível carregar mais questões. Tente novamente.");
    } finally {
      if (idBusca === buscaAtivaRef.current) {
        setCarregando(false);
      }
    }
  }

  async function handleSalvarSimulados(questaoId, simuladosIds) {
    const selecaoAnterior = new Set(simuladosPorQuestao[questaoId] ?? []);
    const novaSelecao = new Set(simuladosIds);
    const adicionados = simuladosIds.filter(
      (simuladoId) => !selecaoAnterior.has(simuladoId),
    );
    const removidos = [...selecaoAnterior].filter(
      (simuladoId) => !novaSelecao.has(simuladoId),
    );

    if (adicionados.length === 0 && removidos.length === 0) {
      return [...selecaoAnterior];
    }

    const resultados = await Promise.allSettled([
      ...adicionados.map((simuladoId) =>
        adicionarQuestoesAoSimuladoDaConta(simuladoId, [questaoId]),
      ),
      ...removidos.map((simuladoId) =>
        removerQuestaoDoSimuladoDaConta(simuladoId, questaoId),
      ),
    ]);
    const falha = resultados.find(
      (resultado) => resultado.status === "rejected",
    );

    if (falha) {
      const erroOperacao =
        falha.reason instanceof Error
          ? falha.reason
          : new Error("Não foi possível salvar. Tente novamente.");

      try {
        const simuladosSincronizados =
          await carregarSimuladosDaContaComQuestoes();
        const associacoesSincronizadas =
          construirAssociacoesPorQuestao(simuladosSincronizados);
        setSimulados(simuladosSincronizados);
        setSimuladosPorQuestao(associacoesSincronizadas);
        definirCache(CHAVE_SIMULADOS_COM_QUESTOES, simuladosSincronizados);
        setErroSimulados("");
        erroOperacao.simuladosIdsSincronizados =
          associacoesSincronizadas[questaoId] ?? [];
      } catch {
        setErroSimulados("Não foi possível sincronizar os simulados.");
      }

      throw erroOperacao;
    }

    setSimuladosPorQuestao((associacoesAtuais) => ({
      ...associacoesAtuais,
      [questaoId]: simuladosIds,
    }));

    return simuladosIds;
  }

  async function handleEnviarResposta(questaoId, alternativaSelecionadaId) {
    return responderQuestao(questaoId, alternativaSelecionadaId);
  }

  return (
    <section className={estiloQuest.paginaQuestoes}>
      <header className={estiloQuest.topo}>
        <h1 className={estiloQuest.titulo}>Buscar Questões</h1>
      </header>

      <PainelBuscaQuestoes
        onBuscarQuestoes={handleBuscarQuestoes}
        opcoesFiltros={opcoesFiltros}
        carregandoOpcoes={carregandoOpcoesFiltros}
        erroOpcoes={erroOpcoesFiltros}
        onTentarNovamenteOpcoes={recarregarOpcoesFiltros}
      />

      {resultados !== null && (
        <div className={estiloQuest.resultados}>
          {erro && <p className={estiloQuest.mensagemErro}>{erro}</p>}

          {carregando && resultados.length === 0 ? (
            mostrarEsqueletoBusca ? (
              <>
                <CardQuestaoSkeleton />
                <CardQuestaoSkeleton />
                <CardQuestaoSkeleton />
              </>
            ) : null
          ) : resultados.length === 0 && !carregando && !erro ? (
            <p className={estiloQuest.estadoVazio}>Nenhuma questão encontrada.</p>
          ) : (
            resultados.map((questao) => {
              const simuladosIds =
                simuladosPorQuestao[questao.id] ?? questao.simuladosIds;

              return (
                <CardQuestao
                  key={`${versaoBusca}-${questao.id}`}
                  questao={{ ...questao, simuladosIds }}
                  simulados={simulados}
                  carregandoSimulados={carregandoSimulados}
                  erroSimulados={erroSimulados}
                  onSalvarSimulados={handleSalvarSimulados}
                  onEnviarResposta={handleEnviarResposta}
                  exibirSeletorSimulados={podeAdministrarSimulados}
                />
              );
            })
          )}

          {temMais && (
            <div className={estiloQuest.areaCarregarMais}>
              <button
                type="button"
                className={estiloQuest.botaoCarregarMais}
                disabled={carregando}
                onClick={handleCarregarMais}
              >
                {carregando ? "Carregando..." : "Carregar mais"}
              </button>
            </div>
          )}
        </div>
      )}
    </section>
  );
}

export default Questoes;
