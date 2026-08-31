import { useEffect, useMemo, useRef, useState } from "react";
import {
  listarSimuladosPublicadosNaTurma,
  publicarSimuladoNaTurmaDaConta,
  removerSimuladoPublicadoDaTurma,
} from "../../services/turmasApiService";
import BarraBusca from "../ui/BarraBusca";
import CardSimuladoTurma from "./CardSimuladoTurma";
import CardSimuladoTurmaSkeleton from "./CardSimuladoTurmaSkeleton";
import ModalConfirmarAcaoTurma from "./ModalConfirmarAcaoTurma";
import ModalPublicarSimulado from "./ModalPublicarSimulado";
import { obterCache, definirCache } from "../../services/cacheStore";
import { chaveSimuladosTurma } from "../../services/cacheChaves";
import { useEsqueletoAtrasado } from "../../hooks/useEsqueletoAtrasado";
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

function AbaSimuladosTurma({
  codigo,
  usuarioAdministrador,
  usuarioAluno,
  modalPublicacaoAberto,
  onFecharModalPublicacao,
}) {
  const cacheInicial = obterCache(chaveSimuladosTurma(codigo));
  const [busca, setBusca] = useState("");
  const [simulados, setSimulados] = useState(() => cacheInicial ?? []);
  const [carregando, setCarregando] = useState(() => cacheInicial === undefined);
  const [erro, setErro] = useState("");
  const [publicacaoParaRemover, setPublicacaoParaRemover] = useState(null);
  const [removendo, setRemovendo] = useState(false);
  const [erroRemocao, setErroRemocao] = useState("");
  const removendoRef = useRef(false);
  const mostrarEsqueleto = useEsqueletoAtrasado(carregando);

  useEffect(() => {
    let carregamentoAtivo = true;

    async function carregarSimulados() {
      const chave = chaveSimuladosTurma(codigo);
      const emCache = obterCache(chave);
      if (emCache) {
        setSimulados(emCache);
        setCarregando(false);
      } else {
        setCarregando(true);
      }
      setErro("");

      try {
        const simuladosCarregados =
          await listarSimuladosPublicadosNaTurma(codigo);
        if (carregamentoAtivo) {
          setSimulados(simuladosCarregados);
          definirCache(chave, simuladosCarregados);
        }
      } catch (erroCarregamento) {
        if (carregamentoAtivo && !emCache) {
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

    setSimulados((simuladosAtuais) => {
      const simuladosAtualizados = [
        simuladoPublicado,
        ...simuladosAtuais.filter(
          (simulado) => simulado.idPublicacao !== simuladoPublicado.idPublicacao,
        ),
      ];
      definirCache(chaveSimuladosTurma(codigo), simuladosAtualizados);
      return simuladosAtualizados;
    });
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
      setSimulados((simuladosAtuais) => {
        const simuladosAtualizados = simuladosAtuais.filter(
          (simulado) =>
            simulado.idPublicacao !== publicacaoParaRemover.idPublicacao,
        );
        definirCache(chaveSimuladosTurma(codigo), simuladosAtualizados);
        return simuladosAtualizados;
      });
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
      return mostrarEsqueleto ? (
        <>
          <CardSimuladoTurmaSkeleton />
          <CardSimuladoTurmaSkeleton />
          <CardSimuladoTurmaSkeleton />
        </>
      ) : null;
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
          onFechar={onFecharModalPublicacao}
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
