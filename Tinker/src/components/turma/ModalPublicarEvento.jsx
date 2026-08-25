import { useEffect, useMemo, useRef, useState } from "react";
import BarraBusca from "../ui/BarraBusca";
import { listarEventosDoUsuario } from "../../services/calendarioService";
import {
  formatarDataCurta,
  formatarHorarioEvento,
} from "../../utils/dataEvento";
import estiloModal from "./ModalPublicarSimulado.module.css";

function normalizarTexto(texto) {
  return texto
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase();
}

function prepararEvento(evento) {
  return {
    id: evento.id,
    titulo: evento.title,
    data: evento.extendedProps.data,
    diaInteiro: evento.allDay,
    horaInicio: evento.extendedProps.horarioInicio,
    horaFim: evento.extendedProps.horarioFim,
    cor: evento.color,
  };
}

function ModalPublicarEvento({ onPublicar, onFechar }) {
  const [busca, setBusca] = useState("");
  const [eventos, setEventos] = useState([]);
  const [eventoSelecionadoId, setEventoSelecionadoId] = useState(null);
  const [carregando, setCarregando] = useState(true);
  const [erroCarregamento, setErroCarregamento] = useState("");
  const [publicando, setPublicando] = useState(false);
  const [erroPublicacao, setErroPublicacao] = useState("");
  const publicacaoEmAndamentoRef = useRef(false);
  const componenteMontadoRef = useRef(true);

  useEffect(() => {
    let carregamentoAtivo = true;
    componenteMontadoRef.current = true;

    async function carregarEventos() {
      try {
        const eventosCarregados = await listarEventosDoUsuario();
        if (carregamentoAtivo) {
          setEventos(eventosCarregados.map(prepararEvento));
        }
      } catch {
        if (carregamentoAtivo) {
          setErroCarregamento("Não foi possível carregar os eventos.");
        }
      } finally {
        if (carregamentoAtivo) setCarregando(false);
      }
    }

    carregarEventos();

    return () => {
      carregamentoAtivo = false;
      componenteMontadoRef.current = false;
    };
  }, []);

  const eventosFiltrados = useMemo(() => {
    const buscaNormalizada = normalizarTexto(busca.trim());

    return eventos.filter((evento) =>
      normalizarTexto(evento.titulo).includes(buscaNormalizada)
    );
  }, [busca, eventos]);

  async function handleSubmit(eventoSubmit) {
    eventoSubmit.preventDefault();

    if (eventoSelecionadoId === null || publicacaoEmAndamentoRef.current) return;

    publicacaoEmAndamentoRef.current = true;
    setPublicando(true);
    setErroPublicacao("");

    try {
      await onPublicar(eventoSelecionadoId);
      if (componenteMontadoRef.current) onFechar();
    } catch (erro) {
      if (!componenteMontadoRef.current) return;

      setErroPublicacao(
        erro instanceof Error ? erro.message : "Não foi possível publicar o evento."
      );
      publicacaoEmAndamentoRef.current = false;
      setPublicando(false);
    }
  }

  function handleFechar() {
    if (!publicacaoEmAndamentoRef.current) onFechar();
  }

  function renderizarOpcoes() {
    if (carregando) return <div className={estiloModal.estado} role="status">Carregando eventos...</div>;
    if (erroCarregamento) {
      return <div className={estiloModal.estado} role="alert">{erroCarregamento}</div>;
    }
    if (eventos.length === 0) {
      return <div className={estiloModal.estado}>Você ainda não possui eventos.</div>;
    }
    if (eventosFiltrados.length === 0) {
      return <div className={estiloModal.estado}>Nenhum evento encontrado.</div>;
    }

    return eventosFiltrados.map((evento) => (
      <label
        key={evento.id}
        className={`${estiloModal.opcao} ${
          eventoSelecionadoId === evento.id ? estiloModal.opcaoSelecionada : ""
        }`}
      >
        <input
          type="radio"
          name="evento"
          value={evento.id}
          checked={eventoSelecionadoId === evento.id}
          onChange={() => setEventoSelecionadoId(evento.id)}
          disabled={publicando}
        />
        <i
          className={estiloModal.marcadorCor}
          style={{ backgroundColor: evento.cor }}
          aria-hidden="true"
        />
        <span>
          <strong>{evento.titulo}</strong>
          <small>
            {formatarDataCurta(evento.data)} · {formatarHorarioEvento(evento)}
          </small>
        </span>
      </label>
    ));
  }

  return (
    <div className={estiloModal.overlay} onClick={handleFechar}>
      <div
        className={estiloModal.modal}
        role="dialog"
        aria-modal="true"
        aria-labelledby="titulo-publicar-evento"
        onClick={(evento) => evento.stopPropagation()}
      >
        <h2 id="titulo-publicar-evento">Publicar evento</h2>
        <p>O evento ficará disponível para os membros desta turma.</p>

        <form onSubmit={handleSubmit}>
          <BarraBusca
            placeholder="Pesquisar eventos..."
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
            <button type="button" onClick={handleFechar} disabled={publicando}>
              Cancelar
            </button>
            <button
              type="submit"
              className={estiloModal.publicar}
              disabled={eventoSelecionadoId === null || publicando}
            >
              {publicando ? "Publicando..." : "Publicar"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default ModalPublicarEvento;
