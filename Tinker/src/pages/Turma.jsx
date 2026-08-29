import { useEffect, useMemo, useRef, useState } from "react";
import BarraBusca from "../components/ui/BarraBusca";
import CardTurma from "../components/turma/CardTurma";
import ModalEntrarTurma from "../components/turma/ModalEntrarTurma";
import ModalCriarTurma from "../components/turma/ModalCriarTurma";
import {
  criarTurmaDaConta,
  entrarEmTurmaDaConta,
  listarTurmasDaConta,
} from "../services/turmasApiService";
import { obterSessao } from "../services/autenticacaoService";
import estiloTurma from "./Turma.module.css";

function formatarErroApi(erro, mensagemPadrao) {
  if (!(erro instanceof Error)) return mensagemPadrao;
  return erro.codigo ? `${erro.message} (${erro.codigo})` : erro.message;
}

function Turma() {
  const [busca, setBusca] = useState("");
  const [modalAberto, setModalAberto] = useState(null); // "entrar" | "criar" | null
  const [turmas, setTurmas] = useState([]);
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState("");
  const componenteMontadoRef = useRef(true);
  const tipoUsuario = String(obterSessao()?.tipoUsuario ?? "").toUpperCase();
  const eProfessor = tipoUsuario === "PROFESSOR";
  const eAluno = tipoUsuario === "ALUNO";

  useEffect(() => {
    let carregamentoAtivo = true;
    componenteMontadoRef.current = true;

    async function carregarTurmas() {
      setCarregando(true);
      setErro("");

      try {
        const turmasCarregadas = await listarTurmasDaConta();
        if (carregamentoAtivo) setTurmas(turmasCarregadas);
      } catch (erroCarregamento) {
        if (carregamentoAtivo) {
          setErro(
            formatarErroApi(
              erroCarregamento,
              "Não foi possível carregar as turmas.",
            ),
          );
        }
      } finally {
        if (carregamentoAtivo) setCarregando(false);
      }
    }

    carregarTurmas();

    return () => {
      carregamentoAtivo = false;
      componenteMontadoRef.current = false;
    };
  }, []);

  const turmasFiltradas = useMemo(() => {
    const normalizar = (texto) =>
      texto.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
    return turmas.filter((t) =>
      normalizar(t.nome).includes(normalizar(busca))
    );
  }, [busca, turmas]);

  async function handleCriarTurma(dadosTurma) {
    const novaTurma = await criarTurmaDaConta(dadosTurma);
    if (!componenteMontadoRef.current) return novaTurma;
    setTurmas((turmasAtuais) => [...turmasAtuais, novaTurma]);
    return novaTurma;
  }

  async function handleEntrarEmTurma(codigo) {
    const turmaIngressada = await entrarEmTurmaDaConta(codigo);
    if (!componenteMontadoRef.current) return turmaIngressada;
    setTurmas((turmasAtuais) =>
      turmasAtuais.some((turma) => turma.codigo === turmaIngressada.codigo)
        ? turmasAtuais
        : [...turmasAtuais, turmaIngressada]
    );
    return turmaIngressada;
  }

  return (
    <div className={estiloTurma.pagina}>
      <div className={estiloTurma.conteudo}>
        <h1 className={estiloTurma.titulo}>Minhas Turmas</h1>

        <BarraBusca
          placeholder="Pesquisar turma..."
          value={busca}
          onChange={setBusca}
        />

        {(eProfessor || eAluno) && (
          <div className={estiloTurma.acoes}>
            {eAluno && (
              <button
                className={estiloTurma.botaoSecundario}
                onClick={() => setModalAberto("entrar")}
              >
                Entrar em turma
              </button>
            )}
            {eProfessor && (
              <button
                className={estiloTurma.botaoPrimario}
                onClick={() => setModalAberto("criar")}
              >
                Criar turma
              </button>
            )}
          </div>
        )}

        <div className={estiloTurma.listaTurmas}>
          {carregando ? (
            <div className={estiloTurma.estadoVazio} role="status">
              Carregando turmas...
            </div>
          ) : erro ? (
            <div className={estiloTurma.estadoVazio} role="alert">
              {erro}
            </div>
          ) : turmasFiltradas.length > 0 ? (
            turmasFiltradas.map((turma) => (
              <CardTurma key={turma.codigo} turma={turma} />
            ))
          ) : (
            <div className={estiloTurma.estadoVazio}>Nenhuma turma encontrada.</div>
          )}
        </div>

      </div>

      {eAluno && modalAberto === "entrar" && (
        <ModalEntrarTurma
          onEntrar={handleEntrarEmTurma}
          onFechar={() => setModalAberto(null)}
        />
      )}
      {eProfessor && modalAberto === "criar" && (
        <ModalCriarTurma
          onCriar={handleCriarTurma}
          onFechar={() => setModalAberto(null)}
        />
      )}

    </div>
  );
}

export default Turma;
