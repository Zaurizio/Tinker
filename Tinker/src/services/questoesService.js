import { apiService } from "./apiService";

function montarParametrosBusca(filtros, { pagina, tamanho }) {
  const parametros = new URLSearchParams();
  const filtrosMultiplos = [
    ["disciplinas", filtros.disciplinas],
    ["conteudos", filtros.conteudos],
    ["vestibulares", filtros.instituicoes],
    ["anos", filtros.anos],
  ];

  filtrosMultiplos.forEach(([nome, valores]) => {
    valores.forEach((valor) => parametros.append(nome, String(valor)));
  });

  const trecho = filtros.trecho.trim();
  if (trecho) parametros.set("trecho", trecho);
  parametros.set("pagina", String(pagina));
  parametros.set("tamanho", String(tamanho));

  return parametros;
}

function prepararQuestaoDaApi(questao) {
  const { vestibular, alternativas = [], ...dadosQuestao } = questao;

  return {
    ...dadosQuestao,
    instituicao: vestibular,
    alternativas: alternativas.map((alternativa) => ({ ...alternativa })),
    simuladosIds: [],
  };
}

export async function buscarOpcoesFiltrosQuestoes() {
  return apiService.get("/api/questoes/filtros", { autenticada: true });
}

export async function buscarQuestoes(filtros, { pagina, tamanho }) {
  const parametros = montarParametrosBusca(filtros, { pagina, tamanho });
  const resposta = await apiService.get(
    `/api/questoes?${parametros.toString()}`,
    { autenticada: true }
  );

  return {
    ...resposta,
    itens: (resposta.itens ?? []).map(prepararQuestaoDaApi),
  };
}

export async function responderQuestao(questaoId, alternativaSelecionadaId) {
  const resposta = await apiService.post(
    `/api/questoes/${questaoId}/correcoes`,
    { alternativa: alternativaSelecionadaId },
    { autenticada: true }
  );

  return {
    questaoId: resposta.questaoId,
    alternativaSelecionadaId,
    acertou: resposta.acertou,
    alternativaCorreta: resposta.alternativaCorreta,
  };
}
