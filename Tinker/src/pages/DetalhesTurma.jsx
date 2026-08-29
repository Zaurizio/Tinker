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
import ModalConfirmarAcaoTurma from "../components/turma/ModalConfirmarAcaoTurma";
import { obterSessao } from "../services/autenticacaoService";
import {
  excluirTurmaDaConta,
  obterTurmaDaConta,
  sairDaTurmaDaConta,
} from "../services/turmasApiService";
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
  const [turma, setTurma] = useState(null);
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState("");
  const [acaoConfirmacao, setAcaoConfirmacao] = useState(null);
  const [processando, setProcessando] = useState(false);
  const [erroOperacao, setErroOperacao] = useState("");
  const processandoRef = useRef(false);
  const tipoUsuario = String(obterSessao()?.tipoUsuario ?? "").toUpperCase();
  const eProfessor = tipoUsuario === "PROFESSOR";
  const eAluno = tipoUsuario === "ALUNO";

  useEffect(() => {
    let carregamentoAtivo = true;

    async function carregarTurma() {
      setCarregando(true);
      setErro("");

      try {
        const turmaCarregada = await obterTurmaDaConta(codigo);
        if (carregamentoAtivo) setTurma(turmaCarregada);
      } catch (erroCarregamento) {
        if (carregamentoAtivo) {
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
    return (
      <main className={estiloDetalhes.pagina}>
        <div className={estiloDetalhes.estado} role="status">
          Carregando turma...
        </div>
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
          <Link
            to="/turma"
            className={estiloDetalhes.voltar}
            aria-label="Voltar para minhas turmas"
          >
            <MdArrowBack aria-hidden="true" />
          </Link>

          <div className={estiloDetalhes.identidadeTurma}>
            <div className={estiloDetalhes.fotoTurma}>
              <MdGroups aria-hidden="true" />
            </div>
            <h1>{turma.nome}</h1>
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

        {(eProfessor || eAluno) && (
          <div className={estiloDetalhes.acoesTurma}>
            <button
              type="button"
              className={estiloDetalhes.botaoDestrutivo}
              onClick={() => {
                setErroOperacao("");
                setAcaoConfirmacao(eProfessor ? "excluir" : "sair");
              }}
              disabled={processando}
            >
              {eProfessor ? "Excluir turma" : "Sair da turma"}
            </button>
          </div>
        )}

        <div className={estiloDetalhes.conteudoAba}>
          {abaAtual === "simulados" ? (
            <AbaSimuladosTurma
              codigo={turma.codigo}
              usuarioAdministrador={eProfessor}
            />
          ) : abaAtual === "membros" ? (
            <AbaMembrosTurma
              codigo={turma.codigo}
              usuarioAdministrador={eProfessor}
            />
          ) : (
            <>
              <h2>{conteudoAtual.titulo}</h2>
              <p>{conteudoAtual.descricao}</p>
            </>
          )}
        </div>
      </section>

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
