import { apiService } from "./apiService";
import { obterSessao } from "./autenticacaoService";

const CHAVE_SESSAO = "tinker:sessao";

function ehProfessor(tipoUsuario) {
  return String(tipoUsuario ?? "").toUpperCase().startsWith("PROFESSOR");
}

function atualizarSessaoComPerfil({ nome, sobrenome }) {
  const sessao = obterSessao();
  if (!sessao) return;

  localStorage.setItem(
    CHAVE_SESSAO,
    JSON.stringify({ ...sessao, nome, sobrenome })
  );
}

export async function obterPerfil() {
  return apiService.get("/api/me", { autenticada: true });
}

export async function atualizarPerfil({ nome, sobrenome, nascimento, tipoUsuario }) {
  const dadosPerfil = {
    nome: nome.trim(),
    sobrenome: sobrenome.trim(),
    nascimento: ehProfessor(tipoUsuario) ? null : nascimento || null,
  };

  const perfilAtualizado = await apiService.put(
    "/api/me",
    dadosPerfil,
    { autenticada: true }
  );

  atualizarSessaoComPerfil(dadosPerfil);
  return perfilAtualizado;
}

export { ehProfessor };
