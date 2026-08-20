import {
  conteudosCatalogo,
  disciplinasCatalogo,
  instituicoesCatalogo,
} from "./catalogosQuestoes";

export const disciplinas = disciplinasCatalogo.map(({ nome }) => nome);
export const conteudos = conteudosCatalogo.map(({ nome }) => nome);
export const instituicoes = instituicoesCatalogo.map(({ nome }) => nome);
export const anos = ["2025", "2024", "2023", "2022"];
