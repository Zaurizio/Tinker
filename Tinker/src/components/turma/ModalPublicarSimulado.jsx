import { useEffect, useMemo, useRef, useState } from "react";
import { listarSimuladosDaConta } from "../../services/simuladosApiService";
import BarraBusca from "../ui/BarraBusca";
import estiloModal from "./ModalPublicarSimulado.module.css";

function normalizarTexto(texto) {
  return texto
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase();
}

function formatarErroApi(erro, mensagemPadrao) {
  if (!(erro instanceof Error)) return mensagemPadrao;
  return erro.codigo ? `${erro.message} (${erro.codigo})` : erro.message;
}

function ModalPublicarSimulado({ onPublicar, onFechar }) {
  const [busca, setBusca] = useState("");
  const [simulados, setSimulados] = useState([]);
  const [simuladoSelecionadoId, setSimuladoSelecionadoId] = useState(null);
  const [carregando, setCarregando] = useState(true);
  const [erroCarregamento, setErroCarregamento] = useState("");
  const [publicando, setPublicando] = useState(false);
  const [erroPublicacao, setErroPublicacao] = useState("");
  const publicacaoEmAndamentoRef = useRef(false);

  useEffect(() => {
    let carregamentoAtivo = true;

    async function carregarSimulados() {
      try {
        const simuladosCarregados = await listarSimuladosDaConta();
        if (carregamentoAtivo) setSimulados(simuladosCarregados);
      } catch (erro) {
        if (carregamentoAtivo) {
          setErroCarregamento(
            formatarErroApi(
              erro,
              "Não foi possível carregar os simulados.",
            ),
          );
        }
      } finally {
        if (carregamentoAtivo) setCarregando(false);
      }
    }

    carregarSimulados();
    return () => {
      carregamentoAtivo = false;
    };
  }, []);

  const simuladosFiltrados = useMemo(() => {
    const buscaNormalizada = normalizarTexto(busca.trim());
    return simulados.filter((simulado) =>
      normalizarTexto(simulado.titulo).includes(buscaNormalizada),
    );
  }, [busca, simulados]);

  async function handleSubmit(evento) {
    evento.preventDefault();
    if (simuladoSelecionadoId === null || publicacaoEmAndamentoRef.current) {
      return;
    }

    publicacaoEmAndamentoRef.current = true;
    setPublicando(true);
    setErroPublicacao("");

    try {
      await onPublicar(simuladoSelecionadoId);
      onFechar();
    } catch (erro) {
      setErroPublicacao(
        formatarErroApi(erro, "Não foi possível publicar o simulado."),
      );
      publicacaoEmAndamentoRef.current = false;
      setPublicando(false);
    }
  }

  function renderizarOpcoes() {
    if (carregando) {
      return (
        <div className={estiloModal.estado} role="status">
          Carregando simulados...
        </div>
      );
    }
    if (erroCarregamento) {
      return (
        <div className={estiloModal.estado} role="alert">
          {erroCarregamento}
        </div>
      );
    }
    if (simulados.length === 0) {
      return (
        <div className={estiloModal.estado}>
          Você ainda não possui simulados.
        </div>
      );
    }
    if (simuladosFiltrados.length === 0) {
      return (
        <div className={estiloModal.estado}>Nenhum simulado encontrado.</div>
      );
    }

    return simuladosFiltrados.map((simulado) => (
      <label
        key={simulado.id}
        className={`${estiloModal.opcao} ${
          simuladoSelecionadoId === simulado.id
            ? estiloModal.opcaoSelecionada
            : ""
        }`}
      >
        <input
          type="radio"
          name="simulado"
          value={simulado.id}
          checked={simuladoSelecionadoId === simulado.id}
          onChange={() => setSimuladoSelecionadoId(simulado.id)}
          disabled={publicando}
        />
        <span>
          <strong>{simulado.titulo}</strong>
          <small>
            {simulado.quantidadeQuestoes}{" "}
            {simulado.quantidadeQuestoes === 1 ? "questão" : "questões"}
          </small>
        </span>
      </label>
    ));
  }

  return (
    <div
      className={estiloModal.overlay}
      onClick={publicando ? undefined : onFechar}
    >
      <div
        className={estiloModal.modal}
        role="dialog"
        aria-modal="true"
        aria-labelledby="titulo-publicar-simulado"
        onClick={(evento) => evento.stopPropagation()}
      >
        <h2 id="titulo-publicar-simulado">Publicar simulado</h2>
        <p>O simulado ficará disponível para os membros desta turma.</p>

        <form onSubmit={handleSubmit}>
          <BarraBusca
            placeholder="Pesquisar simulados..."
            value={busca}
            onChange={setBusca}
            disabled={publicando}
          />
          <div className={estiloModal.opcoes}>{renderizarOpcoes()}</div>

          {erroPublicacao && (
            <div className={estiloModal.erro} role="alert">
              {erroPublicacao}
            </div>
          )}

          <div className={estiloModal.acoes}>
            <button type="button" onClick={onFechar} disabled={publicando}>
              Cancelar
            </button>
            <button
              type="submit"
              className={estiloModal.publicar}
              disabled={simuladoSelecionadoId === null || publicando}
            >
              {publicando ? "Publicando..." : "Publicar"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default ModalPublicarSimulado;
