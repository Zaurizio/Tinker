//turmas.js
export const turmas = [
  {
    id: 1,
    nome: "3º Informática",
    codigo: "TIN123",
    professorId: 10,
    quantidadeAlunos: 28
  }
];

export const membrosTurma = [
  {
    id: 1,
    turmaId: 1,
    usuarioId: 21,
    nome: "Gustavo",
    tipo: "aluno"
  },
  {
    id: 2,
    turmaId: 1,
    usuarioId: 10,
    nome: "Professor João",
    tipo: "professor"
  }
];

export const atividadesTurma = [
  {
    id: 1,
    turmaId: 1,
    titulo: "Simulado de Matemática",
    tipo: "simulado",
    dataEntrega: "2026-08-25"
  }
];