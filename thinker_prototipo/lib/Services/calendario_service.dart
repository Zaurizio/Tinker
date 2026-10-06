import 'package:flutter/material.dart';
import 'package:tinker/Services/api_client.dart';
import 'package:tinker/Models/evento_calendario_model.dart';

Future<List<EventoCalendario>> buscarEventos() async {
  final dados = await apiGet('/calendario/eventos') as List;
  return dados.map((e) => EventoCalendario.fromApi(e)).toList();
}

String? _formatarHora(TimeOfDay? t) {
  if (t == null) return null;
  return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
}

Future<List<EventoCalendario>> criarEvento({
  required String titulo,
  required DateTime data,
  TimeOfDay? horarioInicio,
  TimeOfDay? horarioFim,
  required bool diaInteiro,
  required String cor,
  required String recorrencia,
  int? repeticoes,
  String? disciplina,
  String? conteudo,
  String? descricao,
}) async {
  final ano = data.year.toString().padLeft(4, '0');
  final mes = data.month.toString().padLeft(2, '0');
  final dia = data.day.toString().padLeft(2, '0');

  final dados = await apiPost('/calendario/eventos', {
    'titulo': titulo,
    'data': '$ano-$mes-$dia',
    'horarioInicio': diaInteiro ? null : _formatarHora(horarioInicio),
    'horarioFim': diaInteiro ? null : _formatarHora(horarioFim),
    'diaInteiro': diaInteiro,
    'cor': cor,
    'recorrencia': recorrencia,
    if (repeticoes != null) 'repeticoes': repeticoes,
    if (disciplina != null && disciplina.trim().isNotEmpty) 'disciplina': disciplina.trim(),
    if (conteudo != null && conteudo.trim().isNotEmpty) 'conteudo': conteudo.trim(),
    if (descricao != null && descricao.trim().isNotEmpty) 'descricao': descricao.trim(),
  }) as List;

  return dados.map((e) => EventoCalendario.fromApi(e)).toList();
}

Future<void> removerEvento(String id) async {
  await apiDelete('/calendario/eventos/$id');
}
