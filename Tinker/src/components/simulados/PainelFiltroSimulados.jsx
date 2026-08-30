// src/components/simulados/PainelFiltroSimulados.jsx
import { useState } from "react";
import Card from "../ui/Card"; // Caminho correto: ../ui/Card
import CampoSelecaoMultipla from "../questoes/CampoSelecaoMultipla"; // Caminho correto: ../questoes/CampoSelecaoMultipla
import estiloPainel from "./PainelFiltroSimulados.module.css"; // Novo CSS para este componente

// Importe os dados de filtro. O caminho parece ser ../../data/filtrosQuestoes
import {
  disciplinas,
  conteudos,
  instituicoes,
  anos,
} from "../../data/filtrosQuestoes";

function PainelFiltroSimulados({ onGerarSimulado, onLimparFiltros }) {
  const [erroQuantidade, setErroQuantidade] = useState("");
  const [filtros, setFiltros] = useState({
    disciplinas: [],
    conteudos: [],
    instituicoes: [],
    anos: [],
    quantidadeQuestoes: "", // Novo campo para quantidade de questões
  });

  function atualizarFiltro(campo, valor) {
    if (campo === "quantidadeQuestoes") setErroQuantidade("");
    setFiltros((estadoAtual) => ({
      ...estadoAtual,
      [campo]: valor,
    }));
  }

  function limparFiltrosInterno() {
    setErroQuantidade("");
    setFiltros({
      disciplinas: [],
      conteudos: [],
      instituicoes: [],
      anos: [],
      quantidadeQuestoes: "",
    });
    if (onLimparFiltros) {
      onLimparFiltros(); // Chama a função externa se existir
    }
  }

  function handleSubmit(event) {
    event.preventDefault();
    const quantidadeQuestoes = Number(filtros.quantidadeQuestoes);

    if (
      !Number.isInteger(quantidadeQuestoes) ||
      quantidadeQuestoes < 1 ||
      quantidadeQuestoes > 50
    ) {
      setErroQuantidade("Informe uma quantidade inteira entre 1 e 50");
      return;
    }

    setErroQuantidade("");
    if (onGerarSimulado) {
      onGerarSimulado({
        disciplinas: [...filtros.disciplinas],
        conteudos: [...filtros.conteudos],
        instituicoes: [...filtros.instituicoes],
        anos: [...filtros.anos],
        quantidadeQuestoes,
      });
    }
  }

  return (
    <Card className={estiloPainel.cardBusca}>
      <form className={estiloPainel.formulario} onSubmit={handleSubmit}>
        <p className={estiloPainel.rotuloFiltros}>
          Mostrar apenas questões:
        </p>

        <div className={estiloPainel.linhaDuasColunas}>
          {/*Disciplinas*/}
          <CampoSelecaoMultipla
            label="Disciplina"
            placeholder="Todas"
            opcoes={disciplinas}
            selecionadas={filtros.disciplinas}
            onChange={(novasDisciplinas) =>
              atualizarFiltro("disciplinas", novasDisciplinas)
            }
          />

          {/*Conteúdos*/}
          <CampoSelecaoMultipla
            label="Conteúdo"
            placeholder="Todas"
            opcoes={conteudos}
            selecionadas={filtros.conteudos}
            onChange={(novosConteudos) =>
              atualizarFiltro("conteudos", novosConteudos)
            }
          />
        </div>

        <div className={estiloPainel.linhaDuasColunas}>
          {/*Instituições*/}
          <CampoSelecaoMultipla
            label="Instituição"
            placeholder="Todas"
            opcoes={instituicoes}
            selecionadas={filtros.instituicoes}
            onChange={(novasInstituicoes) =>
              atualizarFiltro("instituicoes", novasInstituicoes)
            }
          />

          {/* Anos e Quantidade de Questões na mesma linha */}
          {/* Usei uma div extra para agrupar Anos e Quantidade de Questões */}
          <div className={estiloPainel.grupoAnosQuantidade}>
            <CampoSelecaoMultipla
              label="Anos"
              placeholder="Todas"
              opcoes={anos}
              selecionadas={filtros.anos}
              onChange={(novosAnos) =>
                atualizarFiltro("anos", novosAnos)
              }
            />
            <div className={estiloPainel.campo}>
              <label htmlFor="quantidadeQuestoes">Número de Questões</label>
              <input
                id="quantidadeQuestoes"
                name="quantidadeQuestoes"
                type="number"
                placeholder="Ex: 20"
                value={filtros.quantidadeQuestoes}
                onChange={(event) =>
                  atualizarFiltro("quantidadeQuestoes", event.target.value)
                }
                min="1"
                max="50"
              />
            </div>
          </div>
        </div>

        {/*Botão de envio e limpar*/}
        {erroQuantidade && (
          <p className={estiloPainel.erro} role="alert">
            {erroQuantidade}
          </p>
        )}

        <div className={estiloPainel.linhaAcoes}>
          <button
            type="button"
            className={estiloPainel.botaoSecundario}
            onClick={limparFiltrosInterno}
          >
            Limpar filtros
          </button>

          <button type="submit" className={estiloPainel.botaoPrimario}>
            Gerar simulado
          </button>
        </div>
      </form>
    </Card>
  );
}

export default PainelFiltroSimulados;
