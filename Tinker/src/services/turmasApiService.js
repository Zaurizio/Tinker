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
    fotoCriador: turma.fotoCriador ?? null,
    imagem: null,
    cor: "#2f5d8a",
  };
}

function formatarDataPublicacao(dataPublicacao) {
  const data = new Date(dataPublicacao);

  if (Number.isNaN(data.getTime())) return dataPublicacao;

  return new Intl.DateTimeFormat("pt-BR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
    timeZone: "America/Sao_Paulo",
  }).format(data);
}

function prepararPublicacaoSimulado(publicacao) {
  return {
    idPublicacao: String(publicacao.idPublicacao),
    simuladoId: publicacao.simuladoId,
    titulo: publicacao.titulo,
    descricao: publicacao.descricao ?? "",
    quantidadeQuestoes: publicacao.quantidadeQuestoes,
    dataPublicacao: publicacao.dataPublicacao,
    dataPublicacaoFormatada: formatarDataPublicacao(
      publicacao.dataPublicacao,
    ),
    concluido: Boolean(publicacao.concluido),
  };
}

function validarIdPublicacao(idPublicacao) {
  if (typeof idPublicacao !== "string" || !idPublicacao.trim()) {
    const erro = new Error("A publicação não foi encontrada.");
    erro.codigo = "PUBLICACAO_NAO_ENCONTRADA";
    throw erro;
  }

  return encodeURIComponent(idPublicacao);
}

function prepararQuestaoPublicada(questao) {
  const { vestibular, alternativas = [], ...dadosQuestao } = questao;

  return {
    ...dadosQuestao,
    instituicao: vestibular,
    alternativas: alternativas.map((alternativa) => ({ ...alternativa })),
    simuladosIds: [],
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
    foto: membro.foto ?? null,
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

export async function renomearTurmaDaConta(codigo, nome) {
  const turma = await apiService.put(
    `/api/turmas/${validarCodigo(codigo)}`,
    { nome },
    { autenticada: true }
  );

  return prepararTurma(turma);
}

export async function excluirTurmaDaConta(codigo) {
  await apiService.delete(`/api/turmas/${validarCodigo(codigo)}`, {
    autenticada: true,
  });
}

export async function listarSimuladosPublicadosNaTurma(codigo) {
  const publicacoes = await apiService.get(
    `/api/turmas/${validarCodigo(codigo)}/simulados`,
    { autenticada: true }
  );

  return publicacoes.map(prepararPublicacaoSimulado);
}

export async function publicarSimuladoNaTurmaDaConta(codigo, simuladoId) {
  if (!Number.isInteger(simuladoId)) {
    const erro = new Error("Selecione um simulado.");
    erro.codigo = "SIMULADO_OBRIGATORIO";
    throw erro;
  }

  const publicacao = await apiService.post(
    `/api/turmas/${validarCodigo(codigo)}/simulados`,
    { simuladoId },
    { autenticada: true }
  );

  return prepararPublicacaoSimulado(publicacao);
}

export async function removerSimuladoPublicadoDaTurma(
  codigo,
  idPublicacao
) {
  await apiService.delete(
    `/api/turmas/${validarCodigo(codigo)}/simulados/${encodeURIComponent(String(idPublicacao))}`,
    { autenticada: true }
  );
}

export async function listarQuestoesDoSimuladoPublicado(
  codigo,
  idPublicacao
) {
  const questoes = await apiService.get(
    `/api/turmas/${validarCodigo(codigo)}/simulados/${validarIdPublicacao(idPublicacao)}/questoes`,
    { autenticada: true }
  );

  return questoes.map(prepararQuestaoPublicada);
}

export async function corrigirQuestaoDoSimuladoPublicado(
  codigo,
  idPublicacao,
  questaoId,
  alternativa
) {
  const resposta = await apiService.post(
    `/api/turmas/${validarCodigo(codigo)}/simulados/${validarIdPublicacao(idPublicacao)}/questoes/${questaoId}/correcoes`,
    { alternativa },
    { autenticada: true }
  );

  return {
    questaoId: resposta.questaoId,
    alternativaSelecionadaId: alternativa,
    acertou: resposta.acertou,
    alternativaCorreta: resposta.alternativaCorreta,
  };
}

export async function concluirSimuladoPublicado(
  codigo,
  idPublicacao,
  respostas
) {
  return apiService.post(
    `/api/turmas/${validarCodigo(codigo)}/simulados/${validarIdPublicacao(idPublicacao)}/conclusoes`,
    {
      respostas: respostas.map(({ questaoId, alternativa }) => ({
        questaoId,
        alternativa,
      })),
    },
    { autenticada: true }
  );
}

export async function obterResultadoDoSimuladoPublicado(
  codigo,
  idPublicacao
) {
  return apiService.get(
    `/api/turmas/${validarCodigo(codigo)}/simulados/${validarIdPublicacao(idPublicacao)}/resultado`,
    { autenticada: true }
  );
}
