import { useEffect, useRef, useState } from "react";
import { IoIosArrowBack } from "react-icons/io";
import { useLocation, useNavigate, useParams } from "react-router";
import CardQuestao from "../components/questoes/CardQuestao";
import { obterSessao } from "../services/autenticacaoService";
import {
  concluirSimuladoPublicado,
  corrigirQuestaoDoSimuladoPublicado,
  listarQuestoesDoSimuladoPublicado,
  listarSimuladosPublicadosNaTurma,
} from "../services/turmasApiService";
import estilos from "./ExecutarSimuladoTurma.module.css";

function formatarErroApi(erro, mensagemPadrao) {
  if (!(erro instanceof Error)) return mensagemPadrao;
  return erro.codigo ? `${erro.message} (${erro.codigo})` : erro.message;
}

function ExecutarSimuladoTurma() {
  const { codigo, idPublicacao } = useParams();
  const navigate = useNavigate();
  const { state } = useLocation();
  const publicacaoDoCard =
    String(state?.publicacao?.idPublicacao ?? "") === idPublicacao
      ? state.publicacao
      : null;
  const publicacaoInicialRef = useRef(publicacaoDoCard);
  const [publicacao, setPublicacao] = useState(publicacaoDoCard);
  const [questoes, setQuestoes] = useState([]);
  const [respostas, setRespostas] = useState({});
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState("");
  const [concluindo, setConcluindo] = useState(false);
  const [erroConclusao, setErroConclusao] = useState("");
  const concluindoRef = useRef(false);
  const tipoUsuario = String(obterSessao()?.tipoUsuario ?? "").toUpperCase();
  const eAluno = tipoUsuario === "ALUNO";

  useEffect(() => {
    let carregamentoAtivo = true;

    async function carregarExecucao() {
      if (!eAluno) {
        setCarregando(false);
        return;
      }

      setCarregando(true);
      setErro("");

      try {
        const publicacaoInicial = publicacaoInicialRef.current;
        const consultaPublicacao =
          publicacaoInicial?.idPublicacao === idPublicacao
          ? Promise.resolve(publicacaoInicial)
          : listarSimuladosPublicadosNaTurma(codigo).then((publicacoes) => {
              const encontrada = publicacoes.find(
                (item) => item.idPublicacao === idPublicacao,
              );
              if (!encontrada) {
                const erroPublicacao = new Error(
                  "A publicação não foi encontrada.",
                );
                erroPublicacao.codigo = "PUBLICACAO_NAO_ENCONTRADA";
                throw erroPublicacao;
              }
              return encontrada;
            });

        const [questoesCarregadas, publicacaoCarregada] = await Promise.all([
          listarQuestoesDoSimuladoPublicado(codigo, idPublicacao),
          consultaPublicacao,
        ]);

        if (carregamentoAtivo) {
          setPublicacao(publicacaoCarregada);
          setQuestoes(questoesCarregadas);
        }
      } catch (erroCarregamento) {
        if (carregamentoAtivo) {
          setErro(
            formatarErroApi(
              erroCarregamento,
              "Não foi possível carregar o simulado.",
            ),
          );
        }
      } finally {
        if (carregamentoAtivo) setCarregando(false);
      }
    }

    carregarExecucao();
    return () => {
      carregamentoAtivo = false;
    };
  }, [codigo, eAluno, idPublicacao]);

  async function handleEnviarResposta(questaoId, alternativa) {
    try {
      const correcao = await corrigirQuestaoDoSimuladoPublicado(
        codigo,
        idPublicacao,
        questaoId,
        alternativa,
      );
      setRespostas((respostasAtuais) => ({
        ...respostasAtuais,
        [questaoId]: { questaoId, alternativa },
      }));
      return correcao;
    } catch (erroCorrecao) {
      throw new Error(
        formatarErroApi(
          erroCorrecao,
          "Não foi possível enviar a resposta.",
        ),
      );
    }
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
        (questao) => respostas[questao.id],
      );
      await concluirSimuladoPublicado(codigo, idPublicacao, respostasOrdenadas);
      navigate(`/turma/${codigo}/simulados`);
    } catch (erroFinalizacao) {
      setErroConclusao(
        formatarErroApi(
          erroFinalizacao,
          "Não foi possível finalizar o simulado.",
        ),
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
            onClick={() => navigate(`/turma/${codigo}/simulados`)}
            aria-label="Voltar para os simulados da turma"
          >
            <IoIosArrowBack />
          </button>

          <div className={estilos.conteudoPrincipal}>
            {!eAluno ? (
              <p className={estilos.estado}>
                A execução de simulados da turma está disponível somente para alunos.
              </p>
            ) : carregando ? (
              <p className={estilos.estado} role="status">
                Carregando simulado...
              </p>
            ) : erro ? (
              <p className={estilos.erro} role="alert">
                {erro}
              </p>
            ) : (
              <div className={estilos.card}>
                <h1 className={estilos.titulo}>{publicacao?.titulo ?? "Simulado"}</h1>

                {questoes.length === 0 ? (
                  <p className={estilos.estado}>
                    Este simulado não possui questões disponíveis.
                  </p>
                ) : (
                  <>
                    <div className={estilos.metadados}>
                      <span>{questoes.length} questões</span>
                    </div>

                    <div className={estilos.listaQuestoes}>
                      {questoes.map((questao) => (
                        <CardQuestao
                          key={questao.id}
                          questao={questao}
                          exibirSeletorSimulados={false}
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

export default ExecutarSimuladoTurma;
