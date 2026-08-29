import { useEffect, useMemo, useRef, useState } from "react";
import {
  listarSimuladosPublicadosNaTurma,
  publicarSimuladoNaTurmaDaConta,
  removerSimuladoPublicadoDaTurma,
} from "../../services/turmasApiService";
import BarraBusca from "../ui/BarraBusca";
import CardSimuladoTurma from "./CardSimuladoTurma";
import ModalConfirmarAcaoTurma from "./ModalConfirmarAcaoTurma";
import ModalPublicarSimulado from "./ModalPublicarSimulado";
import estiloSimulados from "./AbaSimuladosTurma.module.css";

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

function AbaSimuladosTurma({ codigo, usuarioAdministrador, usuarioAluno }) {
  const [busca, setBusca] = useState("");
  const [simulados, setSimulados] = useState([]);
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState("");
  const [modalPublicacaoAberto, setModalPublicacaoAberto] = useState(false);
  const [publicacaoParaRemover, setPublicacaoParaRemover] = useState(null);
  const [removendo, setRemovendo] = useState(false);
  const [erroRemocao, setErroRemocao] = useState("");
  const removendoRef = useRef(false);

  useEffect(() => {
    let carregamentoAtivo = true;

    async function carregarSimulados() {
      setCarregando(true);
      setErro("");

      try {
        const simuladosCarregados =
          await listarSimuladosPublicadosNaTurma(codigo);
        if (carregamentoAtivo) setSimulados(simuladosCarregados);
      } catch (erroCarregamento) {
        if (carregamentoAtivo) {
          setErro(
            formatarErroApi(
              erroCarregamento,
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
  }, [codigo]);

  const simuladosFiltrados = useMemo(() => {
    const buscaNormalizada = normalizarTexto(busca.trim());

    return simulados.filter((simulado) =>
      normalizarTexto(simulado.titulo).includes(buscaNormalizada),
    );
  }, [busca, simulados]);

  async function handlePublicarSimulado(simuladoId) {
    const simuladoPublicado = await publicarSimuladoNaTurmaDaConta(
      codigo,
      simuladoId,
    );

    setSimulados((simuladosAtuais) => [
      simuladoPublicado,
      ...simuladosAtuais.filter(
        (simulado) => simulado.idPublicacao !== simuladoPublicado.idPublicacao,
      ),
    ]);
  }

  async function handleRemoverPublicacao() {
    if (!publicacaoParaRemover || removendoRef.current) return;

    removendoRef.current = true;
    setRemovendo(true);
    setErroRemocao("");

    try {
      await removerSimuladoPublicadoDaTurma(
        codigo,
        publicacaoParaRemover.idPublicacao,
      );
      setSimulados((simuladosAtuais) =>
        simuladosAtuais.filter(
          (simulado) =>
            simulado.idPublicacao !== publicacaoParaRemover.idPublicacao,
        ),
      );
      setPublicacaoParaRemover(null);
    } catch (erroOperacao) {
      setErroRemocao(
        formatarErroApi(
          erroOperacao,
          "Não foi possível retirar o simulado da turma.",
        ),
      );
    } finally {
      removendoRef.current = false;
      setRemovendo(false);
    }
  }

  function renderizarLista() {
    if (carregando) {
      return (
        <div className={estiloSimulados.estado} role="status">
          Carregando simulados...
        </div>
      );
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
      return (
        <div className={estiloSimulados.estado}>
          Nenhum simulado encontrado.
        </div>
      );
    }

    return simuladosFiltrados.map((simulado) => (
      <CardSimuladoTurma
        key={simulado.idPublicacao}
        codigo={codigo}
        simulado={simulado}
        usuarioAdministrador={usuarioAdministrador}
        usuarioAluno={usuarioAluno}
        onRemover={() => {
          setErroRemocao("");
          setPublicacaoParaRemover(simulado);
        }}
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

      {usuarioAdministrador && modalPublicacaoAberto && (
        <ModalPublicarSimulado
          onPublicar={handlePublicarSimulado}
          onFechar={() => setModalPublicacaoAberto(false)}
        />
      )}

      {usuarioAdministrador && publicacaoParaRemover && (
        <ModalConfirmarAcaoTurma
          titulo="Retirar simulado"
          descricao={`Retirar “${publicacaoParaRemover.titulo}” desta turma?`}
          textoConfirmar="Retirar"
          processando={removendo}
          erro={erroRemocao}
          onConfirmar={handleRemoverPublicacao}
          onFechar={() => {
            if (!removendo) setPublicacaoParaRemover(null);
          }}
        />
      )}
    </section>
  );
}

export default AbaSimuladosTurma;
