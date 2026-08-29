import { questoes } from "../data/questoes";
import { apiService } from "./apiService";
import {
  conteudosCatalogo,
  disciplinasCatalogo,
  instituicoesCatalogo,
} from "../data/catalogosQuestoes";

const normalizarTexto = (texto) =>
  texto
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase();

const criarMapaPorNome = (catalogo) =>
  new Map(catalogo.map(({ id, nome }) => [nome, id]));

const criarMapaPorId = (catalogo) =>
  new Map(catalogo.map(({ id, nome }) => [id, nome]));

const disciplinasPorNome = criarMapaPorNome(disciplinasCatalogo);
const conteudosPorNome = criarMapaPorNome(conteudosCatalogo);
const instituicoesPorNome = criarMapaPorNome(instituicoesCatalogo);

const disciplinasPorId = criarMapaPorId(disciplinasCatalogo);
const conteudosPorId = criarMapaPorId(conteudosCatalogo);
const instituicoesPorId = criarMapaPorId(instituicoesCatalogo);

function prepararQuestaoParaExibicao(questao) {
  return {
    ...questao,
    alternativas: questao.alternativas.map((alternativa) => ({ ...alternativa })),
    simuladosIds: [...(questao.simuladosIds ?? [])],
    disciplina: disciplinasPorId.get(questao.disciplinaId),
    conteudo: conteudosPorId.get(questao.conteudoId),
    instituicao: instituicoesPorId.get(questao.instituicaoId),
  };
}

function correspondeAoRelacionamento(selecionados, mapaPorNome, idQuestao) {
  if (selecionados.length === 0) return true;

  const idsSelecionados = selecionados.map((nome) => mapaPorNome.get(nome));
  return idsSelecionados.includes(idQuestao);
}

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

export async function buscarQuestoesParaSimulados(filtros, { pagina, tamanho }) {
  const trechoNormalizado = normalizarTexto(filtros.trecho.trim());
  const inicio = pagina * tamanho;

  const questoesFiltradas = questoes
    .filter((questao) =>
      correspondeAoRelacionamento(
        filtros.disciplinas,
        disciplinasPorNome,
        questao.disciplinaId
      )
    )
    .filter((questao) =>
      correspondeAoRelacionamento(
        filtros.conteudos,
        conteudosPorNome,
        questao.conteudoId
      )
    )
    .filter((questao) =>
      correspondeAoRelacionamento(
        filtros.instituicoes,
        instituicoesPorNome,
        questao.instituicaoId
      )
    )
    .filter(
      (questao) =>
        filtros.anos.length === 0 || filtros.anos.includes(String(questao.ano))
    )
    .filter(
      (questao) =>
        trechoNormalizado === "" ||
        normalizarTexto(questao.enunciado).includes(trechoNormalizado)
    )
    .filter((questao) => {
      if (filtros.status === "jaRespondi") return questao.respondida === true;
      if (filtros.status === "naoRespondi") return questao.respondida === false;
      return true;
    })
    .sort((questaoA, questaoB) => questaoA.id - questaoB.id);

  const itens = questoesFiltradas
    .slice(inicio, inicio + tamanho)
    .map(prepararQuestaoParaExibicao);

  return {
    itens,
    temMais: inicio + tamanho < questoesFiltradas.length,
    total: questoesFiltradas.length,
  };
}

export async function buscarQuestoesPorIds(ids) {
  if (!Array.isArray(ids)) {
    throw new Error("A lista de questões associadas é inválida.");
  }

  const questoesPorId = new Map(questoes.map((questao) => [questao.id, questao]));

  return ids.map((id) => {
    const questao = questoesPorId.get(id);

    if (!questao) {
      throw new Error("Os dados do simulado estão inconsistentes.");
    }

    return prepararQuestaoParaExibicao(questao);
  });
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
  };
}
