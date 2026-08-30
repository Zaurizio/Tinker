import { useEffect, useState } from "react";
import { IoIosArrowBack } from "react-icons/io";
import { useNavigate, useParams } from "react-router";
import CardQuestao from "../components/questoes/CardQuestao";
import { obterSessao } from "../services/autenticacaoService";
import { responderQuestao } from "../services/questoesService";
import {
  listarQuestoesDoSimuladoDaConta,
  obterSimuladoDaConta,
} from "../services/simuladosApiService";
import estilos from "./DetalhesSimulado.module.css";

function DetalhesSimulado() {
  const { simuladoId } = useParams();
  const navigate = useNavigate();
  const [simulado, setSimulado] = useState(null);
  const [questoes, setQuestoes] = useState([]);
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState("");
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
    return responderQuestao(questaoId, alternativaSelecionadaId);
  }

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
              <div className={estilos.listaQuestoes}>
                {questoes.map((questao) => (
                  <CardQuestao
                    key={questao.id}
                    questao={{ ...questao, instituicao: questao.vestibular }}
                    onEnviarResposta={handleEnviarResposta}
                  />
                ))}
              </div>
            )}
          </div>
        )}
      </div>
    </section>
  );
}

export default DetalhesSimulado;
