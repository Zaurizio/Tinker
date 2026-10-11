import { apiService } from "./apiService";

function prepararSimulado(simulado) {
  const simuladoPreparado = {
    id: simulado.id,
    titulo: simulado.titulo,
    descricao: simulado.descricao ?? "",
    tempo: simulado.tempo ?? null,
    quantidadeQuestoes: simulado.quantidadeQuestoes,
    concluido: Boolean(simulado.concluido),
    acertos: simulado.acertos ?? null,
  };

  if (Array.isArray(simulado.questoesIds)) {
    simuladoPreparado.questoesIds = [...simulado.questoesIds];
  }

  return simuladoPreparado;
}

export async function listarSimuladosDaConta() {
  const simulados = await apiService.get("/api/simulados", {
    autenticada: true,
  });

  return simulados.map(prepararSimulado);
}

export async function criarSimuladoVazio({ titulo }) {
  const simulado = await apiService.post(
    "/api/simulados",
    { titulo },
    { autenticada: true }
  );

  return prepararSimulado(simulado);
}

export async function gerarSimuladoDaConta({
  titulo,
  descricao = null,
  tempo = null,
  quantidadeQuestoes,
  disciplinas = [],
  conteudos = [],
  instituicoes = [],
  anos = [],
}) {
  const simulado = await apiService.post(
    "/api/simulados/geracoes",
    {
      titulo,
      descricao,
      tempo,
      quantidadeQuestoes: Number(quantidadeQuestoes),
      disciplinas: Array.isArray(disciplinas) ? disciplinas : [],
      conteudos: Array.isArray(conteudos) ? conteudos : [],
      vestibulares: Array.isArray(instituicoes) ? instituicoes : [],
      anos: Array.isArray(anos) ? anos.map(Number) : [],
    },
    { autenticada: true }
  );

  return prepararSimulado(simulado);
}

export async function renomearSimuladoDaConta(id, { titulo }) {
  const simulado = await apiService.patch(
    `/api/simulados/${id}`,
    { titulo },
    { autenticada: true }
  );

  return prepararSimulado(simulado);
}

export async function excluirSimuladoDaConta(id) {
  await apiService.delete(`/api/simulados/${id}`, { autenticada: true });
}

export async function obterSimuladoDaConta(id) {
  const simulado = await apiService.get(`/api/simulados/${id}`, {
    autenticada: true,
  });

  return prepararSimulado(simulado);
}

export async function carregarSimuladosDaContaComQuestoes() {
  const simulados = await listarSimuladosDaConta();

  return Promise.all(
    simulados.map((simulado) => obterSimuladoDaConta(simulado.id))
  );
}

export async function adicionarQuestoesAoSimuladoDaConta(
  simuladoId,
  questoesIds
) {
  return apiService.post(
    `/api/simulados/${simuladoId}/questoes`,
    { questoesIds: [...questoesIds] },
    { autenticada: true }
  );
}

export async function removerQuestaoDoSimuladoDaConta(
  simuladoId,
  questaoId
) {
  await apiService.delete(
    `/api/simulados/${simuladoId}/questoes/${questaoId}`,
    { autenticada: true }
  );
}

export async function listarQuestoesDoSimuladoDaConta(id) {
  return apiService.get(`/api/simulados/${id}/questoes`, {
    autenticada: true,
  });
}

export async function concluirSimuladoDaConta(id, respostas) {
  return apiService.post(
    `/api/simulados/${id}/conclusoes`,
    {
      respostas: respostas.map(({ questaoId, alternativa }) => ({
        questaoId,
        alternativa,
      })),
    },
    { autenticada: true }
  );
}
