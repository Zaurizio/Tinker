import { useEffect, useRef, useState } from "react";
import { IoIosArrowBack } from "react-icons/io";
import { useNavigate, useParams } from "react-router";
import CardQuestao from "../components/questoes/CardQuestao";
import CardQuestaoSkeleton from "../components/questoes/CardQuestaoSkeleton";
import Skeleton from "../components/ui/Skeleton";
import { obterSessao } from "../services/autenticacaoService";
import { responderQuestao } from "../services/questoesService";
import {
  concluirSimuladoDaConta,
  listarQuestoesDoSimuladoDaConta,
  obterSimuladoDaConta,
} from "../services/simuladosApiService";
import { obterCache, definirCache } from "../services/cacheStore";
import { chaveSimulado } from "../services/cacheChaves";
import { useEsqueletoAtrasado } from "../hooks/useEsqueletoAtrasado";
import estilos from "./DetalhesSimulado.module.css";

function formatarErroApi(erro, mensagemPadrao) {
  if (!(erro instanceof Error)) return mensagemPadrao;
  return erro.codigo ? `${erro.message} (${erro.codigo})` : erro.message;
}

function DetalhesSimulado() {
  const { simuladoId } = useParams();
  const navigate = useNavigate();
  const cacheInicial = obterCache(chaveSimulado(simuladoId));
  const [simulado, setSimulado] = useState(() => cacheInicial?.simulado ?? null);
  const [questoes, setQuestoes] = useState(() => cacheInicial?.questoes ?? []);
  const [carregando, setCarregando] = useState(() => cacheInicial === undefined);
  const [erro, setErro] = useState("");
  const [respostas, setRespostas] = useState({});
  const [concluindo, setConcluindo] = useState(false);
  const [erroConclusao, setErroConclusao] = useState("");
  const concluindoRef = useRef(false);
  const tipoUsuario = String(obterSessao()?.tipoUsuario ?? "").toUpperCase();
  const podeAdministrarSimulados = ["ALUNO", "PROFESSOR"].includes(tipoUsuario);
  const mostrarEsqueleto = useEsqueletoAtrasado(carregando);

  useEffect(() => {
    let componenteMontado = true;

    async function carregarSimulado() {
      if (!podeAdministrarSimulados) {
        if (componenteMontado) setCarregando(false);
        return;
      }

      const chave = chaveSimulado(simuladoId);
      const emCache = obterCache(chave);

      if (emCache) {
        setSimulado(emCache.simulado);
        setQuestoes(emCache.questoes);
        setCarregando(false);
      } else {
        setSimulado(null);
        setQuestoes([]);
        setCarregando(true);
      }
      setErro("");

      try {
        const [dadosSimulado, questoesAssociadas] = await Promise.all([
          obterSimuladoDaConta(simuladoId),
          listarQuestoesDoSimuladoDaConta(simuladoId),
        ]);

        if (componenteMontado) {
          setSimulado(dadosSimulado);
          setQuestoes(questoesAssociadas);
          definirCache(chave, { simulado: dadosSimulado, questoes: questoesAssociadas });
        }
      } catch (erroCarregamento) {
        if (!componenteMontado || emCache) return;

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
        <div className={estilos.linha}>
          <button
            type="button"
            className={estilos.botaoVoltar}
            onClick={() => navigate("/simulados")}
            aria-label="Voltar para meus simulados"
          >
            <IoIosArrowBack />
          </button>

          <div className={estilos.conteudoPrincipal}>
            {!podeAdministrarSimulados ? (
              <p className={estilos.estado}>
                Esta área não está disponível para este tipo de conta.
              </p>
            ) : carregando ? (
              mostrarEsqueleto ? (
                <div className={estilos.card} aria-hidden="true">
                  <Skeleton height="1.8rem" width="60%" style={{ marginBottom: 12 }} />
                  <div className={estilos.metadados}>
                    <Skeleton width="76px" height="22px" radius="999px" />
                    <Skeleton width="60px" height="22px" radius="999px" />
                  </div>
                  <div className={estilos.listaQuestoes}>
                    <CardQuestaoSkeleton />
                    <CardQuestaoSkeleton />
                    <CardQuestaoSkeleton />
                  </div>
                </div>
              ) : null
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
        </div>
      </div>
    </section>
  );
}

export default DetalhesSimulado;
