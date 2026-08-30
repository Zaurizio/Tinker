import { useEffect, useMemo, useRef, useState } from "react";
import BookmarkIcon from "@mui/icons-material/Bookmark";
import BookmarkBorderIcon from "@mui/icons-material/BookmarkBorder";
import Checkbox from "@mui/material/Checkbox";
import IconButton from "@mui/material/IconButton";
import Radio from "@mui/material/Radio";
import estilosSelecao from "./CampoSelecaoMultipla.module.css";
import styles from "./CardQuestao.module.css";

export default function CardQuestao({
  questao,
  simulados = [],
  carregandoSimulados,
  erroSimulados,
  onSalvarSimulados,
  onEnviarResposta,
  exibirSeletorSimulados = false,
}) {
  const [alternativaSelecionada, setAlternativaSelecionada] = useState(null);
  const [questaoRespondida, setQuestaoRespondida] = useState(false);
  const [resultadoResposta, setResultadoResposta] = useState(null);
  const [enviandoResposta, setEnviandoResposta] = useState(false);
  const [erroResposta, setErroResposta] = useState("");
  const [seletorSimuladosAberto, setSeletorSimuladosAberto] = useState(false);
  const [buscaSimulado, setBuscaSimulado] = useState("");
  const [simuladosTemporarios, setSimuladosTemporarios] = useState(
    () => new Set(questao.simuladosIds ?? []),
  );
  const [salvandoSimulados, setSalvandoSimulados] = useState(false);
  const [erroSalvamento, setErroSalvamento] = useState("");
  const [alternativasEliminadas, setAlternativasEliminadas] = useState(
    () => new Set(),
  );
  const seletorSimuladosRef = useRef(null);
  const enviandoRespostaRef = useRef(false);

  const simuladosFiltrados = useMemo(() => {
    const buscaNormalizada = normalizarTexto(buscaSimulado);

    return simulados.filter((simulado) =>
      normalizarTexto(simulado.titulo).includes(buscaNormalizada),
    );
  }, [buscaSimulado, simulados]);

  useEffect(() => {
    function fecharAoClicarFora(evento) {
      if (
        seletorSimuladosRef.current &&
        !seletorSimuladosRef.current.contains(evento.target)
      ) {
        setSimuladosTemporarios(new Set(questao.simuladosIds ?? []));
        setBuscaSimulado("");
        setErroSalvamento("");
        setSeletorSimuladosAberto(false);
      }
    }

    if (seletorSimuladosAberto) {
      document.addEventListener("mousedown", fecharAoClicarFora);
    }

    return () => document.removeEventListener("mousedown", fecharAoClicarFora);
  }, [seletorSimuladosAberto, questao.simuladosIds]);

  function normalizarTexto(texto) {
    return texto
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .toLowerCase();
  }

  function alternarEliminacao(alternativaId) {
    if (questaoRespondida) return;

    setAlternativasEliminadas((eliminadasAtuais) => {
      const proximasEliminadas = new Set(eliminadasAtuais);

      if (proximasEliminadas.has(alternativaId)) {
        proximasEliminadas.delete(alternativaId);
      } else {
        proximasEliminadas.add(alternativaId);
      }

      return proximasEliminadas;
    });

    if (alternativaSelecionada === alternativaId) {
      setAlternativaSelecionada(null);
    }
  }

  function abrirSeletorSimulados() {
    setSimuladosTemporarios(new Set(questao.simuladosIds ?? []));
    setBuscaSimulado("");
    setErroSalvamento("");
    setSeletorSimuladosAberto(true);
  }

  function fecharSeletorSimulados() {
    setSimuladosTemporarios(new Set(questao.simuladosIds ?? []));
    setBuscaSimulado("");
    setErroSalvamento("");
    setSeletorSimuladosAberto(false);
  }

  function alternarSimuladoTemporario(simuladoId) {
    setSimuladosTemporarios((selecionadosAtuais) => {
      const proximosSelecionados = new Set(selecionadosAtuais);

      if (proximosSelecionados.has(simuladoId)) {
        proximosSelecionados.delete(simuladoId);
      } else {
        proximosSelecionados.add(simuladoId);
      }

      return proximosSelecionados;
    });
  }

  async function salvarSimulados() {
    if (salvandoSimulados || carregandoSimulados || erroSimulados) {
      return;
    }

    const simuladosIds = [...simuladosTemporarios];

    setSalvandoSimulados(true);
    setErroSalvamento("");

    try {
      await onSalvarSimulados(questao.id, simuladosIds);
      setBuscaSimulado("");
      setSeletorSimuladosAberto(false);
    } catch (erro) {
      if (Array.isArray(erro?.simuladosIdsSincronizados)) {
        const selecaoSincronizada = new Set(
          erro.simuladosIdsSincronizados,
        );
        setSimuladosTemporarios(new Set(selecaoSincronizada));
      }

      setErroSalvamento(
        erro instanceof Error
          ? erro.message
          : "Não foi possível salvar. Tente novamente.",
      );
    } finally {
      setSalvandoSimulados(false);
    }
  }

  async function enviarResposta() {
    if (
      alternativaSelecionada === null ||
      questaoRespondida ||
      enviandoRespostaRef.current
    ) {
      return;
    }

    enviandoRespostaRef.current = true;
    setEnviandoResposta(true);
    setErroResposta("");

    try {
      const resultado = await onEnviarResposta(
        questao.id,
        alternativaSelecionada,
      );

      setResultadoResposta(resultado);
      setQuestaoRespondida(true);
    } catch (erro) {
      setErroResposta(
        erro instanceof Error
          ? erro.message
          : "Não foi possível enviar a resposta. Tente novamente.",
      );
    } finally {
      enviandoRespostaRef.current = false;
      setEnviandoResposta(false);
    }
  }

  return (
    <article className={styles.cardQuestao}>
      <div className={styles.cabecalho}>
        <div className={styles.metadados}>
          <span>{questao.disciplina}</span>
          <span>{questao.conteudo}</span>
          <span>{questao.instituicao}</span>
          <span>{questao.ano}</span>
        </div>

        {exibirSeletorSimulados && (
          <div
            className={styles.areaSeletorSimulados}
            ref={seletorSimuladosRef}
          >
            <IconButton
              className={styles.botaoSalvar}
              aria-label="Salvar questão em simulado"
              aria-controls={
                seletorSimuladosAberto ? `simulados-${questao.id}` : undefined
              }
              aria-expanded={seletorSimuladosAberto}
              aria-haspopup="dialog"
              onClick={() =>
                seletorSimuladosAberto
                  ? fecharSeletorSimulados()
                  : abrirSeletorSimulados()
              }
              size="small"
            >
              {(questao.simuladosIds?.length ?? 0) > 0 ? (
                <BookmarkIcon />
              ) : (
                <BookmarkBorderIcon />
              )}
            </IconButton>

            {seletorSimuladosAberto && (
            <div
              id={`simulados-${questao.id}`}
              className={`${estilosSelecao.painelSelecao} ${styles.painelSimulados}`}
              role="dialog"
              aria-label="Selecionar simulados"
            >
              <div className={estilosSelecao.topoPainel}>
                <input
                  type="search"
                  className={estilosSelecao.inputBusca}
                  value={buscaSimulado}
                  onChange={(evento) => setBuscaSimulado(evento.target.value)}
                  placeholder="Pesquisar simulado"
                  autoFocus
                />
              </div>

              <div className={estilosSelecao.listaOpcoes}>
                {carregandoSimulados ? (
                  <div className={estilosSelecao.estadoVazio}>
                    Carregando simulados...
                  </div>
                ) : erroSimulados ? (
                  <div className={estilosSelecao.estadoVazio}>
                    Não foi possível carregar os simulados.
                  </div>
                ) : simulados.length === 0 ? (
                  <div className={estilosSelecao.estadoVazio}>
                    Você ainda não tem nenhum simulado.
                  </div>
                ) : simuladosFiltrados.length === 0 ? (
                  <div className={estilosSelecao.estadoVazio}>
                    Nenhum simulado encontrado.
                  </div>
                ) : (
                  simuladosFiltrados.map((simulado) => (
                    <label
                      key={simulado.id}
                      className={estilosSelecao.itemOpcao}
                    >
                      <Checkbox
                        checked={simuladosTemporarios.has(simulado.id)}
                        onChange={() =>
                          alternarSimuladoTemporario(simulado.id)
                        }
                        className={estilosSelecao.checkboxCustom}
                        disableRipple
                      />
                      <span>{simulado.titulo}</span>
                    </label>
                  ))
                )}
              </div>

              {erroSalvamento && (
                <div className={styles.mensagemErro}>{erroSalvamento}</div>
              )}

              <div className={estilosSelecao.acoesPainel}>
                <button
                  type="button"
                  className={estilosSelecao.botaoLimpar}
                  onClick={fecharSeletorSimulados}
                >
                  Cancelar
                </button>
                <button
                  type="button"
                  className={estilosSelecao.botaoAplicar}
                  disabled={
                    salvandoSimulados ||
                    carregandoSimulados ||
                    Boolean(erroSimulados)
                  }
                  onClick={salvarSimulados}
                >
                  {salvandoSimulados ? "Salvando..." : "Salvar"}
                </button>
              </div>
            </div>
            )}
          </div>
        )}
      </div>

      <p className={styles.enunciado}>
        {questao.enunciado}
      </p>

      <div className={styles.alternativas}>
        {questao.alternativas.map((alternativa) => {
          const eliminada = alternativasEliminadas.has(alternativa.id);
          const alternativaRespondida =
            resultadoResposta?.alternativaSelecionadaId === alternativa.id;
          const alternativaCorreta =
            (alternativaRespondida && resultadoResposta?.acertou === true) ||
            (resultadoResposta?.acertou === false &&
              resultadoResposta.alternativaCorreta === alternativa.id);
          const alternativaIncorretaSelecionada =
            alternativaRespondida && resultadoResposta?.acertou === false;
          const textoResultado = alternativaCorreta
            ? alternativaRespondida
              ? "Resposta correta"
              : "Alternativa correta"
            : alternativaIncorretaSelecionada
              ? "Sua resposta"
              : "";

          return (
            <div
              className={`${styles.alternativa} ${
                eliminada ? styles.eliminada : ""
              } ${alternativaCorreta ? styles.correta : ""} ${
                alternativaIncorretaSelecionada ? styles.incorreta : ""
              }`}
              key={alternativa.id}
            >
              <label className={styles.conteudoAlternativa}>
                <Radio
                  checked={alternativaSelecionada === alternativa.id}
                  disabled={
                    eliminada || questaoRespondida || enviandoResposta
                  }
                  name={`questao-${questao.id}`}
                  onChange={() => setAlternativaSelecionada(alternativa.id)}
                  value={alternativa.id}
                  size="small"
                  sx={{
                    color: "var(--cor-texto-secundario)",
                    "&.Mui-checked": { color: "var(--cor-primaria-destaque)" },
                  }}
                />

                <span>{alternativa.texto}</span>
                {textoResultado && (
                  <span className={styles.indicadorResultado}>
                    {textoResultado}
                  </span>
                )}
              </label>

              <button
                type="button"
                className={styles.botaoEliminar}
                disabled={questaoRespondida || enviandoResposta}
                onClick={() => alternarEliminacao(alternativa.id)}
                aria-label={`${eliminada ? "Restaurar" : "Eliminar"} alternativa`}
                aria-pressed={eliminada}
              >
                X
              </button>
            </div>
          );
        })}
      </div>

      <div className={styles.acoes}>
        <button
          type="button"
          className={styles.botaoEnviar}
          disabled={
            alternativaSelecionada === null ||
            questaoRespondida ||
            enviandoResposta
          }
          onClick={enviarResposta}
        >
          {enviandoResposta
            ? "Enviando..."
            : questaoRespondida
              ? "Resposta enviada"
              : "Enviar resposta"}
        </button>
      </div>

      {erroResposta && (
        <p className={styles.mensagemErro}>{erroResposta}</p>
      )}

      {resultadoResposta && (
        <p
          className={
            resultadoResposta.acertou
              ? styles.mensagemSucesso
              : styles.mensagemErro
          }
        >
          {resultadoResposta.acertou
            ? "Resposta correta!"
            : "Resposta incorreta."}
        </p>
      )}
    </article>
  );
}
