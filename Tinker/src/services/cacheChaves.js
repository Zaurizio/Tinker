export const CHAVE_EVENTOS = "eventos";
export const CHAVE_DESEMPENHO = "desempenho";
export const CHAVE_SIMULADOS = "simulados";
export const CHAVE_SIMULADOS_COM_QUESTOES = "simulados-com-questoes";
export const CHAVE_TURMAS = "turmas";
export const CHAVE_FILTROS_QUESTOES = "filtros-questoes";
export const CHAVE_PERFIL = "perfil";

export const chaveSimulado = (id) => `simulado:${id}`;
export const chaveTurma = (codigo) => `turma:${codigo}`;
export const chaveMembrosTurma = (codigo) => `membros-turma:${codigo}`;
export const chaveSimuladosTurma = (codigo) => `simulados-turma:${codigo}`;
export const chavePublicacaoTurma = (codigo, idPublicacao) =>
  `publicacao-turma:${codigo}:${idPublicacao}`;
