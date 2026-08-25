import {
  membrosTurma,
  publicacoesEventosTurma,
  publicacoesSimuladosTurma,
  turmas,
} from "../data/turmas";
import { usuarioAtual } from "../data/usuario";
import {
  encontrarEventoEquivalente,
  obterEventoDoUsuarioPorId,
  obterEventoPorId,
  salvarEventoCompartilhado,
} from "./calendarioService";
import {
  encontrarSimuladoSalvoDoUsuario,
  obterSimuladoDoUsuarioPorId,
  obterSimuladoPublicadoPorId,
  salvarSimuladoCompartilhado,
} from "./simuladosService";

const TEMPO_SIMULADO_MS = 300;
const CARACTERES_CODIGO = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

const turmasEmMemoria = turmas.map((turma) => ({ ...turma }));
const membrosEmMemoria = membrosTurma.map((membro) => ({ ...membro }));
const publicacoesSimuladosEmMemoria = publicacoesSimuladosTurma.map(
  (publicacao) => ({ ...publicacao })
);
const publicacoesEventosEmMemoria = publicacoesEventosTurma.map(
  (publicacao) => ({ ...publicacao })
);
const salvamentosSimuladosEmMemoria = [];
const salvamentosEventosEmMemoria = [];

let proximoIdTurma =
  turmasEmMemoria.reduce(
    (maiorId, turma) => Math.max(maiorId, Number(turma.id) || 0),
    0
  ) + 1;
let proximoIdMembro =
  membrosEmMemoria.reduce(
    (maiorId, membro) => Math.max(maiorId, Number(membro.id) || 0),
    0
  ) + 1;
let proximoIdPublicacao =
  publicacoesSimuladosEmMemoria.reduce(
    (maiorId, publicacao) => Math.max(maiorId, Number(publicacao.id) || 0),
    0
  ) + 1;
let proximoIdPublicacaoEvento =
  publicacoesEventosEmMemoria.reduce(
    (maiorId, publicacao) => Math.max(maiorId, Number(publicacao.id) || 0),
    0
  ) + 1;

function copiarTurma(turma) {
  return { ...turma };
}

function copiarMembro(membro) {
  return { ...membro };
}

function localizarTurma(turmaId) {
  const idNormalizado = Number(turmaId);
  const turma = Number.isInteger(idNormalizado)
    ? turmasEmMemoria.find((item) => item.id === idNormalizado)
    : null;

  if (!turma) {
    const erro = new Error("Turma não encontrada.");
    erro.codigo = "TURMA_NAO_ENCONTRADA";
    throw erro;
  }

  return turma;
}

function obterAssociacaoDoUsuario(turmaId) {
  const associacaoUsuario = membrosEmMemoria.find(
    (membro) =>
      membro.turmaId === turmaId && membro.usuarioId === usuarioAtual.id
  );

  if (!associacaoUsuario) {
    const erro = new Error("Você não participa desta turma.");
    erro.codigo = "USUARIO_NAO_PARTICIPA";
    throw erro;
  }

  return associacaoUsuario;
}

function aguardarOperacaoSimulada() {
  return new Promise((resolve) => {
    setTimeout(resolve, TEMPO_SIMULADO_MS);
  });
}

function obterDataAtual() {
  const agora = new Date();
  return [
    agora.getFullYear(),
    String(agora.getMonth() + 1).padStart(2, "0"),
    String(agora.getDate()).padStart(2, "0"),
  ].join("-");
}

async function prepararSimuladoPublicado(publicacao, simulado) {
  const simuladoSalvo = await encontrarSimuladoSalvoDoUsuario({
    simuladoOrigemId: simulado.id,
    publicacaoTurmaId: publicacao.id,
  });

  return {
    idPublicacao: publicacao.id,
    simuladoId: simulado.id,
    titulo: simulado.titulo,
    dataPublicacao: publicacao.dataPublicacao,
    quantidadeQuestoes: simulado.quantidadeQuestoes,
    salvoPeloUsuario: Boolean(simuladoSalvo),
  };
}

function registrarSalvamento(publicacaoTurmaId, simuladoPessoalId) {
  const salvamentoExistente = salvamentosSimuladosEmMemoria.find(
    (item) =>
      item.usuarioId === usuarioAtual.id &&
      item.publicacaoTurmaId === publicacaoTurmaId
  );

  if (salvamentoExistente) {
    salvamentoExistente.simuladoPessoalId = simuladoPessoalId;
    return;
  }

  salvamentosSimuladosEmMemoria.push({
    usuarioId: usuarioAtual.id,
    publicacaoTurmaId,
    simuladoPessoalId,
  });
}

function registrarSalvamentoEvento(publicacaoTurmaId, eventoPessoalId) {
  const salvamentoExistente = salvamentosEventosEmMemoria.find(
    (item) =>
      item.usuarioId === usuarioAtual.id &&
      item.publicacaoTurmaId === publicacaoTurmaId
  );

  if (salvamentoExistente) {
    salvamentoExistente.eventoPessoalId = eventoPessoalId;
    return;
  }

  salvamentosEventosEmMemoria.push({
    usuarioId: usuarioAtual.id,
    publicacaoTurmaId,
    eventoPessoalId,
  });
}

async function eventoEstaSalvoParaUsuario(publicacao, evento) {
  if (evento.usuarioId === usuarioAtual.id) return true;

  const salvamento = salvamentosEventosEmMemoria.find(
    (item) =>
      item.usuarioId === usuarioAtual.id &&
      item.publicacaoTurmaId === publicacao.id
  );

  if (salvamento) {
    try {
      await obterEventoDoUsuarioPorId(salvamento.eventoPessoalId);
      return true;
    } catch (erro) {
      if (
        erro.codigo !== "EVENTO_NAO_ENCONTRADO" &&
        erro.codigo !== "EVENTO_NAO_PERTENCE_AO_USUARIO"
      ) throw erro;
    }
  }

  const equivalente = await encontrarEventoEquivalente(evento, usuarioAtual.id);
  return Boolean(equivalente);
}

function gerarCodigoUnico() {
  let codigo;

  do {
    codigo = Array.from(
      { length: 6 },
      () => CARACTERES_CODIGO[Math.floor(Math.random() * CARACTERES_CODIGO.length)]
    ).join("");
  } while (turmasEmMemoria.some((turma) => turma.codigo === codigo));

  return codigo;
}

export function listarTurmasDoUsuario() {
  return new Promise((resolve) => {
    setTimeout(() => {
      const turmasIdsDoUsuario = new Set(
        membrosEmMemoria
          .filter((membro) => membro.usuarioId === usuarioAtual.id)
          .map((membro) => membro.turmaId)
      );

      resolve(
        turmasEmMemoria
          .filter((turma) => turmasIdsDoUsuario.has(turma.id))
          .map(copiarTurma)
      );
    }, TEMPO_SIMULADO_MS);
  });
}

export async function obterTurmaPorId(turmaId) {
  await aguardarOperacaoSimulada();

  const turma = localizarTurma(turmaId);
  const associacaoUsuario = obterAssociacaoDoUsuario(turma.id);

  return {
    ...copiarTurma(turma),
    papelUsuario: associacaoUsuario.tipo,
    usuarioAdministrador: associacaoUsuario.tipo === "administrador",
  };
}

export async function listarMembrosDaTurma(turmaId) {
  await aguardarOperacaoSimulada();

  const turma = localizarTurma(turmaId);
  obterAssociacaoDoUsuario(turma.id);

  return membrosEmMemoria
    .filter((membro) => membro.turmaId === turma.id)
    .map(copiarMembro);
}

export async function listarSimuladosDaTurma(turmaId) {
  await aguardarOperacaoSimulada();

  const turma = localizarTurma(turmaId);
  obterAssociacaoDoUsuario(turma.id);

  const publicacoesDaTurma = publicacoesSimuladosEmMemoria.filter(
    (publicacao) => publicacao.turmaId === turma.id
  );
  const simuladosPublicados = await Promise.all(
    publicacoesDaTurma.map(async (publicacao) => {
      try {
        const simulado = await obterSimuladoPublicadoPorId(publicacao.simuladoId);

        return await prepararSimuladoPublicado(publicacao, simulado);
      } catch (erro) {
        if (erro.codigo === "SIMULADO_NAO_ENCONTRADO") return null;
        throw erro;
      }
    })
  );

  return simuladosPublicados
    .filter((simulado) => simulado !== null)
    .map((simulado) => ({ ...simulado }));
}

export async function listarEventosDaTurma(turmaId) {
  await aguardarOperacaoSimulada();

  const turma = localizarTurma(turmaId);
  obterAssociacaoDoUsuario(turma.id);

  const publicacoesDaTurma = publicacoesEventosEmMemoria.filter(
    (publicacao) => publicacao.turmaId === turma.id
  );
  const eventosPublicados = await Promise.all(
    publicacoesDaTurma.map(async (publicacao) => {
      try {
        const evento = await obterEventoPorId(publicacao.eventoId);
        const salvoPeloUsuario = await eventoEstaSalvoParaUsuario(
          publicacao,
          evento
        );

        return {
          idPublicacao: publicacao.id,
          eventoId: evento.id,
          titulo: evento.titulo,
          data: evento.data,
          diaInteiro: evento.tipo === "dia_inteiro",
          horaInicio: evento.horarioInicio,
          horaFim: evento.horarioFim,
          cor: evento.cor,
          dataPublicacao: publicacao.dataPublicacao,
          serieId: evento.serieId ?? null,
          salvoPeloUsuario,
        };
      } catch (erro) {
        if (erro.codigo === "EVENTO_NAO_ENCONTRADO") return null;
        throw erro;
      }
    })
  );

  return eventosPublicados
    .filter((evento) => evento !== null)
    .sort((eventoA, eventoB) => {
      const comparacaoData = eventoA.data.localeCompare(eventoB.data);
      if (comparacaoData !== 0) return comparacaoData;

      if (eventoA.diaInteiro !== eventoB.diaInteiro) {
        return eventoA.diaInteiro ? -1 : 1;
      }

      const comparacaoHorario = (eventoA.horaInicio ?? "").localeCompare(
        eventoB.horaInicio ?? ""
      );
      if (comparacaoHorario !== 0) return comparacaoHorario;

      return eventoA.titulo.localeCompare(eventoB.titulo, "pt-BR", {
        sensitivity: "base",
      });
    })
    .map((evento) => ({ ...evento }));
}

export async function publicarEventoNaTurma(turmaId, eventoId) {
  const turmaIdNormalizado = Number(turmaId);
  const eventoIdNormalizado = Number(eventoId);

  if (!Number.isInteger(turmaIdNormalizado)) {
    throw new Error("Turma não encontrada.");
  }

  if (!Number.isInteger(eventoIdNormalizado)) {
    throw new Error("Evento não encontrado.");
  }

  await aguardarOperacaoSimulada();

  const turma = localizarTurma(turmaIdNormalizado);
  const associacaoUsuario = obterAssociacaoDoUsuario(turma.id);

  if (associacaoUsuario.tipo !== "administrador") {
    throw new Error("Você não tem permissão para publicar eventos nesta turma.");
  }

  let evento;

  try {
    evento = await obterEventoDoUsuarioPorId(eventoIdNormalizado);
  } catch (erro) {
    if (erro.codigo === "EVENTO_NAO_ENCONTRADO") {
      throw new Error("Evento não encontrado.");
    }
    throw erro;
  }

  const eventoJaPublicado = publicacoesEventosEmMemoria.some(
    (publicacao) =>
      publicacao.turmaId === turma.id && publicacao.eventoId === evento.id
  );

  if (eventoJaPublicado) {
    throw new Error("Este evento já foi publicado nesta turma.");
  }

  const novaPublicacao = {
    id: proximoIdPublicacaoEvento,
    turmaId: turma.id,
    eventoId: evento.id,
    dataPublicacao: obterDataAtual(),
    publicadoPorUsuarioId: usuarioAtual.id,
  };

  proximoIdPublicacaoEvento += 1;
  publicacoesEventosEmMemoria.push({ ...novaPublicacao });

  return {
    idPublicacao: novaPublicacao.id,
    eventoId: evento.id,
    titulo: evento.titulo,
    data: evento.data,
    diaInteiro: evento.tipo === "dia_inteiro",
    horaInicio: evento.horarioInicio,
    horaFim: evento.horarioFim,
    cor: evento.cor,
    dataPublicacao: novaPublicacao.dataPublicacao,
    serieId: evento.serieId ?? null,
    salvoPeloUsuario: true,
  };
}

export async function adicionarEventoDaTurmaAoCalendario(publicacaoId) {
  const publicacaoIdNormalizado = Number(publicacaoId);

  if (!Number.isInteger(publicacaoIdNormalizado)) {
    throw new Error("Evento publicado não encontrado.");
  }

  await aguardarOperacaoSimulada();

  const publicacao = publicacoesEventosEmMemoria.find(
    (item) => item.id === publicacaoIdNormalizado
  );

  if (!publicacao) {
    throw new Error("Evento publicado não encontrado.");
  }

  const turma = localizarTurma(publicacao.turmaId);
  obterAssociacaoDoUsuario(turma.id);

  const eventoOriginal = await obterEventoPorId(publicacao.eventoId);

  if (eventoOriginal.usuarioId === usuarioAtual.id) {
    return {
      criado: false,
      eventoJaExistia: true,
      eventoPessoalId: eventoOriginal.id,
    };
  }

  const salvamentoExistente = salvamentosEventosEmMemoria.find(
    (item) =>
      item.usuarioId === usuarioAtual.id &&
      item.publicacaoTurmaId === publicacao.id
  );

  if (salvamentoExistente) {
    try {
      const eventoPessoal = await obterEventoDoUsuarioPorId(
        salvamentoExistente.eventoPessoalId
      );

      return {
        criado: false,
        eventoJaExistia: true,
        eventoPessoalId: eventoPessoal.id,
      };
    } catch (erro) {
      if (erro.codigo !== "EVENTO_NAO_ENCONTRADO") throw erro;
    }
  }

  const resultado = await salvarEventoCompartilhado({
    eventoOrigem: eventoOriginal,
    publicacaoTurmaId: publicacao.id,
    usuarioId: usuarioAtual.id,
  });

  registrarSalvamentoEvento(publicacao.id, resultado.evento.id);

  return {
    criado: resultado.criado,
    eventoJaExistia: !resultado.criado,
    eventoPessoalId: resultado.evento.id,
  };
}

export async function publicarSimuladoNaTurma(turmaId, simuladoId) {
  const turmaIdNormalizado = Number(turmaId);
  const simuladoIdNormalizado = Number(simuladoId);

  if (!Number.isInteger(turmaIdNormalizado)) {
    throw new Error("Turma não encontrada.");
  }

  if (!Number.isInteger(simuladoIdNormalizado)) {
    throw new Error("Simulado não encontrado.");
  }

  await aguardarOperacaoSimulada();

  const turma = localizarTurma(turmaIdNormalizado);
  const associacaoUsuario = obterAssociacaoDoUsuario(turma.id);

  if (associacaoUsuario.tipo !== "administrador") {
    throw new Error("Você não tem permissão para publicar simulados nesta turma.");
  }

  let simulado;

  try {
    simulado = await obterSimuladoDoUsuarioPorId(simuladoIdNormalizado);
  } catch (erro) {
    if (erro.codigo === "SIMULADO_NAO_ENCONTRADO") {
      throw new Error("Simulado não encontrado.");
    }
    throw erro;
  }

  const simuladoJaPublicado = publicacoesSimuladosEmMemoria.some(
    (publicacao) =>
      publicacao.turmaId === turma.id &&
      publicacao.simuladoId === simulado.id
  );

  if (simuladoJaPublicado) {
    throw new Error("Este simulado já foi publicado nesta turma.");
  }

  const novaPublicacao = {
    id: proximoIdPublicacao,
    turmaId: turma.id,
    simuladoId: simulado.id,
    dataPublicacao: obterDataAtual(),
    publicadoPorUsuarioId: usuarioAtual.id,
  };

  proximoIdPublicacao += 1;
  publicacoesSimuladosEmMemoria.push({ ...novaPublicacao });

  return { ...(await prepararSimuladoPublicado(novaPublicacao, simulado)) };
}

export async function adicionarSimuladoDaTurmaAosMeus(publicacaoId) {
  const publicacaoIdNormalizado = Number(publicacaoId);

  if (!Number.isInteger(publicacaoIdNormalizado)) {
    throw new Error("Simulado publicado não encontrado.");
  }

  await aguardarOperacaoSimulada();

  const publicacao = publicacoesSimuladosEmMemoria.find(
    (item) => item.id === publicacaoIdNormalizado
  );

  if (!publicacao) {
    throw new Error("Simulado publicado não encontrado.");
  }

  const turma = localizarTurma(publicacao.turmaId);
  obterAssociacaoDoUsuario(turma.id);

  const simuladoOriginal = await obterSimuladoPublicadoPorId(
    publicacao.simuladoId
  );
  const salvamentoExistente = salvamentosSimuladosEmMemoria.find(
    (item) =>
      item.usuarioId === usuarioAtual.id &&
      item.publicacaoTurmaId === publicacao.id
  );

  if (simuladoOriginal.proprietarioUsuarioId === usuarioAtual.id) {
    return {
      sucesso: true,
      simuladoPessoalId: simuladoOriginal.id,
      jaAdicionado: true,
    };
  }

  if (salvamentoExistente) {
    try {
      const simuladoPessoal = await obterSimuladoDoUsuarioPorId(
        salvamentoExistente.simuladoPessoalId
      );

      return {
        sucesso: true,
        simuladoPessoalId: simuladoPessoal.id,
        jaAdicionado: true,
      };
    } catch (erro) {
      if (erro.codigo !== "SIMULADO_NAO_ENCONTRADO") throw erro;
    }
  }

  let copiaPessoal;

  try {
    copiaPessoal = await salvarSimuladoCompartilhado({
      simuladoOrigemId: simuladoOriginal.id,
      publicacaoTurmaId: publicacao.id,
      usuarioId: usuarioAtual.id,
    });
  } catch (erro) {
    if (erro.codigo === "SIMULADO_JA_ADICIONADO") {
      registrarSalvamento(publicacao.id, erro.simuladoPessoalId);

      return {
        sucesso: true,
        simuladoPessoalId: erro.simuladoPessoalId,
        jaAdicionado: true,
      };
    }
    throw erro;
  }

  registrarSalvamento(publicacao.id, copiaPessoal.id);

  return {
    sucesso: true,
    simuladoPessoalId: copiaPessoal.id,
    jaAdicionado: false,
  };
}

export async function criarTurma({ nome }) {
  const nomeNormalizado = typeof nome === "string" ? nome.trim() : "";

  if (!nomeNormalizado) {
    throw new Error("Digite um nome para a turma.");
  }

  await aguardarOperacaoSimulada();

  const nomeCriador = `${usuarioAtual.nome} ${usuarioAtual.sobrenome}`.trim();
  const novaTurma = {
    id: proximoIdTurma,
    nome: nomeNormalizado,
    codigo: gerarCodigoUnico(),
    criador: nomeCriador,
    criadorId: usuarioAtual.id,
    administradorId: usuarioAtual.id,
    imagem: null,
    cor: "#2f5d8a",
    quantidadeAlunos: 0,
  };
  const novoMembro = {
    id: proximoIdMembro,
    turmaId: novaTurma.id,
    usuarioId: usuarioAtual.id,
    nome: nomeCriador,
    tipo: "administrador",
    fotoPerfil: usuarioAtual.fotoPerfil,
  };

  proximoIdTurma += 1;
  proximoIdMembro += 1;
  turmasEmMemoria.push({ ...novaTurma });
  membrosEmMemoria.push({ ...novoMembro });

  return copiarTurma(novaTurma);
}

export async function entrarEmTurma(codigo) {
  const codigoNormalizado = typeof codigo === "string" ? codigo.trim().toUpperCase() : "";

  if (!codigoNormalizado) {
    throw new Error("Digite o código da turma.");
  }

  await aguardarOperacaoSimulada();

  const turma = turmasEmMemoria.find(
    (item) => item.codigo.toUpperCase() === codigoNormalizado
  );

  if (!turma) {
    throw new Error("Turma não encontrada.");
  }

  const usuarioJaParticipa = membrosEmMemoria.some(
    (membro) =>
      membro.turmaId === turma.id && membro.usuarioId === usuarioAtual.id
  );

  if (usuarioJaParticipa) {
    throw new Error("Você já participa desta turma.");
  }

  const nomeUsuario = `${usuarioAtual.nome} ${usuarioAtual.sobrenome}`.trim();
  const novoMembro = {
    id: proximoIdMembro,
    turmaId: turma.id,
    usuarioId: usuarioAtual.id,
    nome: nomeUsuario,
    tipo: "aluno",
    fotoPerfil: usuarioAtual.fotoPerfil,
  };

  proximoIdMembro += 1;
  membrosEmMemoria.push({ ...novoMembro });
  turma.quantidadeAlunos += 1;

  return copiarTurma(turma);
}
