import { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router";
import BarraBusca from "../components/ui/BarraBusca";
import CardSimulado from "../components/simulados/CardSimulado";
import ModalCriarSimulado from "../components/simulados/ModalCriarSimulado";
import ModalExcluirSimulado from "../components/simulados/ModalExcluirSimulado";
import ModalGerarSimulado from "../components/simulados/ModalGerarSimulado";
import ModalRenomearSimulado from "../components/simulados/ModalRenomearSimulado";
import PainelFiltroSimulados from "../components/simulados/PainelFiltroSimulados";
import { obterSessao } from "../services/autenticacaoService";
import {
  criarSimuladoVazio,
  excluirSimuladoDaConta,
  gerarSimuladoDaConta,
  listarSimuladosDaConta,
  renomearSimuladoDaConta,
} from "../services/simuladosApiService";
import estiloSimulados from "./Simulados.module.css";

const normalizarTexto = (texto) =>
  texto.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();

function Simulados() {
  const navigate = useNavigate();
  const [busca, setBusca] = useState("");
  const [simulados, setSimulados] = useState([]);
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState("");
  const [modalCriarAberto, setModalCriarAberto] = useState(false);
  const [criando, setCriando] = useState(false);
  const [erroCriacao, setErroCriacao] = useState("");
  const [painelGeracaoAberto, setPainelGeracaoAberto] = useState(false);
  const [filtrosGeracao, setFiltrosGeracao] = useState(null);
  const [gerando, setGerando] = useState(false);
  const [erroGeracao, setErroGeracao] = useState("");
  const [simuladoParaRenomear, setSimuladoParaRenomear] = useState(null);
  const [renomeando, setRenomeando] = useState(false);
  const [erroRenomeacao, setErroRenomeacao] = useState("");
  const [simuladoParaExcluir, setSimuladoParaExcluir] = useState(null);
  const [excluindo, setExcluindo] = useState(false);
  const [erroExclusao, setErroExclusao] = useState("");
  const tipoUsuario = String(obterSessao()?.tipoUsuario ?? "").toUpperCase();
  const podeAdministrarSimulados = ["ALUNO", "PROFESSOR"].includes(tipoUsuario);

  useEffect(() => {
    let componenteMontado = true;

    async function carregarSimulados() {
      if (!podeAdministrarSimulados) {
        if (componenteMontado) setCarregando(false);
        return;
      }

      setCarregando(true);
      setErro("");

      try {
        const simuladosCarregados = await listarSimuladosDaConta();
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
  }, [podeAdministrarSimulados]);

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
      const simuladoAtualizado = await renomearSimuladoDaConta(
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

  async function handleGerar(titulo) {
    if (gerando || !filtrosGeracao) return;

    setGerando(true);
    setErroGeracao("");

    try {
      const novoSimulado = await gerarSimuladoDaConta({
        titulo,
        ...filtrosGeracao,
      });
      adicionarOuAtualizarSimulado(novoSimulado);
      setFiltrosGeracao(null);
      setPainelGeracaoAberto(false);
    } catch (erroGerar) {
      setErroGeracao(
        erroGerar instanceof Error
          ? erroGerar.message
          : "Não foi possível gerar o simulado. Tente novamente."
      );
    } finally {
      setGerando(false);
    }
  }

  async function handleExcluir() {
    if (excluindo || !simuladoParaExcluir) return;

    setExcluindo(true);
    setErroExclusao("");

    try {
      await excluirSimuladoDaConta(simuladoParaExcluir.id);
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
        onVerQuestoes={(simuladoSelecionado) =>
          navigate(`/simulados/${simuladoSelecionado.id}`)
        }
      />
    ));
  }

  return (
    <div className={estiloSimulados.pagina}>
      <div className={estiloSimulados.conteudo}>
        <h1 className={estiloSimulados.titulo}>Meus Simulados</h1>

        {!podeAdministrarSimulados ? (
          <p className={estiloSimulados.estadoVazio}>
            Esta área não está disponível para este tipo de conta.
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
              <button
                type="button"
                className={estiloSimulados.botaoFiltrarSimulados}
                onClick={() => {
                  setErroGeracao("");
                  setPainelGeracaoAberto((aberto) => !aberto);
                }}
              >
                Gerar Simulado
              </button>
            </div>
            {painelGeracaoAberto && (
              <PainelFiltroSimulados
                onGerarSimulado={(filtros) => {
                  setErroGeracao("");
                  setFiltrosGeracao(filtros);
                }}
              />
            )}
            <div className={estiloSimulados.listaSimulados}>{renderizarLista()}</div>
          </>
        )}
      </div>

      {podeAdministrarSimulados && modalCriarAberto && (
        <ModalCriarSimulado
          onFechar={() => {
            if (!criando) setModalCriarAberto(false);
          }}
          onSalvar={handleCriar}
          salvando={criando}
          erro={erroCriacao}
        />
      )}

      {podeAdministrarSimulados && filtrosGeracao && (
        <ModalGerarSimulado
          quantidadeQuestoes={filtrosGeracao.quantidadeQuestoes}
          onFechar={() => {
            if (!gerando) setFiltrosGeracao(null);
          }}
          onConfirmar={handleGerar}
          gerando={gerando}
          erro={erroGeracao}
        />
      )}

      {podeAdministrarSimulados && simuladoParaRenomear && (
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

      {podeAdministrarSimulados && simuladoParaExcluir && (
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
