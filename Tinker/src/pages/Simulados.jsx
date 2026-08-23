import { useEffect, useMemo, useRef, useState } from "react";
import { useNavigate } from "react-router";
import BarraBusca from "../components/ui/BarraBusca";
import CardSimulado from "../components/simulados/CardSimulado";
import ModalCriarSimulado from "../components/simulados/ModalCriarSimulado";
import ModalExcluirSimulado from "../components/simulados/ModalExcluirSimulado";
import ModalGerarSimulado from "../components/simulados/ModalGerarSimulado";
import ModalRenomearSimulado from "../components/simulados/ModalRenomearSimulado";
import PainelFiltroSimulados from "../components/simulados/PainelFiltroSimulados";
import {
  criarSimulado,
  excluirSimulado,
  gerarSimulado,
  listarSimuladosDoUsuario,
  renomearSimulado,
} from "../services/simuladosService";
import estiloSimulados from "./Simulados.module.css";

const normalizarTexto = (texto) =>
  texto.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();

function Simulados() {
  const navigate = useNavigate();
  const [busca, setBusca] = useState("");
  const [modalCriarSimuladoAberto, setModalCriarSimuladoAberto] = useState(false);
  const [mostrarPainelFiltro, setMostrarPainelFiltro] = useState(false);
  const [simulados, setSimulados] = useState([]);
  const [carregandoSimulados, setCarregandoSimulados] = useState(true);
  const [erroSimulados, setErroSimulados] = useState(null);
  const [criandoSimulado, setCriandoSimulado] = useState(false);
  const [erroCriacaoSimulado, setErroCriacaoSimulado] = useState(null);
  const [filtrosGeracaoPendentes, setFiltrosGeracaoPendentes] = useState(null);
  const [modalGerarSimuladoAberto, setModalGerarSimuladoAberto] = useState(false);
  const [gerandoSimulado, setGerandoSimulado] = useState(false);
  const [erroGeracaoSimulado, setErroGeracaoSimulado] = useState(null);
  const [simuladoSelecionado, setSimuladoSelecionado] = useState(null);
  const [modalRenomearAberto, setModalRenomearAberto] = useState(false);
  const [renomeandoSimulado, setRenomeandoSimulado] = useState(false);
  const [erroRenomeacao, setErroRenomeacao] = useState(null);
  const [modalExcluirAberto, setModalExcluirAberto] = useState(false);
  const [excluindoSimulado, setExcluindoSimulado] = useState(false);
  const [erroExclusao, setErroExclusao] = useState(null);
  const componenteMontadoRef = useRef(true);
  const criacaoEmAndamentoRef = useRef(false);
  const geracaoEmAndamentoRef = useRef(false);
  const renomeacaoEmAndamentoRef = useRef(false);
  const exclusaoEmAndamentoRef = useRef(false);

  useEffect(() => {
    let componenteMontado = true;
    componenteMontadoRef.current = true;

    async function carregarSimulados() {
      try {
        const simuladosCarregados = await listarSimuladosDoUsuario();
        if (componenteMontado) setSimulados(simuladosCarregados);
      } catch (erro) {
        if (componenteMontado) setErroSimulados(erro);
      } finally {
        if (componenteMontado) setCarregandoSimulados(false);
      }
    }

    carregarSimulados();
    return () => {
      componenteMontado = false;
      componenteMontadoRef.current = false;
    };
  }, []);

  const simuladosFiltrados = useMemo(() => {
    const buscaNormalizada = normalizarTexto(busca);
    return simulados.filter((simulado) =>
      normalizarTexto(simulado.titulo).includes(buscaNormalizada)
    );
  }, [busca, simulados]);

  const handleAbrirSimulado = (simuladoId) => {
    navigate(`/simulados/${simuladoId}`);
  };

  const handleSolicitarRenomeacao = (simulado) => {
    setSimuladoSelecionado(simulado);
    setErroRenomeacao(null);
    setModalRenomearAberto(true);
  };

  const handleFecharRenomeacao = () => {
    if (renomeandoSimulado) return;

    setModalRenomearAberto(false);
    setSimuladoSelecionado(null);
    setErroRenomeacao(null);
  };

  const handleConfirmarRenomeacao = async (titulo) => {
    if (
      renomeandoSimulado ||
      renomeacaoEmAndamentoRef.current ||
      !simuladoSelecionado
    ) return;

    renomeacaoEmAndamentoRef.current = true;
    setRenomeandoSimulado(true);
    setErroRenomeacao(null);

    try {
      const simuladoAtualizado = await renomearSimulado(
        simuladoSelecionado.id,
        { titulo }
      );

      if (componenteMontadoRef.current) {
        adicionarOuAtualizarSimulado(simuladoAtualizado);
        setModalRenomearAberto(false);
        setSimuladoSelecionado(null);
      }
    } catch (erro) {
      if (componenteMontadoRef.current) {
        setErroRenomeacao(
          erro instanceof Error
            ? erro.message
            : "Não foi possível renomear o simulado. Tente novamente."
        );
      }
    } finally {
      renomeacaoEmAndamentoRef.current = false;
      if (componenteMontadoRef.current) setRenomeandoSimulado(false);
    }
  };

  const handleSolicitarExclusao = (simulado) => {
    setSimuladoSelecionado(simulado);
    setErroExclusao(null);
    setModalExcluirAberto(true);
  };

  const handleFecharExclusao = () => {
    if (excluindoSimulado) return;

    setModalExcluirAberto(false);
    setSimuladoSelecionado(null);
    setErroExclusao(null);
  };

  const handleConfirmarExclusao = async () => {
    if (
      excluindoSimulado ||
      exclusaoEmAndamentoRef.current ||
      !simuladoSelecionado
    ) return;

    exclusaoEmAndamentoRef.current = true;
    setExcluindoSimulado(true);
    setErroExclusao(null);

    try {
      const resultado = await excluirSimulado(simuladoSelecionado.id);

      if (componenteMontadoRef.current) {
        setSimulados((simuladosAtuais) =>
          simuladosAtuais.filter((simulado) => simulado.id !== resultado.id)
        );
        setModalExcluirAberto(false);
        setSimuladoSelecionado(null);
      }
    } catch (erro) {
      if (componenteMontadoRef.current) {
        setErroExclusao(
          erro instanceof Error
            ? erro.message
            : "Não foi possível excluir o simulado. Tente novamente."
        );
      }
    } finally {
      exclusaoEmAndamentoRef.current = false;
      if (componenteMontadoRef.current) setExcluindoSimulado(false);
    }
  };

  const handleBaixarSimulado = () => {
    // O download será implementado quando o contrato da API estiver disponível.
  };

  const handleAbrirModalCriacao = () => {
    setErroCriacaoSimulado(null);
    setModalCriarSimuladoAberto(true);
  };

  function adicionarOuAtualizarSimulado(simuladoRecebido) {
    setSimulados((simuladosAtuais) => {
      const simuladoJaExiste = simuladosAtuais.some(
        (simulado) => simulado.id === simuladoRecebido.id
      );

      if (simuladoJaExiste) {
        return simuladosAtuais.map((simulado) =>
          simulado.id === simuladoRecebido.id ? simuladoRecebido : simulado
        );
      }

      return [...simuladosAtuais, simuladoRecebido];
    });
  }

  const handleConfirmarCriacao = async (titulo) => {
    if (criandoSimulado || criacaoEmAndamentoRef.current) return;

    criacaoEmAndamentoRef.current = true;
    setCriandoSimulado(true);
    setErroCriacaoSimulado(null);

    try {
      const novoSimulado = await criarSimulado({ titulo });

      if (componenteMontadoRef.current) {
        adicionarOuAtualizarSimulado(novoSimulado);
        setModalCriarSimuladoAberto(false);
      }
    } catch (erro) {
      if (componenteMontadoRef.current) {
        setErroCriacaoSimulado(
          erro instanceof Error
            ? erro.message
            : "Não foi possível criar o simulado. Tente novamente."
        );
      }
    } finally {
      criacaoEmAndamentoRef.current = false;
      if (componenteMontadoRef.current) setCriandoSimulado(false);
    }
  };

  const handleGerarSimuladoComFiltros = (filtros) => {
    setFiltrosGeracaoPendentes({
      ...filtros,
      disciplinas: [...filtros.disciplinas],
      conteudos: [...filtros.conteudos],
      instituicoes: [...filtros.instituicoes],
      anos: [...filtros.anos],
    });
    setErroGeracaoSimulado(null);
    setModalGerarSimuladoAberto(true);
  };

  const handleFecharModalGeracao = () => {
    if (gerandoSimulado) return;

    setModalGerarSimuladoAberto(false);
    setFiltrosGeracaoPendentes(null);
    setErroGeracaoSimulado(null);
  };

  const handleConfirmarGeracao = async (titulo) => {
    if (
      gerandoSimulado ||
      geracaoEmAndamentoRef.current ||
      !filtrosGeracaoPendentes
    ) return;

    geracaoEmAndamentoRef.current = true;
    setGerandoSimulado(true);
    setErroGeracaoSimulado(null);

    const { quantidadeQuestoes, ...filtros } = filtrosGeracaoPendentes;

    try {
      const novoSimulado = await gerarSimulado({
        titulo,
        filtros,
        quantidadeQuestoes,
      });

      if (componenteMontadoRef.current) {
        adicionarOuAtualizarSimulado(novoSimulado);
        setModalGerarSimuladoAberto(false);
        setFiltrosGeracaoPendentes(null);
        setMostrarPainelFiltro(false);
      }
    } catch (erro) {
      if (componenteMontadoRef.current) {
        setErroGeracaoSimulado(
          erro instanceof Error
            ? erro.message
            : "Não foi possível gerar o simulado. Tente novamente."
        );
      }
    } finally {
      geracaoEmAndamentoRef.current = false;
      if (componenteMontadoRef.current) setGerandoSimulado(false);
    }
  };

  function renderizarListaSimulados() {
    if (carregandoSimulados) {
      return <div className={estiloSimulados.estadoVazio}>Carregando simulados...</div>;
    }
    if (erroSimulados) {
      return (
        <div className={estiloSimulados.estadoVazio}>
          Não foi possível carregar os simulados. Tente novamente.
        </div>
      );
    }
    if (simulados.length === 0) {
      return (
        <div className={estiloSimulados.estadoVazio}>
          Você ainda não tem nenhum simulado.
        </div>
      );
    }
    if (simuladosFiltrados.length === 0) {
      return <div className={estiloSimulados.estadoVazio}>Nenhum simulado encontrado.</div>;
    }
    return simuladosFiltrados.map((simulado) => (
      <CardSimulado
        key={simulado.id}
        simulado={simulado}
        onAbrir={handleAbrirSimulado}
        onRenomear={handleSolicitarRenomeacao}
        onBaixar={handleBaixarSimulado}
        onExcluir={handleSolicitarExclusao}
      />
    ));
  }

  return (
    <div className={estiloSimulados.pagina}>
      <div className={estiloSimulados.conteudo}>
        <h1 className={estiloSimulados.titulo}>Meus Simulados</h1>

        {!mostrarPainelFiltro && (
          <BarraBusca
            placeholder="Pesquisar simulados..."
            value={busca}
            onChange={setBusca}
          />
        )}

        <div className={estiloSimulados.acoes}>
          <button
            className={estiloSimulados.botaoCriarSimulado}
            onClick={handleAbrirModalCriacao}
          >
            Criar Simulado
          </button>
          <button
            className={estiloSimulados.botaoFiltrarSimulados}
            onClick={() => setMostrarPainelFiltro(!mostrarPainelFiltro)}
          >
            {mostrarPainelFiltro ? "Ver Simulados" : "Filtrar Questões"}
          </button>
        </div>

        {mostrarPainelFiltro ? (
          <PainelFiltroSimulados onGerarSimulado={handleGerarSimuladoComFiltros} />
        ) : (
          <div className={estiloSimulados.listaSimulados}>
            {renderizarListaSimulados()}
          </div>
        )}
      </div>

      {modalCriarSimuladoAberto && (
        <ModalCriarSimulado
          onFechar={() => setModalCriarSimuladoAberto(false)}
          onSalvar={handleConfirmarCriacao}
          salvando={criandoSimulado}
          erro={erroCriacaoSimulado}
        />
      )}

      {modalGerarSimuladoAberto && filtrosGeracaoPendentes && (
        <ModalGerarSimulado
          quantidadeQuestoes={filtrosGeracaoPendentes.quantidadeQuestoes}
          onFechar={handleFecharModalGeracao}
          onConfirmar={handleConfirmarGeracao}
          gerando={gerandoSimulado}
          erro={erroGeracaoSimulado}
        />
      )}

      {modalRenomearAberto && simuladoSelecionado && (
        <ModalRenomearSimulado
          tituloAtual={simuladoSelecionado.titulo}
          onFechar={handleFecharRenomeacao}
          onConfirmar={handleConfirmarRenomeacao}
          renomeando={renomeandoSimulado}
          erro={erroRenomeacao}
        />
      )}

      {modalExcluirAberto && simuladoSelecionado && (
        <ModalExcluirSimulado
          onFechar={handleFecharExclusao}
          onConfirmar={handleConfirmarExclusao}
          excluindo={excluindoSimulado}
          erro={erroExclusao}
        />
      )}
    </div>
  );
}

export default Simulados;
