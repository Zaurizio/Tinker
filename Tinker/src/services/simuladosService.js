import { simulados } from "../data/simulados";
import { usuarioAtual } from "../data/usuario";
import { buscarQuestoes, buscarQuestoesPorIds } from "./questoesService";

const simuladosEmMemoria = simulados.map((simulado) => ({
  ...simulado,
  questoesIds: [...(simulado.questoesIds ?? [])],
}));
let proximoId =
  simuladosEmMemoria.reduce(
    (maiorId, simulado) => Math.max(maiorId, Number(simulado.id) || 0),
    0
  ) + 1;

export async function listarSimuladosDoUsuario() {
  return simuladosEmMemoria
    .filter((simulado) => simulado.proprietarioUsuarioId === usuarioAtual.id)
    .map(criarResumoSimulado);
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

function localizarSimuladoDoUsuario(simuladoId) {
  const simulado = localizarSimulado(simuladoId);

  if (simulado.proprietarioUsuarioId !== usuarioAtual.id) {
    const erro = new Error("Simulado não encontrado.");
    erro.codigo = "SIMULADO_NAO_ENCONTRADO";
    throw erro;
  }

  return simulado;
}

export async function obterSimuladoPorId(simuladoId) {
  return criarResumoSimulado(localizarSimuladoDoUsuario(simuladoId));
}

export async function obterSimuladoDoUsuarioPorId(simuladoId) {
  return criarResumoSimulado(localizarSimuladoDoUsuario(simuladoId));
}

export async function obterSimuladoPublicadoPorId(simuladoId) {
  return criarResumoSimulado(localizarSimulado(simuladoId));
}

export async function encontrarSimuladoSalvoDoUsuario({
  simuladoOrigemId,
  publicacaoTurmaId,
}) {
  const origemIdNormalizado = Number(simuladoOrigemId);
  const publicacaoIdNormalizado = Number(publicacaoTurmaId);

  if (!Number.isInteger(origemIdNormalizado)) return null;

  const simulado = simuladosEmMemoria.find(
    (item) =>
      item.proprietarioUsuarioId === usuarioAtual.id &&
      (item.id === origemIdNormalizado ||
        Number(item.simuladoOrigemId) === origemIdNormalizado ||
        (Number.isInteger(publicacaoIdNormalizado) &&
          Number(item.publicacaoTurmaId) === publicacaoIdNormalizado))
  );

  return simulado ? criarResumoSimulado(simulado) : null;
}

export async function listarQuestoesDoSimulado(simuladoId) {
  const simulado = localizarSimuladoDoUsuario(simuladoId);
  return buscarQuestoesPorIds([...simulado.questoesIds]);
}

export async function renomearSimulado(simuladoId, { titulo }) {
  const simulado = localizarSimuladoDoUsuario(simuladoId);
  const tituloNormalizado = typeof titulo === "string" ? titulo.trim() : "";

  if (!tituloNormalizado) {
    throw new Error("Digite um título para o simulado.");
  }

  simulado.titulo = tituloNormalizado;
  return criarResumoSimulado(simulado);
}

export async function excluirSimulado(simuladoId) {
  const simulado = localizarSimuladoDoUsuario(simuladoId);
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
    proprietarioUsuarioId: usuarioAtual.id,
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
    proprietarioUsuarioId: usuarioAtual.id,
  };

  proximoId += 1;
  simuladosEmMemoria.push({ ...novoSimulado, questoesIds: [...novoSimulado.questoesIds] });
  return criarResumoSimulado(novoSimulado);
}

export async function atualizarQuestaoNosSimulados(questaoId, simuladosIds) {
  void questaoId;

  return simuladosIds;
}

export async function salvarSimuladoCompartilhado({
  simuladoOrigemId,
  publicacaoTurmaId,
  usuarioId,
}) {
  const usuarioIdNormalizado = Number(usuarioId);
  const publicacaoIdNormalizado = Number(publicacaoTurmaId);
  const simuladoOrigem = localizarSimulado(simuladoOrigemId);

  if (!Number.isInteger(usuarioIdNormalizado)) {
    throw new Error("Usuário inválido.");
  }

  if (!Number.isInteger(publicacaoIdNormalizado)) {
    throw new Error("Simulado publicado não encontrado.");
  }

  const copiaExistente = simuladosEmMemoria.find(
    (simulado) =>
      simulado.proprietarioUsuarioId === usuarioIdNormalizado &&
      (simulado.publicacaoTurmaId === publicacaoIdNormalizado ||
        simulado.simuladoOrigemId === simuladoOrigem.id)
  );

  if (copiaExistente) {
    const erro = new Error("Este simulado já foi adicionado.");
    erro.codigo = "SIMULADO_JA_ADICIONADO";
    erro.simuladoPessoalId = copiaExistente.id;
    throw erro;
  }

  const copiaPessoal = {
    ...simuladoOrigem,
    id: proximoId,
    dataCriacao: obterDataAtual(),
    respondidas: 0,
    acertos: 0,
    status: "nao_iniciado",
    proprietarioUsuarioId: usuarioIdNormalizado,
    simuladoOrigemId: simuladoOrigem.id,
    publicacaoTurmaId: publicacaoIdNormalizado,
    questoesIds: [...simuladoOrigem.questoesIds],
  };

  proximoId += 1;
  simuladosEmMemoria.push({
    ...copiaPessoal,
    questoesIds: [...copiaPessoal.questoesIds],
  });

  return criarResumoSimulado(copiaPessoal);
}
