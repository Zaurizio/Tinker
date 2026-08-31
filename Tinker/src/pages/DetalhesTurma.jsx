import { useEffect, useRef, useState } from "react";
import { MdArrowBack, MdGroups } from "react-icons/md";
import {
  Link,
  NavLink,
  useLocation,
  useNavigate,
  useParams,
} from "react-router";
import AbaMembrosTurma from "../components/turma/AbaMembrosTurma";
import AbaSimuladosTurma from "../components/turma/AbaSimuladosTurma";
import ModalConfiguracoesTurma from "../components/turma/ModalConfiguracoesTurma";
import ModalConfirmarAcaoTurma from "../components/turma/ModalConfirmarAcaoTurma";
import Skeleton from "../components/ui/Skeleton";
import { obterSessao } from "../services/autenticacaoService";
import {
  excluirTurmaDaConta,
  obterTurmaDaConta,
  renomearTurmaDaConta,
  sairDaTurmaDaConta,
} from "../services/turmasApiService";
import { obterCache, definirCache } from "../services/cacheStore";
import { chaveTurma } from "../services/cacheChaves";
import { useEsqueletoAtrasado } from "../hooks/useEsqueletoAtrasado";
import estiloDetalhes from "./DetalhesTurma.module.css";

const CONTEUDO_ABAS = {
  simulados: {
    titulo: "Simulados",
    descricao: "A integração dos simulados da turma será feita na próxima etapa.",
  },
  membros: {
    titulo: "Membros",
    descricao: "Participantes da turma.",
  },
};

function formatarErroApi(erro, mensagemPadrao) {
  if (!(erro instanceof Error)) return mensagemPadrao;
  return erro.codigo ? `${erro.message} (${erro.codigo})` : erro.message;
}

function DetalhesTurma() {
  const { codigo } = useParams();
  const { pathname } = useLocation();
  const navigate = useNavigate();
  const cacheInicial = obterCache(chaveTurma(codigo));
  const [turma, setTurma] = useState(() => cacheInicial ?? null);
  const [carregando, setCarregando] = useState(() => cacheInicial === undefined);
  const [erro, setErro] = useState("");
  const mostrarEsqueleto = useEsqueletoAtrasado(carregando);
  const [acaoConfirmacao, setAcaoConfirmacao] = useState(null);
  const [processando, setProcessando] = useState(false);
  const [erroOperacao, setErroOperacao] = useState("");
  const [modalSimuladoAberto, setModalSimuladoAberto] = useState(false);
  const [modalConfiguracoesAberto, setModalConfiguracoesAberto] =
    useState(false);
  const processandoRef = useRef(false);
  const tipoUsuario = String(obterSessao()?.tipoUsuario ?? "").toUpperCase();
  const eProfessor = tipoUsuario === "PROFESSOR";
  const eAluno = tipoUsuario === "ALUNO";

  useEffect(() => {
    let carregamentoAtivo = true;

    async function carregarTurma() {
      const chave = chaveTurma(codigo);
      const emCache = obterCache(chave);
      if (emCache) {
        setTurma(emCache);
        setCarregando(false);
      } else {
        setCarregando(true);
      }
      setErro("");

      try {
        const turmaCarregada = await obterTurmaDaConta(codigo);
        if (carregamentoAtivo) {
          setTurma(turmaCarregada);
          definirCache(chave, turmaCarregada);
        }
      } catch (erroCarregamento) {
        if (carregamentoAtivo && !emCache) {
          setErro(
            formatarErroApi(
              erroCarregamento,
              "Não foi possível carregar a turma.",
            ),
          );
        }
      } finally {
        if (carregamentoAtivo) setCarregando(false);
      }
    }

    carregarTurma();
    return () => {
      carregamentoAtivo = false;
    };
  }, [codigo]);

  const abaAtual = pathname.split("/").at(-1);
  const conteudoAtual = CONTEUDO_ABAS[abaAtual] ?? CONTEUDO_ABAS.simulados;

  function handleAbrirAdicionarSimulado() {
    if (abaAtual !== "simulados") {
      navigate(`/turma/${codigo}/simulados`);
    }
    setModalSimuladoAberto(true);
  }

  async function handleRenomear(novoNome) {
    const turmaAtualizada = await renomearTurmaDaConta(codigo, novoNome);
    setTurma(turmaAtualizada);
    definirCache(chaveTurma(codigo), turmaAtualizada);
  }

  function handleSolicitarExclusaoPelasConfiguracoes() {
    setModalConfiguracoesAberto(false);
    setErroOperacao("");
    setAcaoConfirmacao("excluir");
  }

  async function handleConfirmarAcao() {
    if (!acaoConfirmacao || processandoRef.current) return;

    processandoRef.current = true;
    setProcessando(true);
    setErroOperacao("");

    try {
      if (acaoConfirmacao === "excluir") {
        await excluirTurmaDaConta(codigo);
      } else {
        await sairDaTurmaDaConta(codigo);
      }
      navigate("/turma", { replace: true });
    } catch (erroAcao) {
      setErroOperacao(
        formatarErroApi(erroAcao, "Não foi possível concluir a operação."),
      );
      processandoRef.current = false;
      setProcessando(false);
    }
  }

  if (carregando) {
    if (!mostrarEsqueleto) {
      return <main className={estiloDetalhes.pagina} />;
    }

    return (
      <main className={estiloDetalhes.pagina}>
        <section className={estiloDetalhes.cardPrincipal} aria-hidden="true">
          <div
            className={estiloDetalhes.faixa}
            style={{ background: "var(--cor-fundo-hover)" }}
          >
            <div className={estiloDetalhes.topoFaixa}>
              <Skeleton width="42px" height="42px" radius="50%" />
            </div>
            <div className={estiloDetalhes.cabecalhoConteudo}>
              <div className={estiloDetalhes.identidadeTurma}>
                <Skeleton width="82px" height="82px" radius="50%" style={{ flexShrink: 0 }} />
                <Skeleton height="2rem" width="260px" />
              </div>
            </div>
          </div>

          <nav className={estiloDetalhes.abas} aria-hidden="true">
            <Skeleton width="80px" height="1rem" style={{ alignSelf: "center" }} />
            <Skeleton width="80px" height="1rem" style={{ alignSelf: "center" }} />
          </nav>

          <div className={estiloDetalhes.conteudoAba}>
            <Skeleton height="1rem" width="40%" style={{ marginBottom: 12 }} />
            <Skeleton height="1rem" width="60%" />
          </div>
        </section>
      </main>
    );
  }

  if (erro) {
    return (
      <main className={estiloDetalhes.pagina}>
        <div className={estiloDetalhes.estado} role="alert">
          <p>{erro}</p>
          <Link to="/turma" className={estiloDetalhes.linkRetorno}>
            Voltar para minhas turmas
          </Link>
        </div>
      </main>
    );
  }

  return (
    <main className={estiloDetalhes.pagina}>
      <section className={estiloDetalhes.cardPrincipal}>
        <header
          className={estiloDetalhes.faixa}
          style={{ backgroundColor: turma.cor }}
        >
          <div className={estiloDetalhes.topoFaixa}>
            <Link
              to="/turma"
              className={estiloDetalhes.voltar}
              aria-label="Voltar para minhas turmas"
            >
              <MdArrowBack aria-hidden="true" />
            </Link>

            {eProfessor && (
              <div className={estiloDetalhes.codigoTurma}>
                <span>Código</span>
                <strong>{turma.codigo}</strong>
              </div>
            )}
          </div>

          <div className={estiloDetalhes.cabecalhoConteudo}>
            <div className={estiloDetalhes.identidadeTurma}>
              <div className={estiloDetalhes.fotoTurma}>
                <MdGroups aria-hidden="true" />
              </div>
              <h1>{turma.nome}</h1>
            </div>

            {eProfessor && (
              <div className={estiloDetalhes.acoesTurma}>
                <button
                  type="button"
                  className={estiloDetalhes.botaoSecundario}
                  onClick={handleAbrirAdicionarSimulado}
                >
                  Adicionar simulado
                </button>
                <button
                  type="button"
                  className={estiloDetalhes.botaoSecundario}
                  onClick={() => setModalConfiguracoesAberto(true)}
                >
                  Configurações
                </button>
              </div>
            )}

            {eAluno && (
              <div className={estiloDetalhes.acoesTurma}>
                <button
                  type="button"
                  className={estiloDetalhes.botaoDestrutivo}
                  onClick={() => {
                    setErroOperacao("");
                    setAcaoConfirmacao("sair");
                  }}
                  disabled={processando}
                >
                  Sair da turma
                </button>
              </div>
            )}
          </div>
        </header>

        <nav className={estiloDetalhes.abas} aria-label="Seções da turma">
          {Object.entries(CONTEUDO_ABAS).map(([aba, conteudo]) => (
            <NavLink
              key={aba}
              to={`/turma/${turma.codigo}/${aba}`}
              className={({ isActive }) =>
                `${estiloDetalhes.aba} ${isActive ? estiloDetalhes.abaAtiva : ""}`
              }
            >
              {conteudo.titulo}
            </NavLink>
          ))}
        </nav>

        <div className={estiloDetalhes.conteudoAba}>
          {abaAtual === "simulados" ? (
            <AbaSimuladosTurma
              codigo={turma.codigo}
              usuarioAdministrador={eProfessor}
              usuarioAluno={eAluno}
              modalPublicacaoAberto={modalSimuladoAberto}
              onFecharModalPublicacao={() => setModalSimuladoAberto(false)}
            />
          ) : abaAtual === "membros" ? (
            <AbaMembrosTurma
              codigo={turma.codigo}
              usuarioAdministrador={eProfessor}
              professorCriador={turma.criador}
              fotoProfessorCriador={turma.fotoCriador}
            />
          ) : (
            <>
              <h2>{conteudoAtual.titulo}</h2>
              <p>{conteudoAtual.descricao}</p>
            </>
          )}
        </div>
      </section>

      {eProfessor && modalConfiguracoesAberto && (
        <ModalConfiguracoesTurma
          turma={turma}
          onFechar={() => setModalConfiguracoesAberto(false)}
          onRenomear={handleRenomear}
          onSolicitarExclusao={handleSolicitarExclusaoPelasConfiguracoes}
        />
      )}

      {acaoConfirmacao && (
        <ModalConfirmarAcaoTurma
          titulo={eProfessor ? "Excluir turma" : "Sair da turma"}
          descricao={
            eProfessor
              ? "Tem certeza que deseja excluir esta turma?"
              : "Tem certeza que deseja sair desta turma?"
          }
          textoConfirmar={eProfessor ? "Excluir" : "Sair"}
          processando={processando}
          erro={erroOperacao}
          onConfirmar={handleConfirmarAcao}
          onFechar={() => {
            if (!processando) setAcaoConfirmacao(null);
          }}
        />
      )}
    </main>
  );
}

export default DetalhesTurma;
