import { apiService } from "./apiService";

function prepararSimulado(simulado) {
  return {
    id: simulado.id,
    titulo: simulado.titulo,
    descricao: simulado.descricao ?? "",
    tempo: simulado.tempo ?? null,
    quantidadeQuestoes: simulado.quantidadeQuestoes,
  };
}

export async function listarSimuladosDoProfessor() {
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

export async function renomearSimuladoDoProfessor(id, { titulo }) {
  const simulado = await apiService.patch(
    `/api/simulados/${id}`,
    { titulo },
    { autenticada: true }
  );

  return prepararSimulado(simulado);
}

export async function excluirSimuladoDoProfessor(id) {
  await apiService.delete(`/api/simulados/${id}`, { autenticada: true });
}

export async function obterSimuladoDoProfessor(id) {
  const simulado = await apiService.get(`/api/simulados/${id}`, {
    autenticada: true,
  });

  return prepararSimulado(simulado);
}

export async function listarQuestoesDoSimuladoDoProfessor(id) {
  return apiService.get(`/api/simulados/${id}/questoes`, {
    autenticada: true,
  });
}
