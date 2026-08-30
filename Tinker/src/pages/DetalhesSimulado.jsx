import { useEffect, useRef, useState } from "react";
import { IoIosArrowBack } from "react-icons/io";
import { useNavigate, useParams } from "react-router";
import CardQuestao from "../components/questoes/CardQuestao";
import { obterSessao } from "../services/autenticacaoService";
import { responderQuestao } from "../services/questoesService";
import {
  concluirSimuladoDaConta,
  listarQuestoesDoSimuladoDaConta,
  obterSimuladoDaConta,
} from "../services/simuladosApiService";
import estilos from "./DetalhesSimulado.module.css";

function formatarErroApi(erro, mensagemPadrao) {
  if (!(erro instanceof Error)) return mensagemPadrao;
  return erro.codigo ? `${erro.message} (${erro.codigo})` : erro.message;
}

function DetalhesSimulado() {
  const { simuladoId } = useParams();
  const navigate = useNavigate();
  const [simulado, setSimulado] = useState(null);
  const [questoes, setQuestoes] = useState([]);
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState("");
  const [respostas, setRespostas] = useState({});
  const [concluindo, setConcluindo] = useState(false);
  const [erroConclusao, setErroConclusao] = useState("");
  const concluindoRef = useRef(false);
  const tipoUsuario = String(obterSessao()?.tipoUsuario ?? "").toUpperCase();
  const podeAdministrarSimulados = ["ALUNO", "PROFESSOR"].includes(tipoUsuario);

  useEffect(() => {
    let componenteMontado = true;

    async function carregarSimulado() {
      if (!podeAdministrarSimulados) {
        if (componenteMontado) setCarregando(false);
        return;
      }

      setCarregando(true);
      setErro("");
      setSimulado(null);
      setQuestoes([]);

      try {
        const dadosSimulado = await obterSimuladoDaConta(simuladoId);
        const questoesAssociadas = await listarQuestoesDoSimuladoDaConta(
          simuladoId
        );

        if (componenteMontado) {
          setSimulado(dadosSimulado);
          setQuestoes(questoesAssociadas);
        }
      } catch (erroCarregamento) {
        if (!componenteMontado) return;

        setErro(
          erroCarregamento?.codigo === "SIMULADO_NAO_ENCONTRADO"
            ? "Simulado não encontrado."
            : erroCarregamento instanceof Error
              ? erroCarregamento.message
              : "Não foi possível carregar o simulado. Tente novamente."
        );
      } finally {
        if (componenteMontado) setCarregando(false);
      }
    }

    carregarSimulado();
    return () => {
      componenteMontado = false;
    };
  }, [podeAdministrarSimulados, simuladoId]);

  async function handleEnviarResposta(questaoId, alternativaSelecionadaId) {
    const resultadoResposta = await responderQuestao(
      questaoId,
      alternativaSelecionadaId
    );
    setRespostas((respostasAtuais) => ({
      ...respostasAtuais,
      [questaoId]: { questaoId, alternativa: alternativaSelecionadaId },
    }));
    return resultadoResposta;
  }

  async function handleFinalizar() {
    if (
      concluindoRef.current ||
      questoes.length === 0 ||
      Object.keys(respostas).length !== questoes.length
    ) {
      return;
    }

    concluindoRef.current = true;
    setConcluindo(true);
    setErroConclusao("");

    try {
      const respostasOrdenadas = questoes.map(
        (questao) => respostas[questao.id]
      );
      await concluirSimuladoDaConta(simuladoId, respostasOrdenadas);
      navigate("/simulados");
    } catch (erroFinalizacao) {
      setErroConclusao(
        formatarErroApi(
          erroFinalizacao,
          "Não foi possível finalizar o simulado."
        )
      );
      concluindoRef.current = false;
      setConcluindo(false);
    }
  }

  const todasRespondidas =
    questoes.length > 0 && Object.keys(respostas).length === questoes.length;

  return (
    <section className={estilos.pagina}>
      <div className={estilos.envoltorio}>
        <header className={estilos.topo}>
          <button
            type="button"
            className={estilos.botaoVoltar}
            onClick={() => navigate("/simulados")}
            aria-label="Voltar para meus simulados"
          >
            <IoIosArrowBack />
          </button>
        </header>

        {!podeAdministrarSimulados ? (
          <p className={estilos.estado}>
            Esta área não está disponível para este tipo de conta.
          </p>
        ) : carregando ? (
          <p className={estilos.estado}>Carregando simulado...</p>
        ) : erro ? (
          <p className={estilos.erro} role="alert">{erro}</p>
        ) : (
          <div className={estilos.card}>
            <h1 className={estilos.titulo}>{simulado.titulo}</h1>
            {simulado.descricao && (
              <p className={estilos.descricao}>{simulado.descricao}</p>
            )}
            <div className={estilos.metadados}>
              <span>{simulado.quantidadeQuestoes} questões</span>
              {simulado.tempo !== null && <span>{simulado.tempo} min</span>}
            </div>

            {questoes.length === 0 ? (
              <p className={estilos.estado}>
                Este simulado ainda não possui questões.
              </p>
            ) : (
              <>
                <div className={estilos.listaQuestoes}>
                  {questoes.map((questao) => (
                    <CardQuestao
                      key={questao.id}
                      questao={{ ...questao, instituicao: questao.vestibular }}
                      onEnviarResposta={handleEnviarResposta}
                    />
                  ))}
                </div>

                {erroConclusao && (
                  <p className={estilos.erroConclusao} role="alert">
                    {erroConclusao}
                  </p>
                )}

                <div className={estilos.acoes}>
                  <button
                    type="button"
                    onClick={handleFinalizar}
                    disabled={!todasRespondidas || concluindo}
                  >
                    {concluindo ? "Finalizando..." : "Finalizar simulado"}
                  </button>
                </div>
              </>
            )}
          </div>
        )}
      </div>
    </section>
  );
}

export default DetalhesSimulado;
