import { desempenho } from "../data/desempenho";

function calcularPorcentagem(acertos, questoesFeitas) {
  if (questoesFeitas <= 0) return null;
  return Math.round((acertos / questoesFeitas) * 100);
}

function prepararDesempenhoPorDisciplina(disciplinas) {
  return disciplinas.map((disciplina) => {
    const porcentagemAcertos = calcularPorcentagem(
      disciplina.acertos,
      disciplina.questoesFeitas
    );

    return {
      id: disciplina.id,
      nome: disciplina.nome,
      porcentagemAcertos,
      acertos: disciplina.acertos,
      questoesFeitas: disciplina.questoesFeitas,
      possuiRespostas: porcentagemAcertos !== null,
    };
  });
}

function obterMensagemTaxaGeral(taxaAcertos) {
  if (taxaAcertos >= 80) return "Excelente evolução!";
  if (taxaAcertos >= 60) return "Bom caminho, continue!";
  if (taxaAcertos >= 40) return "Dá pra melhorar, foco nas revisões.";
  return "Vamos construir sua base aos poucos.";
}

function criarDestaque(disciplina) {
  if (!disciplina) return null;
  return { nome: disciplina.nome, taxa: disciplina.porcentagemAcertos };
}

export async function obterResumoDesempenho() {
  const disciplinasPreparadas = prepararDesempenhoPorDisciplina(
    desempenho.disciplinas
  );
  const disciplinasComRespostas = disciplinasPreparadas.filter(
    (disciplina) => disciplina.possuiRespostas
  );
  const questoesRespondidas = desempenho.disciplinas.reduce(
    (total, disciplina) => total + disciplina.questoesFeitas,
    0
  );
  const totalAcertos = desempenho.disciplinas.reduce(
    (total, disciplina) => total + disciplina.acertos,
    0
  );
  const taxaAcertosGeral =
    calcularPorcentagem(totalAcertos, questoesRespondidas) ?? 0;
  const materiaMaiorAcerto = disciplinasComRespostas.reduce(
    (maior, disciplina) =>
      !maior || disciplina.porcentagemAcertos > maior.porcentagemAcertos
        ? disciplina
        : maior,
    null
  );
  const materiaMenorAcerto = disciplinasComRespostas.reduce(
    (menor, disciplina) =>
      !menor || disciplina.porcentagemAcertos < menor.porcentagemAcertos
        ? disciplina
        : menor,
    null
  );

  return {
    taxaAcertosGeral,
    mensagemTaxaGeral: obterMensagemTaxaGeral(taxaAcertosGeral),
    materiaMaiorAcerto: criarDestaque(materiaMaiorAcerto),
    materiaMenorAcerto: criarDestaque(materiaMenorAcerto),
    questoesRespondidas,
    simuladosFeitos: desempenho.simuladosFeitos,
    disciplinas: disciplinasComRespostas.map((disciplina) => ({
      ...disciplina,
    })),
  };
}
