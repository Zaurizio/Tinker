import { obterSessaoArmazenada } from "./sessaoStorage";

const cachesPorConta = new Map();

function obterMapaDaContaAtual() {
  const email = obterSessaoArmazenada()?.email;
  if (!email) return null;

  let mapa = cachesPorConta.get(email);
  if (!mapa) {
    mapa = new Map();
    cachesPorConta.set(email, mapa);
  }
  return mapa;
}

export function obterCache(chave) {
  const email = obterSessaoArmazenada()?.email;
  if (!email) return undefined;

  const mapa = cachesPorConta.get(email);
  if (!mapa || !mapa.has(chave)) return undefined;
  return mapa.get(chave);
}

export function definirCache(chave, dados) {
  const mapa = obterMapaDaContaAtual();
  if (!mapa) return;
  mapa.set(chave, dados);
}

export function invalidarCache(chave) {
  const email = obterSessaoArmazenada()?.email;
  if (!email) return;
  cachesPorConta.get(email)?.delete(chave);
}

export function invalidarCacheDaContaAtual() {
  const email = obterSessaoArmazenada()?.email;
  if (!email) return;
  cachesPorConta.delete(email);
}

export function limparTodoCache() {
  cachesPorConta.clear();
}
