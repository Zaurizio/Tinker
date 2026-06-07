import { useState, useMemo } from "react";
import BarraBusca from "../components/ui/BarraBusca";
import CardTurma from "../components/turma/CardTurma";
import ModalEntrarTurma from "../components/turma/ModalEntrarTurma";
import ModalCriarTurma from "../components/turma/ModalCriarTurma";
import estiloTurma from "./Turma.module.css"

const turmasSimuladas = [
  { id: 1, nome: "Turma de Matemática", criador: "Prof. João Silva", imagem: null, cor: "#2f5d8a" },
  { id: 2, nome: "Biologia — FUVEST", criador: "Ana Souza", imagem: null, cor: "#4a7c6f" },
  { id: 3, nome: "Redação Intensiva", criador: "Carlos Mendes", imagem: null, cor: "#7a5c8a" },
];

function Turma() {
  const [busca, setBusca] = useState("");
  const [modalAberto, setModalAberto] = useState(null); // "entrar" | "criar" | null

  const turmasFiltradas = useMemo(() => {
    const normalizar = (texto) =>
      texto.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
    return turmasSimuladas.filter((t) =>
      normalizar(t.nome).includes(normalizar(busca))
    );
  }, [busca]);

  return (
    <div className={estiloTurma.pagina}>
      <div className={estiloTurma.conteudo}>
        <h1 className={estiloTurma.titulo}>Minhas Turmas</h1>

        <BarraBusca
          placeholder="Pesquisar turma..."
          value={busca}
          onChange={setBusca}
        />

        <div className={estiloTurma.acoes}>
          <button className={estiloTurma.botaoSecundario} onClick={() => setModalAberto("entrar")}>
            Entrar em turma
          </button>
          <button className={estiloTurma.botaoPrimario} onClick={() => setModalAberto("criar")}>
            Criar turma
          </button>
        </div>

        <div className={estiloTurma.listaTurmas}>
          {turmasFiltradas.length > 0 ? (
            turmasFiltradas.map((turma) => (
              <CardTurma key={turma.id} turma={turma} />
            ))
          ) : (
            <div className={estiloTurma.estadoVazio}>Nenhuma turma encontrada.</div>
          )}
        </div>

      </div>

      {modalAberto === "entrar" && (
        <ModalEntrarTurma onFechar={() => setModalAberto(null)} />
      )}
      {modalAberto === "criar" && (
        <ModalCriarTurma onFechar={() => setModalAberto(null)} />
      )}

    </div>
  );
}

export default Turma;