import { useState, useMemo } from "react";
import BarraBusca from "../components/ui/BarraBusca";
import CardSimulado from "../components/simulados/CardSimulado";

import ModalCriarSimulado from "../components/simulados/ModalCriarSimulado";
import PainelFiltroSimulados from "../components/simulados/PainelFiltroSimulados";

import estiloSimulados from "./Simulados.module.css"

// Simulados de exemplo iniciais
const simuladosExemplo = [ // Use simuladosExemplo, não simuladosIniciais
  { id: 1, nome: "Simulado ENEM 2023", criador: "Prof. Ana", cor: "#ff7f50" },
  { id: 2, nome: "Simulado Fuvest - Matemática", criador: "Prof. Carlos", cor: "#6a5acd" },
  { id: 3, nome: "Simulado de Física - Ondas", criador: "Prof. João", cor: "#8a2be2" },
  { id: 4, nome: "Simulado de História - Brasil Colônia", criador: "Prof. Lúcia", cor: "#008b8b" },
];

function Simulados() {
  const [busca, setBusca] = useState("");
  const [modalCriarSimuladoAberto, setModalCriarSimuladoAberto] = useState(false);
  const [mostrarPainelFiltro, setMostrarPainelFiltro] = useState(false);
  const [meusSimulados, setMeusSimulados] = useState(simuladosExemplo); // CORREÇÃO AQUI: Usar simuladosExemplo

  const simuladosFiltrados = useMemo(() => {
    if (mostrarPainelFiltro) return [];

    const normalizar = (texto) =>
      texto.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
    return meusSimulados.filter((s) =>
      normalizar(s.nome).includes(normalizar(busca))
    );
  }, [busca, mostrarPainelFiltro, meusSimulados]);

  const handleCriarNovoSimulado = (nomeSimulado) => {
    const novoId = Math.max(...meusSimulados.map(s => s.id), 0) + 1;
    const coresDisponiveis = ["#ff7f50", "#6a5acd", "#20b2aa", "#8a2be2", "#008b8b", "#ff6347", "#4682b4"];
    const corAleatoria = coresDisponiveis[Math.floor(Math.random() * coresDisponiveis.length)];

    const novoSimulado = {
      id: novoId,
      nome: nomeSimulado,
      criador: "Você",
      cor: corAleatoria,
    };

    setMeusSimulados(prevSimulados => [...prevSimulados, novoSimulado]);
    setModalCriarSimuladoAberto(false);
    console.log("Novo simulado criado:", novoSimulado);
  };

  const handleGerarSimuladoComFiltros = (filtros) => {
    console.log("Gerar simulado com filtros:", filtros);
    setMostrarPainelFiltro(false);
  };

  const handleLimparFiltrosSimulados = () => {
    console.log("Filtros de simulado limpos.");
  };

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
            onClick={() => setModalCriarSimuladoAberto(true)}
          >
            Criar Simulado {/* Ícone removido */}
          </button>
          <button
            className={estiloSimulados.botaoFiltrarSimulados}
            onClick={() => setMostrarPainelFiltro(!mostrarPainelFiltro)}
          >
            {mostrarPainelFiltro ? 'Ver Simulados' : 'Filtrar Questões'} {/* Ícone removido */}
          </button>
        </div>

        {mostrarPainelFiltro ? (
          <PainelFiltroSimulados
            onGerarSimulado={handleGerarSimuladoComFiltros}
            onLimparFiltros={handleLimparFiltrosSimulados}
          />
        ) : (
          <div className={estiloSimulados.listaSimulados}>
            {simuladosFiltrados.length > 0 ? (
              simuladosFiltrados.map((simulado) => (
                <CardSimulado key={simulado.id} simulado={simulado} />
              ))
            ) : (
              <div className={estiloSimulados.estadoVazio}>Nenhum simulado encontrado.</div>
            )}
          </div>
        )}
      </div>

      {modalCriarSimuladoAberto && (
        <ModalCriarSimulado
          onFechar={() => setModalCriarSimuladoAberto(false)}
          onSalvar={handleCriarNovoSimulado}
        />
      )}
    </div>
  );
}

export default Simulados;