import {
  obterSessaoArmazenada,
  removerSessaoArmazenada,
} from './sessaoStorage'

const API_URL = (import.meta.env.VITE_API_URL || 'http://localhost:8080').replace(/\/$/, '')

export class ApiError extends Error {
  constructor(status, codigo, mensagem) {
    super(mensagem)
    this.name = 'ApiError'
    this.status = status
    this.codigo = codigo
  }
}

function obterTokenSalvo() {
  return obterSessaoArmazenada()?.token ?? null
}

async function lerResposta(response) {
  if (response.status === 204) return null

  const texto = await response.text()
  if (!texto) return null

  try {
    return JSON.parse(texto)
  } catch {
    return texto
  }
}

export async function requisicao(caminho, opcoes = {}) {
  const { autenticada = false, corpo, headers, ...fetchOptions } = opcoes
  const requestHeaders = new Headers(headers)

  if (corpo !== undefined && corpo !== null) {
    requestHeaders.set('Content-Type', 'application/json')
  }

  if (autenticada) {
    const token = obterTokenSalvo()
    if (token) requestHeaders.set('Authorization', `Bearer ${token}`)
  }

  const response = await fetch(`${API_URL}${caminho.startsWith('/') ? caminho : `/${caminho}`}`, {
    ...fetchOptions,
    headers: requestHeaders,
    body: corpo === undefined || corpo === null ? undefined : JSON.stringify(corpo),
  })
  const dados = await lerResposta(response)

  if (!response.ok) {
    const erroDto = dados && typeof dados === 'object' ? dados : {}
    const mensagem = erroDto.mensagem || response.statusText || 'Erro ao comunicar com a API.'
    const erro = new ApiError(response.status, erroDto.codigo, mensagem)

    if (autenticada && response.status === 401) {
      removerSessaoArmazenada()
      if (typeof window !== 'undefined' && window.location.pathname !== '/login') {
        window.location.replace('/login')
      }
    }

    throw erro
  }

  return dados
}

export const apiService = {
  get: (caminho, opcoes) => requisicao(caminho, { ...opcoes, method: 'GET' }),
  post: (caminho, corpo, opcoes) => requisicao(caminho, { ...opcoes, method: 'POST', corpo }),
  put: (caminho, corpo, opcoes) => requisicao(caminho, { ...opcoes, method: 'PUT', corpo }),
  patch: (caminho, corpo, opcoes) => requisicao(caminho, { ...opcoes, method: 'PATCH', corpo }),
  delete: (caminho, opcoes) => requisicao(caminho, { ...opcoes, method: 'DELETE' }),
}
