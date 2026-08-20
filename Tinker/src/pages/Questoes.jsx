import { useEffect, useRef, useState } from "react";
import estiloQuest from "./Questoes.module.css";
import PainelBuscaQuestoes from "../components/questoes/PainelBuscaQuestoes";
import CardQuestao from "../components/questoes/CardQuestao";
import {
  buscarQuestoes,
  responderQuestao,
} from "../services/questoesService";
import {
  atualizarQuestaoNosSimulados,
  listarSimuladosDoUsuario,
} from "../services/simuladosService";

const TAMANHO_LOTE = 10;

function Questoes() {
  const [resultados, setResultados] = useState(null); //busca por questoes
  const [simulados, setSimulados] = useState([]);
  const [carregandoSimulados, setCarregandoSimulados] = useState(true);
  const [erroSimulados, setErroSimulados] = useState("");
  const [versaoBusca, setVersaoBusca] = useState(0);
  const [simuladosPorQuestao, setSimuladosPorQuestao] = useState({});
  const [filtrosDaBusca, setFiltrosDaBusca] = useState(null);
  const [paginaAtual, setPaginaAtual] = useState(0);
  const [temMais, setTemMais] = useState(false);
  const [carregando, setCarregando] = useState(false);
  const [erro, setErro] = useState("");
  const buscaAtivaRef = useRef(0);

  useEffect(() => {
    let carregamentoAtivo = true;

    async function carregarSimulados() {
      setCarregandoSimulados(true);
      setErroSimulados("");

      try {
        const simuladosDoUsuario = await listarSimuladosDoUsuario();

        if (carregamentoAtivo) {
          setSimulados(simuladosDoUsuario);
        }
      } catch {
        if (carregamentoAtivo) {
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
  }, []);

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
    const simuladosAtualizados = await atualizarQuestaoNosSimulados(
      questaoId,
      simuladosIds,
    );

    setSimuladosPorQuestao((associacoesAtuais) => ({
      ...associacoesAtuais,
      [questaoId]: simuladosAtualizados,
    }));

    return simuladosAtualizados;
  }

  async function handleEnviarResposta(questaoId, alternativaSelecionadaId) {
    return responderQuestao(questaoId, alternativaSelecionadaId);
  }

  return (
    <section className={estiloQuest.paginaQuestoes}>
      <header className={estiloQuest.topo}>
        <h1 className={estiloQuest.titulo}>Buscar Questões</h1>
      </header>

      <PainelBuscaQuestoes onBuscarQuestoes={handleBuscarQuestoes} />

      {resultados !== null && (
        <div className={estiloQuest.resultados}>
          {erro && <p className={estiloQuest.mensagemErro}>{erro}</p>}

          {resultados.length === 0 && !carregando && !erro ? (
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
