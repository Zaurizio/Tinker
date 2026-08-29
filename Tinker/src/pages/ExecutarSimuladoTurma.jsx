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
  obterResultadoDoSimuladoPublicado,
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
  const [resultado, setResultado] = useState(null);
  const [respostas, setRespostas] = useState({});
  const [versaoExecucao, setVersaoExecucao] = useState(0);
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

        const [questoesCarregadas, resultadoCarregado, publicacaoCarregada] =
          await Promise.all([
            listarQuestoesDoSimuladoPublicado(codigo, idPublicacao),
            obterResultadoDoSimuladoPublicado(codigo, idPublicacao),
            consultaPublicacao,
          ]);

        if (carregamentoAtivo) {
          setPublicacao(publicacaoCarregada);
          setQuestoes(questoesCarregadas);
          setResultado(resultadoCarregado.completo ? resultadoCarregado : null);
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
      const resultadoConclusao = await concluirSimuladoPublicado(
        codigo,
        idPublicacao,
        respostasOrdenadas,
      );
      setResultado(resultadoConclusao);
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

  function handleRecomecar() {
    setResultado(null);
    setRespostas({});
    setErroConclusao("");
    setConcluindo(false);
    concluindoRef.current = false;
    setVersaoExecucao((versaoAtual) => versaoAtual + 1);
  }

  const todasRespondidas =
    questoes.length > 0 && Object.keys(respostas).length === questoes.length;

  return (
    <main className={estilos.pagina}>
      <header className={estilos.topo}>
        <button
          type="button"
          className={estilos.botaoVoltar}
          onClick={() => navigate(`/turma/${codigo}/simulados`)}
          aria-label="Voltar para os simulados da turma"
        >
          <IoIosArrowBack />
        </button>
        <h1 className={estilos.titulo}>{publicacao?.titulo ?? "Simulado"}</h1>
        <div aria-hidden="true" />
      </header>

      <div className={estilos.conteudo}>
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
        ) : resultado ? (
          <section className={estilos.resultado} aria-labelledby="resultado-titulo">
            <h2 id="resultado-titulo">Completo</h2>
            <div className={estilos.metricas}>
              <span>{resultado.quantidadeQuestoes} questões</span>
              <span>{resultado.acertos} acertos</span>
              <span>{resultado.erros} erros</span>
            </div>
            <button type="button" onClick={handleRecomecar}>
              Recomeçar
            </button>
          </section>
        ) : questoes.length === 0 ? (
          <p className={estilos.estado}>
            Este simulado não possui questões disponíveis.
          </p>
        ) : (
          <>
            <div className={estilos.listaQuestoes}>
              {questoes.map((questao) => (
                <CardQuestao
                  key={`${versaoExecucao}-${questao.id}`}
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
    </main>
  );
}

export default ExecutarSimuladoTurma;
