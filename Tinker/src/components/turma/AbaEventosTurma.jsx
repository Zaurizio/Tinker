import { useEffect, useMemo, useRef, useState } from "react";
import BarraBusca from "../ui/BarraBusca";
import {
  adicionarEventoDaTurmaAoCalendario,
  listarEventosDaTurma,
  publicarEventoNaTurma,
} from "../../services/turmaService";
import CardEventoTurma from "./CardEventoTurma";
import ModalPublicarEvento from "./ModalPublicarEvento";
import estiloEventos from "./AbaEventosTurma.module.css";

function normalizarTexto(texto) {
  return texto
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase();
}

function AbaEventosTurma({ turmaId, usuarioAdministrador }) {
  const [busca, setBusca] = useState("");
  const [eventos, setEventos] = useState([]);
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState("");
  const [modalPublicacaoAberto, setModalPublicacaoAberto] = useState(false);
  const componenteMontadoRef = useRef(true);

  useEffect(() => {
    componenteMontadoRef.current = true;

    return () => {
      componenteMontadoRef.current = false;
    };
  }, []);

  useEffect(() => {
    let carregamentoAtivo = true;

    async function carregarEventos() {
      setCarregando(true);
      setErro("");

      try {
        const eventosCarregados = await listarEventosDaTurma(turmaId);
        if (carregamentoAtivo) setEventos(eventosCarregados);
      } catch {
        if (carregamentoAtivo) {
          setErro("Não foi possível carregar os eventos.");
        }
      } finally {
        if (carregamentoAtivo) setCarregando(false);
      }
    }

    carregarEventos();

    return () => {
      carregamentoAtivo = false;
    };
  }, [turmaId]);

  const eventosFiltrados = useMemo(() => {
    const buscaNormalizada = normalizarTexto(busca.trim());

    return eventos.filter((evento) =>
      normalizarTexto(evento.titulo).includes(buscaNormalizada)
    );
  }, [busca, eventos]);

  async function handlePublicarEvento(eventoId) {
    await publicarEventoNaTurma(turmaId, eventoId);
    const eventosAtualizados = await listarEventosDaTurma(turmaId);

    if (componenteMontadoRef.current) setEventos(eventosAtualizados);
  }

  async function handleAdicionarEvento(publicacaoId) {
    const resultado = await adicionarEventoDaTurmaAoCalendario(publicacaoId);

    if (!componenteMontadoRef.current) return resultado;

    setEventos((eventosAtuais) =>
      eventosAtuais.map((evento) =>
        evento.idPublicacao === publicacaoId
          ? { ...evento, salvoPeloUsuario: true }
          : evento
      )
    );

    return resultado;
  }

  function renderizarLista() {
    if (carregando) {
      return <div className={estiloEventos.estado} role="status">Carregando eventos...</div>;
    }

    if (erro) {
      return (
        <div className={estiloEventos.estado} role="alert">
          {erro}
        </div>
      );
    }

    if (eventos.length === 0) {
      return (
        <div className={estiloEventos.estado}>
          Nenhum evento foi publicado nesta turma.
        </div>
      );
    }

    if (eventosFiltrados.length === 0) {
      return <div className={estiloEventos.estado}>Nenhum evento encontrado.</div>;
    }

    return eventosFiltrados.map((evento) => (
      <CardEventoTurma
        key={evento.idPublicacao}
        evento={evento}
        onAdicionar={handleAdicionarEvento}
      />
    ));
  }

  return (
    <section aria-labelledby="titulo-eventos-turma">
      <div className={estiloEventos.cabecalho}>
        <div>
          <h2 id="titulo-eventos-turma">Eventos</h2>
          <p>Eventos publicados para esta turma.</p>
        </div>

        {usuarioAdministrador && (
          <button
            type="button"
            className={estiloEventos.botaoNovo}
            onClick={() => setModalPublicacaoAberto(true)}
          >
            + Novo evento
          </button>
        )}
      </div>

      <div className={estiloEventos.busca}>
        <BarraBusca
          placeholder="Pesquisar eventos..."
          value={busca}
          onChange={setBusca}
        />
      </div>

      <div className={estiloEventos.lista}>{renderizarLista()}</div>

      {modalPublicacaoAberto && (
        <ModalPublicarEvento
          onPublicar={handlePublicarEvento}
          onFechar={() => setModalPublicacaoAberto(false)}
        />
      )}
    </section>
  );
}

export default AbaEventosTurma;
