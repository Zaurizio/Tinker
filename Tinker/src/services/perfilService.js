import { apiService } from "./apiService";
import { atualizarSessao } from "./autenticacaoService";

function ehProfessor(tipoUsuario) {
  return String(tipoUsuario ?? "").toUpperCase().startsWith("PROFESSOR");
}

function atualizarSessaoComPerfil({ nome, sobrenome }) {
  atualizarSessao({ nome, sobrenome });
}

export const TAMANHO_MAXIMO_FOTO = 2 * 1024 * 1024;
export const TIPOS_FOTO_PERMITIDOS = ["image/jpeg", "image/png"];

export async function obterPerfil() {
  return apiService.get("/api/me", { autenticada: true });
}

export async function enviarFotoPerfil(arquivo) {
  const formData = new FormData();
  formData.append("foto", arquivo);
  return apiService.post("/api/me/foto", formData, { autenticada: true });
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
