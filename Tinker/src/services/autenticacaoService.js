import { apiService } from './apiService'

const CHAVE_SESSAO = 'tinker:sessao'

export function fazerLogin({ email, senha, tipoUsuario }) {
  return apiService.post('/api/auth/login', { email, senha, tipoUsuario })
}

export function fazerCadastro({ nome, sobrenome, email, senha, nascimento, tipoUsuario }) {
  return apiService.post('/api/auth/cadastros', {
    nome,
    sobrenome,
    email,
    senha,
    nascimento,
    tipoUsuario,
  })
}

export function salvarSessao(dadosLogin) {
  const sessao = {
    token: dadosLogin.token,
    nome: dadosLogin.nome,
    sobrenome: dadosLogin.sobrenome,
    email: dadosLogin.email,
    tipoUsuario: dadosLogin.tipoUsuario,
  }

  localStorage.setItem(CHAVE_SESSAO, JSON.stringify(sessao))
  return sessao
}

export function obterSessao() {
  const sessaoSalva = localStorage.getItem(CHAVE_SESSAO)
  if (!sessaoSalva) return null

  try {
    return JSON.parse(sessaoSalva)
  } catch {
    localStorage.removeItem(CHAVE_SESSAO)
    return null
  }
}

export function obterToken() {
  return obterSessao()?.token ?? null
}

export function estaAutenticado() {
  return Boolean(obterToken())
}

export function encerrarSessao() {
  localStorage.removeItem(CHAVE_SESSAO)
}
