import { useMemo, useState } from "react";
import Card from "../ui/Card";
import CampoSelecaoMultipla from "./CampoSelecaoMultipla";
import estiloPainel from "./PainelBuscaQuestoes.module.css";
import { obterConteudosDisponiveis } from "../../utils/opcoesFiltrosQuestoes";

const FILTROS_INICIAIS = {
  disciplinas: [],
  conteudos: [],
  instituicoes: [],
  anos: [],
  trecho: "",
  status: "todas",
};

function formatarErroOpcoes(erro) {
  if (!(erro instanceof Error)) return "Não foi possível carregar as opções de filtro.";
  return erro.codigo ? `${erro.message} (${erro.codigo})` : erro.message;
}

function PainelBuscaQuestoes({
  onBuscarQuestoes,
  opcoesFiltros,
  carregandoOpcoes,
  erroOpcoes,
  onTentarNovamenteOpcoes,
}) {
  const [filtros, setFiltros] = useState(FILTROS_INICIAIS);

  const disciplinasDisponiveis = useMemo(
    () => opcoesFiltros.disciplinas.map((disciplina) => disciplina.nome),
    [opcoesFiltros.disciplinas]
  );
  const conteudosDisponiveis = useMemo(
    () =>
      obterConteudosDisponiveis(opcoesFiltros.disciplinas, filtros.disciplinas),
    [opcoesFiltros.disciplinas, filtros.disciplinas]
  );
  const anosDisponiveis = useMemo(
    () => opcoesFiltros.anos.map(String),
    [opcoesFiltros.anos]
  );

  const [conteudosDisponiveisSincronizados, setConteudosDisponiveisSincronizados] =
    useState(conteudosDisponiveis);
  if (conteudosDisponiveis !== conteudosDisponiveisSincronizados) {
    setConteudosDisponiveisSincronizados(conteudosDisponiveis);
    setFiltros((estadoAtual) => {
      const conteudosValidos = estadoAtual.conteudos.filter((conteudo) =>
        conteudosDisponiveis.includes(conteudo)
      );
      if (conteudosValidos.length === estadoAtual.conteudos.length) {
        return estadoAtual;
      }
      return { ...estadoAtual, conteudos: conteudosValidos };
    });
  }

  function atualizarFiltro(campo, valor) {
    setFiltros((estadoAtual) => ({
      ...estadoAtual,
      [campo]: valor,
    }));
  }

  function limparFiltros() {
    setFiltros(FILTROS_INICIAIS);
  }

  function handleSubmit(event) {
    event.preventDefault();
    onBuscarQuestoes(filtros);
  }

  const placeholderCampos = carregandoOpcoes ? "Carregando..." : "Todas";

  return (
    <Card className={estiloPainel.cardBusca}>
      <form className={estiloPainel.formulario} onSubmit={handleSubmit}>

        {erroOpcoes && (
          <p className={estiloPainel.erroOpcoes} role="alert">
            {formatarErroOpcoes(erroOpcoes)}
            <button
              type="button"
              className={estiloPainel.botaoTentarNovamente}
              onClick={onTentarNovamenteOpcoes}
            >
              Tentar novamente
            </button>
          </p>
        )}

        <div className={estiloPainel.linhaDuasColunas}>
          {/*Disciplinas*/}
          <CampoSelecaoMultipla
            label="Disciplina"
            placeholder={placeholderCampos}
            opcoes={disciplinasDisponiveis}
            selecionadas={filtros.disciplinas}
            onChange={(novasDisciplinas) =>
              atualizarFiltro("disciplinas", novasDisciplinas)
            }
            desabilitado={carregandoOpcoes}
          />

          {/*Conteúdos*/}
          <CampoSelecaoMultipla
            label="Conteúdo"
            placeholder={placeholderCampos}
            opcoes={conteudosDisponiveis}
            selecionadas={filtros.conteudos}
            onChange={(novosConteudos) =>
              atualizarFiltro("conteudos", novosConteudos)
            }
            desabilitado={carregandoOpcoes}
          />
        </div>

        <div className={estiloPainel.linhaDuasColunas}>
          {/*Instituições*/}
          <CampoSelecaoMultipla
            label="Instituição"
            placeholder={placeholderCampos}
            opcoes={opcoesFiltros.vestibulares}
            selecionadas={filtros.instituicoes}
            onChange={(novasInstituicoes) =>
              atualizarFiltro("instituicoes", novasInstituicoes)
            }
            desabilitado={carregandoOpcoes}
          />

          {/*Anos*/}
          <CampoSelecaoMultipla
            label="Anos"
            placeholder={placeholderCampos}
            opcoes={anosDisponiveis}
            selecionadas={filtros.anos}
            onChange={(novosAnos) =>
              atualizarFiltro("anos", novosAnos)
            }
            desabilitado={carregandoOpcoes}
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
              disabled
              title="Disponível quando o histórico de respostas for integrado."
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
              disabled
              title="Disponível quando o histórico de respostas for integrado."
            >
              Não respondi
            </button>
          </div>
          <span className={estiloPainel.avisoStatus}>
            Histórico de respostas em breve.
          </span>
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
