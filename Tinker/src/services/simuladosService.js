import { simulados } from "../data/simulados";
import { buscarQuestoes, buscarQuestoesPorIds } from "./questoesService";

const simuladosEmMemoria = simulados.map((simulado) => ({
  ...simulado,
  questoesIds: [],
}));
let proximoId =
  simuladosEmMemoria.reduce(
    (maiorId, simulado) => Math.max(maiorId, Number(simulado.id) || 0),
    0
  ) + 1;

export async function listarSimuladosDoUsuario() {
  return simuladosEmMemoria.map(criarResumoSimulado);
}

function criarResumoSimulado(simulado) {
  const { questoesIds, ...resumo } = simulado;
  void questoesIds;
  return { ...resumo };
}

function localizarSimulado(simuladoId) {
  const idNormalizado = Number(simuladoId);
  const simulado = Number.isInteger(idNormalizado)
    ? simuladosEmMemoria.find((item) => item.id === idNormalizado)
    : null;

  if (!simulado) {
    const erro = new Error("Simulado não encontrado.");
    erro.codigo = "SIMULADO_NAO_ENCONTRADO";
    throw erro;
  }

  return simulado;
}

export async function obterSimuladoPorId(simuladoId) {
  return criarResumoSimulado(localizarSimulado(simuladoId));
}

export async function listarQuestoesDoSimulado(simuladoId) {
  const simulado = localizarSimulado(simuladoId);
  return buscarQuestoesPorIds([...simulado.questoesIds]);
}

export async function renomearSimulado(simuladoId, { titulo }) {
  const simulado = localizarSimulado(simuladoId);
  const tituloNormalizado = typeof titulo === "string" ? titulo.trim() : "";

  if (!tituloNormalizado) {
    throw new Error("Digite um título para o simulado.");
  }

  simulado.titulo = tituloNormalizado;
  return criarResumoSimulado(simulado);
}

export async function excluirSimulado(simuladoId) {
  const simulado = localizarSimulado(simuladoId);
  const indiceSimulado = simuladosEmMemoria.indexOf(simulado);

  simuladosEmMemoria.splice(indiceSimulado, 1);
  return { id: simulado.id };
}

function obterDataAtual() {
  const agora = new Date();
  return [
    agora.getFullYear(),
    String(agora.getMonth() + 1).padStart(2, "0"),
    String(agora.getDate()).padStart(2, "0"),
  ].join("-");
}

export async function criarSimulado({ titulo }) {
  const tituloNormalizado = typeof titulo === "string" ? titulo.trim() : "";

  if (!tituloNormalizado) {
    throw new Error("Digite um título para o simulado.");
  }

  const novoSimulado = {
    id: proximoId,
    titulo: tituloNormalizado,
    dataCriacao: obterDataAtual(),
    quantidadeQuestoes: 0,
    respondidas: 0,
    acertos: 0,
    status: "nao_iniciado",
    questoesIds: [],
  };

  proximoId += 1;
  simuladosEmMemoria.push({ ...novoSimulado });
  return criarResumoSimulado(novoSimulado);
}

export async function gerarSimulado({ titulo, filtros, quantidadeQuestoes }) {
  const tituloNormalizado = typeof titulo === "string" ? titulo.trim() : "";
  const quantidade = Number(quantidadeQuestoes);

  if (!tituloNormalizado) {
    throw new Error("Digite um título para o simulado.");
  }

  if (!Number.isInteger(quantidade) || quantidade < 1 || quantidade > 200) {
    throw new Error("A quantidade de questões deve ser um número inteiro entre 1 e 200.");
  }

  const resultadoBusca = await buscarQuestoes(
    { ...filtros, trecho: "" },
    { pagina: 0, tamanho: quantidade }
  );

  if (resultadoBusca.total === 0) {
    throw new Error("Nenhuma questão encontrada com os filtros informados.");
  }

  if (resultadoBusca.total < quantidade) {
    throw new Error(
      `Existem somente ${resultadoBusca.total} questões disponíveis para esses filtros.`
    );
  }

  const novoSimulado = {
    id: proximoId,
    titulo: tituloNormalizado,
    dataCriacao: obterDataAtual(),
    quantidadeQuestoes: quantidade,
    respondidas: 0,
    acertos: 0,
    status: "nao_iniciado",
    questoesIds: resultadoBusca.itens.map((questao) => questao.id),
  };

  proximoId += 1;
  simuladosEmMemoria.push({ ...novoSimulado, questoesIds: [...novoSimulado.questoesIds] });
  return criarResumoSimulado(novoSimulado);
}

export async function atualizarQuestaoNosSimulados(questaoId, simuladosIds) {
  void questaoId;

  return simuladosIds;
}
