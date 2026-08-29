import { apiService } from "./apiService";

const RECORRENCIAS = {
  "Não se repete": { recorrencia: "NENHUMA", repeticoes: 1 },
  "Todos os dias": { recorrencia: "DIARIA", repeticoes: 365 },
  Semanal: { recorrencia: "SEMANAL", repeticoes: 52 },
  Mensal: { recorrencia: "MENSAL", repeticoes: 12 },
};

function normalizarHorario(horario) {
  return typeof horario === "string" ? horario.slice(0, 5) : null;
}

function prepararEvento(evento) {
  const horarioInicio = normalizarHorario(evento.horarioInicio);
  const horarioFim = normalizarHorario(evento.horarioFim);

  return {
    id: String(evento.id),
    title: evento.titulo,
    titulo: evento.titulo,
    start: evento.diaInteiro
      ? evento.data
      : `${evento.data}T${horarioInicio}`,
    end:
      !evento.diaInteiro && horarioFim
        ? `${evento.data}T${horarioFim}`
        : undefined,
    allDay: evento.diaInteiro,
    color: evento.cor,
    data: evento.data,
    horarioInicio,
    horarioFim,
    diaInteiro: evento.diaInteiro,
    cor: evento.cor,
    extendedProps: {
      data: evento.data,
      horarioInicio,
      horarioFim,
      diaInteiro: evento.diaInteiro,
      cor: evento.cor,
    },
  };
}

export async function listarEventosDoCalendario() {
  const eventos = await apiService.get("/api/calendario/eventos", {
    autenticada: true,
  });

  return eventos.map(prepararEvento);
}

export async function criarEventoNoCalendario(dadosEvento) {
  const configuracaoRecorrencia =
    RECORRENCIAS[dadosEvento.recorrencia] ?? RECORRENCIAS["Não se repete"];
  const diaInteiro = Boolean(dadosEvento.diaInteiro);
  const eventos = await apiService.post(
    "/api/calendario/eventos",
    {
      titulo: dadosEvento.titulo,
      data: dadosEvento.data,
      horarioInicio: diaInteiro ? null : dadosEvento.horarioInicio,
      horarioFim: diaInteiro ? null : dadosEvento.horarioFim,
      diaInteiro,
      cor: dadosEvento.cor,
      recorrencia: configuracaoRecorrencia.recorrencia,
      repeticoes: configuracaoRecorrencia.repeticoes,
    },
    { autenticada: true }
  );

  return eventos.map(prepararEvento);
}

export async function excluirEventoDoCalendario(eventoId) {
  await apiService.delete(
    `/api/calendario/eventos/${encodeURIComponent(String(eventoId))}`,
    { autenticada: true }
  );
}
