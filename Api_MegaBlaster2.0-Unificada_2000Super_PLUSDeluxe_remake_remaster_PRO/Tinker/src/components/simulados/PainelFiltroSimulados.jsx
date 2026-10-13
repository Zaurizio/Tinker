// src/components/simulados/PainelFiltroSimulados.jsx
import { useMemo, useState } from "react";
import Card from "../ui/Card"; // Caminho correto: ../ui/Card
import CampoSelecaoMultipla from "../questoes/CampoSelecaoMultipla"; // Caminho correto: ../questoes/CampoSelecaoMultipla
import estiloPainel from "./PainelFiltroSimulados.module.css"; // Novo CSS para este componente
import { obterConteudosDisponiveis } from "../../utils/opcoesFiltrosQuestoes";

const FILTROS_INICIAIS = {
  disciplinas: [],
  conteudos: [],
  instituicoes: [],
  anos: [],
  quantidadeQuestoes: "", // Novo campo para quantidade de questões
};

function formatarErroOpcoes(erro) {
  if (!(erro instanceof Error)) return "Não foi possível carregar as opções de filtro.";
  return erro.codigo ? `${erro.message} (${erro.codigo})` : erro.message;
}

function PainelFiltroSimulados({
  onGerarSimulado,
  onLimparFiltros,
  opcoesFiltros,
  carregandoOpcoes,
  erroOpcoes,
  onTentarNovamenteOpcoes,
}) {
  const [erroQuantidade, setErroQuantidade] = useState("");
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
    if (campo === "quantidadeQuestoes") setErroQuantidade("");
    setFiltros((estadoAtual) => ({
      ...estadoAtual,
      [campo]: valor,
    }));
  }

  function limparFiltrosInterno() {
    setErroQuantidade("");
    setFiltros(FILTROS_INICIAIS);
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

  const placeholderCampos = carregandoOpcoes ? "Carregando..." : "Todas";
  const geracaoBloqueada = carregandoOpcoes || Boolean(erroOpcoes);

  return (
    <Card className={estiloPainel.cardBusca}>
      <form className={estiloPainel.formulario} onSubmit={handleSubmit}>
        {erroOpcoes && (
          <p className={estiloPainel.erro} role="alert">
            {formatarErroOpcoes(erroOpcoes)}{" "}
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

          {/* Anos e Quantidade de Questões na mesma linha */}
          {/* Usei uma div extra para agrupar Anos e Quantidade de Questões */}
          <div className={estiloPainel.grupoAnosQuantidade}>
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

          <button
            type="submit"
            className={estiloPainel.botaoPrimario}
            disabled={geracaoBloqueada}
          >
            Gerar simulado
          </button>
        </div>
      </form>
    </Card>
  );
}

export default PainelFiltroSimulados;
