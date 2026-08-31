import { apiService } from "./apiService";

function obterMensagemTaxaGeral(taxaAcertos) {
  if (taxaAcertos >= 80) return "Excelente evolução!";
  if (taxaAcertos >= 60) return "Bom caminho, continue!";
  if (taxaAcertos >= 40) return "Dá pra melhorar, foco nas revisões.";
  return "Vamos construir sua base aos poucos.";
}

function prepararDestaque(disciplina) {
  if (!disciplina) return null;

  return {
    nome: disciplina.disciplina,
    taxa: disciplina.percentualAcertos,
    acertos: disciplina.numeroAcertos,
    questoesFeitas: disciplina.questoesFeitas,
  };
}

function prepararDisciplinas(disciplinas) {
  return (disciplinas ?? []).map((disciplina) => ({
    id: disciplina.disciplina,
    nome: disciplina.disciplina,
    porcentagemAcertos: disciplina.percentualAcertos,
    acertos: disciplina.numeroAcertos,
    questoesFeitas: disciplina.questoesFeitas,
  }));
}

export async function obterResumoDesempenho() {
  const dados = await apiService.get("/api/desempenho", { autenticada: true });
  const questoesRespondidas = dados.questoesRespondidas ?? 0;
  const possuiRespostas = questoesRespondidas > 0;
  const taxaAcertosGeral = possuiRespostas ? dados.percentualGeral : null;

  return {
    questoesRespondidas,
    totalAcertos: dados.totalAcertos ?? 0,
    simuladosConcluidos: dados.simuladosConcluidos ?? 0,
    possuiRespostas,
    taxaAcertosGeral,
    mensagemTaxaGeral: possuiRespostas
      ? obterMensagemTaxaGeral(taxaAcertosGeral)
      : "",
    materiaMaiorAcerto: possuiRespostas
      ? prepararDestaque(dados.maiorDesempenho)
      : null,
    materiaMenorAcerto: possuiRespostas
      ? prepararDestaque(dados.menorDesempenho)
      : null,
    disciplinas: possuiRespostas ? prepararDisciplinas(dados.disciplinas) : [],
  };
}
