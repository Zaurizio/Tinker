import { useEffect, useMemo, useRef, useState } from "react";
import BarraBusca from "../ui/BarraBusca";
import {
  adicionarSimuladoDaTurmaAosMeus,
  listarSimuladosDaTurma,
  publicarSimuladoNaTurma,
} from "../../services/turmaService";
import CardSimuladoTurma from "./CardSimuladoTurma";
import ModalPublicarSimulado from "./ModalPublicarSimulado";
import estiloSimulados from "./AbaSimuladosTurma.module.css";

function normalizarTexto(texto) {
  return texto
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase();
}

function AbaSimuladosTurma({ turmaId, usuarioAdministrador }) {
  const [busca, setBusca] = useState("");
  const [simulados, setSimulados] = useState([]);
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

    async function carregarSimulados() {
      setCarregando(true);
      setErro("");

      try {
        const simuladosCarregados = await listarSimuladosDaTurma(turmaId);
        if (carregamentoAtivo) setSimulados(simuladosCarregados);
      } catch {
        if (carregamentoAtivo) {
          setErro("Não foi possível carregar os simulados.");
        }
      } finally {
        if (carregamentoAtivo) setCarregando(false);
      }
    }

    carregarSimulados();

    return () => {
      carregamentoAtivo = false;
    };
  }, [turmaId]);

  const simuladosFiltrados = useMemo(() => {
    const buscaNormalizada = normalizarTexto(busca.trim());

    return simulados.filter((simulado) =>
      normalizarTexto(simulado.titulo).includes(buscaNormalizada)
    );
  }, [busca, simulados]);

  async function handlePublicarSimulado(simuladoId) {
    const simuladoPublicado = await publicarSimuladoNaTurma(turmaId, simuladoId);

    if (!componenteMontadoRef.current) return;

    setSimulados((simuladosAtuais) =>
      simuladosAtuais.some(
        (simulado) => simulado.idPublicacao === simuladoPublicado.idPublicacao
      )
        ? simuladosAtuais
        : [...simuladosAtuais, simuladoPublicado]
    );
  }

  async function handleAdicionarAosMeus(publicacaoId) {
    const resultado = await adicionarSimuladoDaTurmaAosMeus(publicacaoId);

    if (!componenteMontadoRef.current) return resultado;

    setSimulados((simuladosAtuais) =>
      simuladosAtuais.map((simulado) =>
        simulado.idPublicacao === publicacaoId
          ? { ...simulado, salvoPeloUsuario: true }
          : simulado
      )
    );

    return resultado;
  }

  function renderizarLista() {
    if (carregando) {
      return <div className={estiloSimulados.estado} role="status">Carregando simulados...</div>;
    }

    if (erro) {
      return (
        <div className={estiloSimulados.estado} role="alert">
          {erro}
        </div>
      );
    }

    if (simulados.length === 0) {
      return (
        <div className={estiloSimulados.estado}>
          Nenhum simulado foi publicado nesta turma.
        </div>
      );
    }

    if (simuladosFiltrados.length === 0) {
      return <div className={estiloSimulados.estado}>Nenhum simulado encontrado.</div>;
    }

    return simuladosFiltrados.map((simulado) => (
      <CardSimuladoTurma
        key={simulado.idPublicacao}
        simulado={simulado}
        onAdicionar={handleAdicionarAosMeus}
      />
    ));
  }

  return (
    <section aria-labelledby="titulo-simulados-turma">
      <div className={estiloSimulados.cabecalho}>
        <div>
          <h2 id="titulo-simulados-turma">Simulados</h2>
          <p>Simulados publicados para esta turma.</p>
        </div>

        {usuarioAdministrador && (
          <button
            type="button"
            className={estiloSimulados.botaoNovo}
            onClick={() => setModalPublicacaoAberto(true)}
          >
            + Novo simulado
          </button>
        )}
      </div>

      <div className={estiloSimulados.busca}>
        <BarraBusca
          placeholder="Pesquisar simulados..."
          value={busca}
          onChange={setBusca}
        />
      </div>

      <div className={estiloSimulados.lista}>{renderizarLista()}</div>

      {modalPublicacaoAberto && (
        <ModalPublicarSimulado
          onPublicar={handlePublicarSimulado}
          onFechar={() => setModalPublicacaoAberto(false)}
        />
      )}
    </section>
  );
}

export default AbaSimuladosTurma;
