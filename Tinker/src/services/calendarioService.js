import { eventos } from "../data/calendario";
import { usuarioAtual } from "../data/usuario";

const eventosEmMemoria = eventos.map((evento) => ({
  ...evento,
  serieId: evento.serieId ?? null,
  recorrencia: evento.recorrencia ?? "Não se repete",
}));
let proximoId =
  eventosEmMemoria.reduce(
    (maiorId, evento) => Math.max(maiorId, Number(evento.id) || 0),
    0
  ) + 1;
let proximaSerieId =
  eventosEmMemoria.reduce((maiorSerieId, evento) => {
    const resultado = /^serie-(\d+)$/.exec(String(evento.serieId ?? ""));
    return resultado ? Math.max(maiorSerieId, Number(resultado[1])) : maiorSerieId;
  }, 0) + 1;

function idsSaoIguais(primeiroId, segundoId) {
  return String(primeiroId) === String(segundoId);
}

function copiarEvento(evento) {
  return { ...evento };
}

function normalizarTitulo(titulo) {
  return typeof titulo === "string" ? titulo.trim().toLowerCase() : "";
}

function eventoEhDiaInteiro(evento) {
  return evento?.tipo === "dia_inteiro" || evento?.diaInteiro === true;
}

function eventosSaoEquivalentes(eventoA, eventoB) {
  const eventoADiaInteiro = eventoEhDiaInteiro(eventoA);
  const eventoBDiaInteiro = eventoEhDiaInteiro(eventoB);

  if (
    normalizarTitulo(eventoA?.titulo) !== normalizarTitulo(eventoB?.titulo) ||
    eventoA?.data !== eventoB?.data ||
    eventoADiaInteiro !== eventoBDiaInteiro
  ) return false;

  if (eventoADiaInteiro) return true;

  return (
    (eventoA?.horarioInicio ?? null) === (eventoB?.horarioInicio ?? null) &&
    (eventoA?.horarioFim ?? null) === (eventoB?.horarioFim ?? null)
  );
}

function formatarDataLocal(data) {
  return [
    data.getFullYear(),
    String(data.getMonth() + 1).padStart(2, "0"),
    String(data.getDate()).padStart(2, "0"),
  ].join("-");
}

function interpretarData(data) {
  const resultado = /^(\d{4})-(\d{2})-(\d{2})$/.exec(data ?? "");
  if (!resultado) return null;

  const [, ano, mes, dia] = resultado.map(Number);
  const dataInterpretada = new Date(ano, mes - 1, dia, 12);

  if (
    dataInterpretada.getFullYear() !== ano ||
    dataInterpretada.getMonth() !== mes - 1 ||
    dataInterpretada.getDate() !== dia
  ) return null;

  return dataInterpretada;
}

function interpretarHorario(horario) {
  const resultado = /^(\d{2}):(\d{2})$/.exec(horario ?? "");
  if (!resultado) return null;

  const horas = Number(resultado[1]);
  const minutos = Number(resultado[2]);
  if (horas > 23 || minutos > 59) return null;

  return { horas, minutos, totalMinutos: horas * 60 + minutos };
}

function validarDadosEvento(dadosEvento) {
  const titulo = typeof dadosEvento?.titulo === "string"
    ? dadosEvento.titulo.trim()
    : "";
  if (!titulo) throw new Error("Digite um nome para o evento.");

  const dataInterpretada = interpretarData(dadosEvento?.data);
  if (!dataInterpretada) throw new Error("Informe uma data válida.");

  const hoje = new Date();
  const dataHoje = formatarDataLocal(hoje);
  if (dadosEvento.data < dataHoje) {
    throw new Error("Não é possível marcar um evento em uma data ou horário que já passou.");
  }

  if (!dadosEvento.diaInteiro) {
    const inicio = interpretarHorario(dadosEvento.horarioInicio);
    const fim = interpretarHorario(dadosEvento.horarioFim);
    if (!inicio || !fim) throw new Error("Informe horários válidos.");
    if (fim.totalMinutos <= inicio.totalMinutos) {
      throw new Error("O horário final deve ser maior que o horário inicial.");
    }

    if (dadosEvento.data === dataHoje) {
      const inicioEvento = new Date(
        dataInterpretada.getFullYear(),
        dataInterpretada.getMonth(),
        dataInterpretada.getDate(),
        inicio.horas,
        inicio.minutos
      );
      if (inicioEvento <= hoje) {
        throw new Error("Não é possível marcar um evento em uma data ou horário que já passou.");
      }
    }
  }

  return {
    titulo,
    data: dadosEvento.data,
    horarioInicio: dadosEvento.diaInteiro ? null : dadosEvento.horarioInicio,
    horarioFim: dadosEvento.diaInteiro ? null : dadosEvento.horarioFim,
    diaInteiro: Boolean(dadosEvento.diaInteiro),
    recorrencia: dadosEvento.recorrencia,
    cor: dadosEvento.cor,
  };
}

function avancarMesPreservandoDiaOriginal(data, diaOriginal) {
  const proximoMes = data.getMonth() + 1;
  const anoDestino = data.getFullYear() + Math.floor(proximoMes / 12);
  const mesDestino = proximoMes % 12;
  const ultimoDiaDoMes = new Date(anoDestino, mesDestino + 1, 0).getDate();

  data.setFullYear(
    anoDestino,
    mesDestino,
    Math.min(diaOriginal, ultimoDiaDoMes)
  );
}

function gerarOcorrencias(dadosEvento) {
  const dataOcorrencia = interpretarData(dadosEvento.data);
  const diaOriginal = dataOcorrencia.getDate();
  const configuracoes = {
    "Não se repete": { total: 1 },
    "Todos os dias": {
      total: 365,
      avancar: (data) => data.setDate(data.getDate() + 1),
    },
    Semanal: {
      total: 52,
      avancar: (data) => data.setDate(data.getDate() + 7),
    },
    Mensal: {
      total: 12,
      avancar: (data) => avancarMesPreservandoDiaOriginal(data, diaOriginal),
    },
    Anual: {
      total: 5,
      avancar: (data) => data.setFullYear(data.getFullYear() + 1),
    },
  };
  const configuracao =
    configuracoes[dadosEvento.recorrencia] ?? configuracoes["Não se repete"];
  const ocorrencias = [];
  const recorrente = configuracao.total > 1;
  const serieId = recorrente ? `serie-${proximaSerieId}` : null;
  if (recorrente) proximaSerieId += 1;

  for (let indice = 0; indice < configuracao.total; indice += 1) {
    ocorrencias.push({
      id: proximoId,
      titulo: dadosEvento.titulo,
      data: formatarDataLocal(dataOcorrencia),
      tipo: dadosEvento.diaInteiro ? "dia_inteiro" : "com_horario",
      horarioInicio: dadosEvento.horarioInicio,
      horarioFim: dadosEvento.horarioFim,
      cor: dadosEvento.cor,
      recorrencia: dadosEvento.recorrencia,
      serieId,
      usuarioId: usuarioAtual.id,
    });
    proximoId += 1;
    configuracao.avancar?.(dataOcorrencia);
  }

  return ocorrencias;
}

function converterEventoParaCalendario(evento) {
  const diaInteiro = evento.tipo === "dia_inteiro";
  return {
    id: evento.id,
    title: evento.titulo,
    start: diaInteiro ? evento.data : `${evento.data}T${evento.horarioInicio}:00`,
    end: !diaInteiro && evento.horarioFim
      ? `${evento.data}T${evento.horarioFim}:00`
      : undefined,
    allDay: diaInteiro,
    color: evento.cor,
    extendedProps: {
      serieId: evento.serieId ?? null,
      recorrencia: evento.recorrencia ?? "Não se repete",
      data: evento.data,
      horarioInicio: evento.horarioInicio,
      horarioFim: evento.horarioFim,
    },
  };
}

export async function listarEventosDoUsuario() {
  return eventosEmMemoria
    .filter((evento) => evento.usuarioId === usuarioAtual.id)
    .map((evento) => ({
      ...converterEventoParaCalendario(evento),
    }));
}

export async function criarEvento(dadosEvento) {
  const dadosValidados = validarDadosEvento(dadosEvento);
  const ocorrencias = gerarOcorrencias(dadosValidados);

  eventosEmMemoria.push(...ocorrencias.map((evento) => ({ ...evento })));
  return ocorrencias.map((evento) => ({
    ...converterEventoParaCalendario(evento),
  }));
}

export async function obterEventoPorId(eventoId) {
  const evento = eventosEmMemoria.find((item) => idsSaoIguais(item.id, eventoId));
  if (!evento) {
    const erro = new Error("Evento não encontrado.");
    erro.codigo = "EVENTO_NAO_ENCONTRADO";
    throw erro;
  }

  return copiarEvento(evento);
}

export async function obterEventoDoUsuarioPorId(eventoId) {
  const evento = await obterEventoPorId(eventoId);

  if (evento.usuarioId !== usuarioAtual.id) {
    const erro = new Error("Este evento não pertence ao usuário atual.");
    erro.codigo = "EVENTO_NAO_PERTENCE_AO_USUARIO";
    throw erro;
  }

  return copiarEvento(evento);
}

export async function encontrarEventoEquivalente(dadosEvento, usuarioId) {
  const usuarioIdNormalizado = Number(usuarioId);
  if (!Number.isInteger(usuarioIdNormalizado)) return null;

  const evento = eventosEmMemoria.find(
    (item) =>
      item.usuarioId === usuarioIdNormalizado &&
      eventosSaoEquivalentes(item, dadosEvento)
  );

  return evento ? copiarEvento(evento) : null;
}

export async function salvarEventoCompartilhado({
  eventoOrigem,
  publicacaoTurmaId,
  usuarioId,
}) {
  const usuarioIdNormalizado = Number(usuarioId);
  const publicacaoIdNormalizado = Number(publicacaoTurmaId);

  if (!eventoOrigem || !Number.isInteger(Number(eventoOrigem.id))) {
    throw new Error("Evento não encontrado.");
  }

  if (!Number.isInteger(usuarioIdNormalizado)) {
    throw new Error("Usuário inválido.");
  }

  if (!Number.isInteger(publicacaoIdNormalizado)) {
    throw new Error("Evento publicado não encontrado.");
  }

  const eventoExistente = await encontrarEventoEquivalente(
    eventoOrigem,
    usuarioIdNormalizado
  );

  if (eventoExistente) {
    return { evento: copiarEvento(eventoExistente), criado: false };
  }

  const copiaPessoal = {
    ...eventoOrigem,
    id: proximoId,
    usuarioId: usuarioIdNormalizado,
    eventoOrigemId: eventoOrigem.id,
    publicacaoTurmaId: publicacaoIdNormalizado,
    serieId: null,
    recorrencia: "Não se repete",
  };

  proximoId += 1;
  eventosEmMemoria.push({ ...copiaPessoal });

  return { evento: copiarEvento(copiaPessoal), criado: true };
}

export async function possuiOutrasOcorrenciasDaSerie(eventoId) {
  const evento = eventosEmMemoria.find((item) => idsSaoIguais(item.id, eventoId));
  if (!evento) throw new Error("Evento não encontrado.");

  if (!evento.serieId || evento.recorrencia === "Não se repete") return false;

  return eventosEmMemoria.some(
    (item) => item.serieId === evento.serieId && !idsSaoIguais(item.id, evento.id)
  );
}

export async function excluirEvento(eventoId) {
  const indiceEvento = eventosEmMemoria.findIndex(
    (evento) => idsSaoIguais(evento.id, eventoId)
  );
  if (indiceEvento === -1) throw new Error("Evento não encontrado.");

  const [eventoRemovido] = eventosEmMemoria.splice(indiceEvento, 1);
  return copiarEvento(eventoRemovido);
}

export async function excluirSerieEventos(serieId) {
  const serieNormalizada = String(serieId ?? "");
  if (!serieNormalizada) throw new Error("Sequência de eventos não encontrada.");

  const eventosDaSerie = eventosEmMemoria.filter(
    (evento) => String(evento.serieId ?? "") === serieNormalizada
  );
  if (eventosDaSerie.length === 0) {
    throw new Error("Sequência de eventos não encontrada.");
  }

  for (let indice = eventosEmMemoria.length - 1; indice >= 0; indice -= 1) {
    if (String(eventosEmMemoria[indice].serieId ?? "") === serieNormalizada) {
      eventosEmMemoria.splice(indice, 1);
    }
  }

  return eventosDaSerie.map(copiarEvento);
}
