export function interpretarDataLocal(dataEvento) {
  const resultado = /^(\d{4})-(\d{2})-(\d{2})$/.exec(dataEvento ?? "");
  if (!resultado) return null;

  const [, ano, mes, dia] = resultado.map(Number);
  const data = new Date(ano, mes - 1, dia, 12);

  if (
    data.getFullYear() !== ano ||
    data.getMonth() !== mes - 1 ||
    data.getDate() !== dia
  ) return null;

  return data;
}

export function abreviarParteData(data, tipo) {
  return new Intl.DateTimeFormat("pt-BR", { [tipo]: "short" })
    .format(data)
    .replace(".", "")
    .slice(0, 3)
    .toUpperCase();
}

export function formatarDataCurta(dataEvento) {
  const data = interpretarDataLocal(dataEvento);
  if (!data) return dataEvento;

  return new Intl.DateTimeFormat("pt-BR").format(data);
}

export function formatarHorarioEvento(evento) {
  if (evento.diaInteiro) return "Dia inteiro";
  if (evento.horaInicio && evento.horaFim) {
    return `${evento.horaInicio} – ${evento.horaFim}`;
  }
  return evento.horaInicio ?? evento.horaFim ?? "Horário não informado";
}
