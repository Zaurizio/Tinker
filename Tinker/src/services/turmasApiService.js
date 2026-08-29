import { apiService } from "./apiService";

function prepararTurma(turma) {
  return {
    codigo: String(turma.codigo),
    nome: turma.nome,
    criador: turma.criadorNome,
    imagem: null,
    cor: "#2f5d8a",
  };
}

export async function listarTurmasDaConta() {
  const turmas = await apiService.get("/api/turmas", {
    autenticada: true,
  });

  return turmas.map(prepararTurma);
}

export async function criarTurmaDaConta({ nome }) {
  const turma = await apiService.post(
    "/api/turmas",
    { nome },
    { autenticada: true }
  );

  return prepararTurma(turma);
}

export async function entrarEmTurmaDaConta(codigo) {
  const turma = await apiService.post(
    "/api/turmas/entradas",
    { codigo },
    { autenticada: true }
  );

  return prepararTurma(turma);
}
