import { useEffect, useMemo, useState } from "react";
import BarraBusca from "../components/ui/BarraBusca";
import CardSimulado from "../components/simulados/CardSimulado";
import ModalCriarSimulado from "../components/simulados/ModalCriarSimulado";
import ModalExcluirSimulado from "../components/simulados/ModalExcluirSimulado";
import ModalRenomearSimulado from "../components/simulados/ModalRenomearSimulado";
import { obterSessao } from "../services/autenticacaoService";
import {
  criarSimuladoVazio,
  excluirSimuladoDoProfessor,
  listarSimuladosDoProfessor,
  renomearSimuladoDoProfessor,
} from "../services/simuladosApiService";
import estiloSimulados from "./Simulados.module.css";

const normalizarTexto = (texto) =>
  texto.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();

function Simulados() {
  const [busca, setBusca] = useState("");
  const [simulados, setSimulados] = useState([]);
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState("");
  const [modalCriarAberto, setModalCriarAberto] = useState(false);
  const [criando, setCriando] = useState(false);
  const [erroCriacao, setErroCriacao] = useState("");
  const [simuladoParaRenomear, setSimuladoParaRenomear] = useState(null);
  const [renomeando, setRenomeando] = useState(false);
  const [erroRenomeacao, setErroRenomeacao] = useState("");
  const [simuladoParaExcluir, setSimuladoParaExcluir] = useState(null);
  const [excluindo, setExcluindo] = useState(false);
  const [erroExclusao, setErroExclusao] = useState("");
  const tipoUsuario = String(obterSessao()?.tipoUsuario ?? "").toUpperCase();
  const eProfessor = tipoUsuario === "PROFESSOR";

  useEffect(() => {
    let componenteMontado = true;

    async function carregarSimulados() {
      if (!eProfessor) {
        if (componenteMontado) setCarregando(false);
        return;
      }

      setCarregando(true);
      setErro("");

      try {
        const simuladosCarregados = await listarSimuladosDoProfessor();
        if (componenteMontado) setSimulados(simuladosCarregados);
      } catch {
        if (componenteMontado) {
          setErro("Não foi possível carregar os simulados. Tente novamente.");
        }
      } finally {
        if (componenteMontado) setCarregando(false);
      }
    }

    carregarSimulados();
    return () => {
      componenteMontado = false;
    };
  }, [eProfessor]);

  const simuladosFiltrados = useMemo(() => {
    const buscaNormalizada = normalizarTexto(busca);
    return simulados.filter((simulado) =>
      normalizarTexto(simulado.titulo).includes(buscaNormalizada)
    );
  }, [busca, simulados]);

  function adicionarOuAtualizarSimulado(simuladoRecebido) {
    setSimulados((simuladosAtuais) => {
      const jaExiste = simuladosAtuais.some(
        (simulado) => simulado.id === simuladoRecebido.id
      );

      return jaExiste
        ? simuladosAtuais.map((simulado) =>
            simulado.id === simuladoRecebido.id ? simuladoRecebido : simulado
          )
        : [...simuladosAtuais, simuladoRecebido];
    });
  }

  async function handleCriar(titulo) {
    if (criando) return;

    setCriando(true);
    setErroCriacao("");

    try {
      const novoSimulado = await criarSimuladoVazio({ titulo });
      adicionarOuAtualizarSimulado(novoSimulado);
      setModalCriarAberto(false);
    } catch (erroCriar) {
      setErroCriacao(
        erroCriar instanceof Error
          ? erroCriar.message
          : "Não foi possível criar o simulado. Tente novamente."
      );
    } finally {
      setCriando(false);
    }
  }

  async function handleRenomear(titulo) {
    if (renomeando || !simuladoParaRenomear) return;

    setRenomeando(true);
    setErroRenomeacao("");

    try {
      const simuladoAtualizado = await renomearSimuladoDoProfessor(
        simuladoParaRenomear.id,
        { titulo }
      );
      adicionarOuAtualizarSimulado(simuladoAtualizado);
      setSimuladoParaRenomear(null);
    } catch (erroRenomear) {
      setErroRenomeacao(
        erroRenomear instanceof Error
          ? erroRenomear.message
          : "Não foi possível renomear o simulado. Tente novamente."
      );
    } finally {
      setRenomeando(false);
    }
  }

  async function handleExcluir() {
    if (excluindo || !simuladoParaExcluir) return;

    setExcluindo(true);
    setErroExclusao("");

    try {
      await excluirSimuladoDoProfessor(simuladoParaExcluir.id);
      setSimulados((simuladosAtuais) =>
        simuladosAtuais.filter(
          (simulado) => simulado.id !== simuladoParaExcluir.id
        )
      );
      setSimuladoParaExcluir(null);
    } catch (erroExcluir) {
      setErroExclusao(
        erroExcluir instanceof Error
          ? erroExcluir.message
          : "Não foi possível excluir o simulado. Tente novamente."
      );
    } finally {
      setExcluindo(false);
    }
  }

  function renderizarLista() {
    if (carregando) {
      return <div className={estiloSimulados.estadoVazio}>Carregando simulados...</div>;
    }
    if (erro) {
      return <div className={estiloSimulados.estadoVazio} role="alert">{erro}</div>;
    }
    if (simulados.length === 0) {
      return <div className={estiloSimulados.estadoVazio}>Você ainda não tem nenhum simulado.</div>;
    }
    if (simuladosFiltrados.length === 0) {
      return <div className={estiloSimulados.estadoVazio}>Nenhum simulado encontrado.</div>;
    }

    return simuladosFiltrados.map((simulado) => (
      <CardSimulado
        key={simulado.id}
        simulado={simulado}
        somenteLeitura
        onRenomear={(simuladoSelecionado) => {
          setErroRenomeacao("");
          setSimuladoParaRenomear(simuladoSelecionado);
        }}
        onExcluir={(simuladoSelecionado) => {
          setErroExclusao("");
          setSimuladoParaExcluir(simuladoSelecionado);
        }}
      />
    ));
  }

  return (
    <div className={estiloSimulados.pagina}>
      <div className={estiloSimulados.conteudo}>
        <h1 className={estiloSimulados.titulo}>Meus Simulados</h1>

        {!eProfessor ? (
          <p className={estiloSimulados.estadoVazio}>
            Os simulados serão acessados pelas turmas quando essa integração estiver disponível.
          </p>
        ) : (
          <>
            <BarraBusca
              placeholder="Pesquisar simulados..."
              value={busca}
              onChange={setBusca}
            />
            <div className={estiloSimulados.acoes}>
              <button
                type="button"
                className={estiloSimulados.botaoCriarSimulado}
                onClick={() => {
                  setErroCriacao("");
                  setModalCriarAberto(true);
                }}
              >
                Criar Simulado
              </button>
            </div>
            <div className={estiloSimulados.listaSimulados}>{renderizarLista()}</div>
          </>
        )}
      </div>

      {eProfessor && modalCriarAberto && (
        <ModalCriarSimulado
          onFechar={() => {
            if (!criando) setModalCriarAberto(false);
          }}
          onSalvar={handleCriar}
          salvando={criando}
          erro={erroCriacao}
        />
      )}

      {eProfessor && simuladoParaRenomear && (
        <ModalRenomearSimulado
          tituloAtual={simuladoParaRenomear.titulo}
          onFechar={() => {
            if (!renomeando) setSimuladoParaRenomear(null);
          }}
          onConfirmar={handleRenomear}
          renomeando={renomeando}
          erro={erroRenomeacao}
        />
      )}

      {eProfessor && simuladoParaExcluir && (
        <ModalExcluirSimulado
          onFechar={() => {
            if (!excluindo) setSimuladoParaExcluir(null);
          }}
          onConfirmar={handleExcluir}
          excluindo={excluindo}
          erro={erroExclusao}
        />
      )}
    </div>
  );
}

export default Simulados;
