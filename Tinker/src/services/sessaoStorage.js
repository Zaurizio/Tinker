export const CHAVE_SESSAO = "tinker:sessao";

function decodificarPayloadJwt(token) {
  if (typeof token !== "string") return null;

  const partes = token.split(".");
  if (
    partes.length !== 3 ||
    partes.some((parte) => !/^[A-Za-z0-9_-]+$/.test(parte))
  ) return null;

  try {
    const payloadBase64 = partes[1].replace(/-/g, "+").replace(/_/g, "/");
    if (payloadBase64.length % 4 === 1) return null;

    const payloadComPadding = payloadBase64.padEnd(
      payloadBase64.length + ((4 - (payloadBase64.length % 4)) % 4),
      "=",
    );
    const bytes = Uint8Array.from(atob(payloadComPadding), (caractere) =>
      caractere.charCodeAt(0),
    );
    const payload = JSON.parse(new TextDecoder().decode(bytes));

    return payload && typeof payload === "object" && !Array.isArray(payload)
      ? payload
      : null;
  } catch {
    return null;
  }
}

export function sessaoEhValida(sessao, agoraMs = Date.now()) {
  if (!sessao || typeof sessao !== "object" || Array.isArray(sessao)) {
    return false;
  }

  const payload = decodificarPayloadJwt(sessao.token);
  if (
    !payload ||
    typeof payload.exp !== "number" ||
    !Number.isFinite(payload.exp) ||
    payload.exp <= 0
  ) {
    return false;
  }

  return payload.exp * 1000 > agoraMs;
}

export function removerSessaoArmazenada() {
  localStorage.removeItem(CHAVE_SESSAO);
}

export function obterSessaoArmazenada() {
  const valorArmazenado = localStorage.getItem(CHAVE_SESSAO);
  if (!valorArmazenado) return null;

  try {
    const sessao = JSON.parse(valorArmazenado);
    if (!sessaoEhValida(sessao)) {
      removerSessaoArmazenada();
      return null;
    }
    return sessao;
  } catch {
    removerSessaoArmazenada();
    return null;
  }
}

export function salvarSessaoArmazenada(sessao) {
  if (!sessaoEhValida(sessao)) {
    removerSessaoArmazenada();
    throw new Error("A sessão recebida é inválida.");
  }

  localStorage.setItem(CHAVE_SESSAO, JSON.stringify(sessao));
  return sessao;
}

export function atualizarSessaoArmazenada(dados) {
  const sessaoAtual = obterSessaoArmazenada();
  if (!sessaoAtual) return null;

  return salvarSessaoArmazenada({ ...sessaoAtual, ...dados });
}
