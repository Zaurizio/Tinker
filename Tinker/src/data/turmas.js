export const turmas = [
  {
    id: 1,
    nome: "Turma de Matemática",
    criador: "Prof. João Silva",
    imagem: null,
    cor: "#2f5d8a",
    codigo: "MAT123",
    professorId: 10,
    quantidadeAlunos: 28,
  },
  {
    id: 2,
    nome: "Biologia — FUVEST",
    criador: "Ana Souza",
    imagem: null,
    cor: "#4a7c6f",
    codigo: "BIO456",
    professorId: 11,
    quantidadeAlunos: 24,
  },
  {
    id: 3,
    nome: "Redação Intensiva",
    criador: "Carlos Mendes",
    imagem: null,
    cor: "#7a5c8a",
    codigo: "RED789",
    professorId: 12,
    quantidadeAlunos: 19,
  },
];

export const membrosTurma = [
  {
    id: 1,
    turmaId: 1,
    usuarioId: 1,
    nome: "Gustavo Pareschi",
    tipo: "aluno",
    fotoPerfil: null,
  },
  {
    id: 2,
    turmaId: 1,
    usuarioId: 10,
    nome: "Prof. João Silva",
    tipo: "administrador",
    fotoPerfil: null,
  },
  {
    id: 3,
    turmaId: 2,
    usuarioId: 1,
    nome: "Gustavo Pareschi",
    tipo: "aluno",
    fotoPerfil: null,
  },
  {
    id: 4,
    turmaId: 2,
    usuarioId: 11,
    nome: "Ana Souza",
    tipo: "administrador",
    fotoPerfil: null,
  },
  {
    id: 5,
    turmaId: 3,
    usuarioId: 12,
    nome: "Carlos Mendes",
    tipo: "administrador",
    fotoPerfil: null,
  },
];

export const publicacoesSimuladosTurma = [
  {
    id: 1,
    turmaId: 1,
    simuladoId: 1,
    dataPublicacao: "2026-08-20",
    publicadoPorUsuarioId: 10,
  },
  {
    id: 2,
    turmaId: 3,
    simuladoId: 2,
    dataPublicacao: "2026-08-22",
    publicadoPorUsuarioId: 12,
  },
];

export const publicacoesEventosTurma = [
  {
    id: 1,
    turmaId: 1,
    eventoId: 5,
    dataPublicacao: "2026-08-19",
    publicadoPorUsuarioId: 10,
  },
  {
    id: 2,
    turmaId: 3,
    eventoId: 6,
    dataPublicacao: "2026-08-21",
    publicadoPorUsuarioId: 12,
  },
  {
    id: 3,
    turmaId: 1,
    eventoId: 3,
    dataPublicacao: "2026-08-25",
    publicadoPorUsuarioId: 10,
  },
];
