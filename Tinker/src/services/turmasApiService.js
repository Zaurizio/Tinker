import { apiService } from "./apiService";

function validarCodigo(codigo) {
  if (typeof codigo !== "string" || !/^\d{8}$/.test(codigo)) {
    const erro = new Error("O código deve conter exatamente oito dígitos.");
    erro.codigo = "CODIGO_TURMA_INVALIDO";
    throw erro;
  }

  return codigo;
}

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
  const codigoValidado = validarCodigo(codigo);
  const turma = await apiService.post(
    "/api/turmas/entradas",
    { codigo: codigoValidado },
    { autenticada: true }
  );

  return prepararTurma(turma);
}

export async function obterTurmaDaConta(codigo) {
  const turma = await apiService.get(`/api/turmas/${validarCodigo(codigo)}`, {
    autenticada: true,
  });

  return prepararTurma(turma);
}

export async function listarMembrosDaTurmaDaConta(codigo) {
  const membros = await apiService.get(
    `/api/turmas/${validarCodigo(codigo)}/membros`,
    { autenticada: true }
  );

  return membros.map((membro) => ({
    email: membro.email,
    nome: membro.nome,
    sobrenome: membro.sobrenome,
    nomeCompleto: `${membro.nome} ${membro.sobrenome}`.trim(),
  }));
}

export async function sairDaTurmaDaConta(codigo) {
  await apiService.delete(
    `/api/turmas/${validarCodigo(codigo)}/membros/me`,
    { autenticada: true }
  );
}

export async function removerMembroDaTurmaDaConta(codigo, emailAluno) {
  await apiService.delete(
    `/api/turmas/${validarCodigo(codigo)}/membros/${encodeURIComponent(emailAluno)}`,
    { autenticada: true }
  );
}

export async function excluirTurmaDaConta(codigo) {
  await apiService.delete(`/api/turmas/${validarCodigo(codigo)}`, {
    autenticada: true,
  });
}
