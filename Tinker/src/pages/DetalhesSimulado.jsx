import { useEffect, useRef, useState } from "react";
import { IoIosArrowBack } from "react-icons/io";
import { useNavigate, useParams } from "react-router";
import CardQuestao from "../components/questoes/CardQuestao";
import { responderQuestao } from "../services/questoesService";
import {
  atualizarQuestaoNosSimulados,
  listarQuestoesDoSimulado,
  listarSimuladosDoUsuario,
  obterSimuladoPorId,
} from "../services/simuladosService";
import estilos from "./DetalhesSimulado.module.css";

function DetalhesSimulado() {
  const { simuladoId } = useParams();
  const navigate = useNavigate();
  const [simulado, setSimulado] = useState(null);
  const [questoes, setQuestoes] = useState([]);
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState("");
  const [simulados, setSimulados] = useState([]);
  const [carregandoSimulados, setCarregandoSimulados] = useState(true);
  const [erroSimulados, setErroSimulados] = useState("");
  const [simuladosPorQuestao, setSimuladosPorQuestao] = useState({});
  const [erroSalvamento, setErroSalvamento] = useState("");
  const [erroResposta, setErroResposta] = useState("");
  const carregamentoAtualRef = useRef(0);

  useEffect(() => {
    carregamentoAtualRef.current += 1;
    const idCarregamento = carregamentoAtualRef.current;
    let carregamentoAtivo = true;

    async function carregarSimulado() {
      setCarregando(true);
      setErro("");
      setSimulado(null);
      setQuestoes([]);
      setSimuladosPorQuestao({});

      try {
        const resumo = await obterSimuladoPorId(simuladoId);
        const questoesAssociadas = await listarQuestoesDoSimulado(simuladoId);

        if (
          carregamentoAtivo &&
          idCarregamento === carregamentoAtualRef.current
        ) {
          setSimulado(resumo);
          setQuestoes(questoesAssociadas);
        }
      } catch (erroCarregamento) {
        if (
          carregamentoAtivo &&
          idCarregamento === carregamentoAtualRef.current
        ) {
          setErro(
            erroCarregamento?.codigo === "SIMULADO_NAO_ENCONTRADO"
              ? "Simulado não encontrado."
              : "Não foi possível carregar o simulado. Tente novamente."
          );
        }
      } finally {
        if (
          carregamentoAtivo &&
          idCarregamento === carregamentoAtualRef.current
        ) {
          setCarregando(false);
        }
      }
    }

    carregarSimulado();

    return () => {
      carregamentoAtivo = false;
    };
  }, [simuladoId]);

  useEffect(() => {
    let carregamentoAtivo = true;

    async function carregarSimulados() {
      setCarregandoSimulados(true);
      setErroSimulados("");

      try {
        const simuladosDoUsuario = await listarSimuladosDoUsuario();
        if (carregamentoAtivo) setSimulados(simuladosDoUsuario);
      } catch {
        if (carregamentoAtivo) {
          setErroSimulados("Não foi possível carregar os simulados.");
        }
      } finally {
        if (carregamentoAtivo) setCarregandoSimulados(false);
      }
    }

    carregarSimulados();
    return () => {
      carregamentoAtivo = false;
    };
  }, []);

  async function handleSalvarSimulados(questaoId, simuladosIds) {
    setErroSalvamento("");

    try {
      const simuladosAtualizados = await atualizarQuestaoNosSimulados(
        questaoId,
        simuladosIds
      );

      setSimuladosPorQuestao((associacoesAtuais) => ({
        ...associacoesAtuais,
        [questaoId]: [...simuladosAtualizados],
      }));
      return simuladosAtualizados;
    } catch (erroSalvar) {
      setErroSalvamento("Não foi possível salvar a questão. Tente novamente.");
      throw erroSalvar;
    }
  }

  async function handleEnviarResposta(questaoId, alternativaId) {
    setErroResposta("");

    try {
      return await responderQuestao(questaoId, alternativaId);
    } catch (erroEnviar) {
      setErroResposta("Não foi possível enviar a resposta. Tente novamente.");
      throw erroEnviar;
    }
  }

  return (
    <section className={estilos.pagina}>
      <header className={estilos.topo}>
        <button
          type="button"
          className={estilos.botaoVoltar}
          onClick={() => navigate("/simulados")}
          aria-label="Voltar para meus simulados"
        >
          <IoIosArrowBack />
        </button>
        <h1 className={estilos.titulo}>{simulado?.titulo ?? "Simulado"}</h1>
        <div aria-hidden="true" />
      </header>

      <div className={estilos.conteudo}>
        {carregando ? (
          <p className={estilos.estado}>Carregando simulado...</p>
        ) : erro ? (
          <p className={estilos.erro} role="alert">{erro}</p>
        ) : questoes.length === 0 ? (
          <p className={estilos.estado}>Este simulado ainda não possui questões.</p>
        ) : (
          <>
            {erroSalvamento && <p className={estilos.erro}>{erroSalvamento}</p>}
            {erroResposta && <p className={estilos.erro}>{erroResposta}</p>}
            <div className={estilos.listaQuestoes}>
              {questoes.map((questao) => {
                const idsAssociados = simuladosPorQuestao[questao.id] ?? [
                  ...(questao.simuladosIds ?? []),
                  simulado.id,
                ];

                return (
                  <CardQuestao
                    key={`${simulado.id}-${questao.id}`}
                    questao={{ ...questao, simuladosIds: [...new Set(idsAssociados)] }}
                    simulados={simulados}
                    carregandoSimulados={carregandoSimulados}
                    erroSimulados={erroSimulados}
                    onSalvarSimulados={handleSalvarSimulados}
                    onEnviarResposta={handleEnviarResposta}
                  />
                );
              })}
            </div>
          </>
        )}
      </div>
    </section>
  );
}

export default DetalhesSimulado;
