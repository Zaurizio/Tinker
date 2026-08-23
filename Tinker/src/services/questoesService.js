import { questoes } from "../data/questoes";
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
  const { respostaCorretaId, ...questaoSemGabarito } = questao;
  void respostaCorretaId;

  return {
    ...questaoSemGabarito,
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

export async function buscarQuestoes(filtros, { pagina, tamanho }) {
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
  const questao = questoes.find((item) => item.id === questaoId);

  if (!questao) {
    throw new Error("Questão não encontrada.");
  }

  return {
    questaoId,
    alternativaSelecionadaId,
    alternativaCorretaId: questao.respostaCorretaId,
    correta: alternativaSelecionadaId === questao.respostaCorretaId,
  };
}
