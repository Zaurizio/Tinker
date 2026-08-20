import { useState } from "react";
import Card from "../ui/Card";
import CampoSelecaoMultipla from "./CampoSelecaoMultipla";
import estiloPainel from "./PainelBuscaQuestoes.module.css";
import {
  disciplinas,
  conteudos,
  instituicoes,
  anos,
} from "../../data/filtrosQuestoes";

function PainelBuscaQuestoes({ onBuscarQuestoes }) {
  const [filtros, setFiltros] = useState({
    disciplinas: [],
    conteudos: [],
    instituicoes: [],
    anos: [],
    trecho: "",
    status: "todas",
  });

  function atualizarFiltro(campo, valor) {
    setFiltros((estadoAtual) => ({
      ...estadoAtual,
      [campo]: valor,
    }));
  } {/*o que caralhos isso significa*/}

  function limparFiltros() {
    setFiltros({
      disciplinas: [],
      conteudos: [],
      instituicoes: [],
      anos: [],
      trecho: "",
      status: "todas",
    });
  }

  function handleSubmit(event) {
    event.preventDefault();
    onBuscarQuestoes(filtros);
  }

  return (
    <Card className={estiloPainel.cardBusca}>
      <form className={estiloPainel.formulario} onSubmit={handleSubmit}>
        
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

          {/*Anos*/}
          <CampoSelecaoMultipla
            label="Anos"
            placeholder="Todas"
            opcoes={anos}
            selecionadas={filtros.anos}
            onChange={(novosAnos) =>
              atualizarFiltro("anos", novosAnos)
            }
          />
          
        </div>

        <div className={estiloPainel.linhaCompleta}>
          {/*Trecho da questão*/}
          <div className={estiloPainel.campo}>
            <label htmlFor="trecho">Trecho da questão</label>
            <input
              id="trecho"
              name="trecho"
              type="text"
              placeholder="Digite um trecho da questão"
              value={filtros.trecho}
              onChange={(event) =>
                atualizarFiltro("trecho", event.target.value)
              }
            />
          </div>
        </div>

        {/*Botões*/}
        <div className={estiloPainel.linhaStatus}>
          <span className={estiloPainel.rotuloStatus}>
            Mostrar apenas questões:
          </span>

          <div className={estiloPainel.grupoBotoesStatus}>
            <button
              type="button"
              className={`${estiloPainel.botaoStatus} ${
                filtros.status === "todas" ? estiloPainel.botaoStatusAtivo : ""
              }`}
              onClick={() => atualizarFiltro("status", "todas")}
            >
              Todas
            </button>

            <button
              type="button"
              className={`${estiloPainel.botaoStatus} ${
                filtros.status === "jaRespondi"
                  ? estiloPainel.botaoStatusAtivo
                  : ""
              }`}
              onClick={() => atualizarFiltro("status", "jaRespondi")}
            >
              Já respondi
            </button>

            <button
              type="button"
              className={`${estiloPainel.botaoStatus} ${
                filtros.status === "naoRespondi"
                  ? estiloPainel.botaoStatusAtivo
                  : ""
              }`}
              onClick={() => atualizarFiltro("status", "naoRespondi")}
            >
              Não respondi
            </button>
          </div>
        </div>

        {/*Botão de envio e limpar*/}
        <div className={estiloPainel.linhaAcoes}>
          <button
            type="button"
            className={estiloPainel.botaoSecundario}
            onClick={limparFiltros}
          >
            Limpar filtros
          </button>

          <button type="submit" className={estiloPainel.botaoPrimario}>
            Buscar questões
          </button>
        </div>
      </form>
    </Card>
  );
}

export default PainelBuscaQuestoes;
