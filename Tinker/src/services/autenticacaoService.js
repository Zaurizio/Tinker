import { apiService } from './apiService'
import {
  atualizarSessaoArmazenada,
  obterSessaoArmazenada,
  removerSessaoArmazenada,
  salvarSessaoArmazenada,
} from './sessaoStorage'
import { limparTodoCache } from './cacheStore'

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

  return salvarSessaoArmazenada(sessao)
}

export function obterSessao() {
  return obterSessaoArmazenada()
}

export function obterToken() {
  return obterSessao()?.token ?? null
}

export function estaAutenticado() {
  return Boolean(obterToken())
}

export function encerrarSessao() {
  removerSessaoArmazenada()
  limparTodoCache()
}

export function atualizarSessao(dados) {
  return atualizarSessaoArmazenada(dados)
}
