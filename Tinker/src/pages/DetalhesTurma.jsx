import { useEffect, useState } from "react";
import { MdArrowBack, MdGroups } from "react-icons/md";
import { Link, NavLink, useLocation, useParams } from "react-router";
import AbaEventosTurma from "../components/turma/AbaEventosTurma";
import AbaMembrosTurma from "../components/turma/AbaMembrosTurma";
import AbaSimuladosTurma from "../components/turma/AbaSimuladosTurma";
import { obterTurmaPorId } from "../services/turmaService";
import estiloDetalhes from "./DetalhesTurma.module.css";

const CONTEUDO_ABAS = {
  simulados: {
    titulo: "Simulados",
    descricao: "Aqui ficarão os simulados publicados na turma.",
  },
  eventos: {
    titulo: "Eventos",
    descricao: "Aqui ficarão os eventos publicados na turma.",
  },
  membros: {
    titulo: "Membros",
    descricao: "Aqui ficarão os participantes da turma.",
  },
};

function DetalhesTurma() {
  const { turmaId } = useParams();
  const { pathname } = useLocation();
  const [turma, setTurma] = useState(null);
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState("");

  useEffect(() => {
    let carregamentoAtivo = true;

    async function carregarTurma() {
      setCarregando(true);
      setErro("");

      try {
        const turmaCarregada = await obterTurmaPorId(turmaId);
        if (carregamentoAtivo) setTurma(turmaCarregada);
      } catch (erroCarregamento) {
        if (!carregamentoAtivo) return;

        if (
          erroCarregamento.codigo === "TURMA_NAO_ENCONTRADA" ||
          erroCarregamento.codigo === "USUARIO_NAO_PARTICIPA"
        ) {
          setErro(erroCarregamento.message);
        } else {
          setErro("Não foi possível carregar a turma.");
        }
      } finally {
        if (carregamentoAtivo) setCarregando(false);
      }
    }

    carregarTurma();

    return () => {
      carregamentoAtivo = false;
    };
  }, [turmaId]);

  const abaAtual = pathname.split("/").at(-1);
  const conteudoAtual = CONTEUDO_ABAS[abaAtual] ?? CONTEUDO_ABAS.simulados;

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

  const estiloFaixa = turma.imagem
    ? { backgroundColor: turma.cor, backgroundImage: `url(${turma.imagem})` }
    : { backgroundColor: turma.cor };

  return (
    <main className={estiloDetalhes.pagina}>
      <section className={estiloDetalhes.cardPrincipal}>
        <header className={estiloDetalhes.faixa} style={estiloFaixa}>
          <Link
            to="/turma"
            className={estiloDetalhes.voltar}
            aria-label="Voltar para minhas turmas"
          >
            <MdArrowBack aria-hidden="true" />
          </Link>

          <div className={estiloDetalhes.identidadeTurma}>
            <div className={estiloDetalhes.fotoTurma}>
              {turma.imagem ? (
                <img src={turma.imagem} alt="" />
              ) : (
                <MdGroups aria-hidden="true" />
              )}
            </div>
            <h1>{turma.nome}</h1>
          </div>
        </header>

        <nav className={estiloDetalhes.abas} aria-label="Seções da turma">
          {Object.entries(CONTEUDO_ABAS).map(([aba, conteudo]) => (
            <NavLink
              key={aba}
              to={`/turma/${turma.id}/${aba}`}
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
              turmaId={turma.id}
              usuarioAdministrador={turma.usuarioAdministrador}
            />
          ) : abaAtual === "eventos" ? (
            <AbaEventosTurma
              turmaId={turma.id}
              usuarioAdministrador={turma.usuarioAdministrador}
            />
          ) : abaAtual === "membros" ? (
            <AbaMembrosTurma turmaId={turma.id} />
          ) : (
            <>
              <h2>{conteudoAtual.titulo}</h2>
              <p>{conteudoAtual.descricao}</p>
            </>
          )}
        </div>
      </section>
    </main>
  );
}

export default DetalhesTurma;
