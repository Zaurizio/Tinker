class EventoCalendario {
  final String id;
  final String titulo;
  final DateTime data;
  final String? horarioInicio;
  final String? horarioFim;
  final bool diaInteiro;
  final String? cor;
  final String? disciplina;
  final String? conteudo;
  final String? descricao;

  EventoCalendario({
    required this.id,
    required this.titulo,
    required this.data,
    this.horarioInicio,
    this.horarioFim,
    required this.diaInteiro,
    this.cor,
    this.disciplina,
    this.conteudo,
    this.descricao,
  });

  factory EventoCalendario.fromApi(Map<String, dynamic> json) {
    return EventoCalendario(
      id: json['id'].toString(),
      titulo: (json['titulo'] ?? '').toString(),
      data: DateTime.parse(json['data']),
      horarioInicio: _normalizarHora(json['horarioInicio']),
      horarioFim: _normalizarHora(json['horarioFim']),
      diaInteiro: json['diaInteiro'] == true,
      cor: json['cor']?.toString(),
      disciplina: json['disciplina']?.toString(),
      conteudo: json['conteudo']?.toString(),
      descricao: json['descricao']?.toString(),
    );
  }

  static String? _normalizarHora(dynamic valor) {
    if (valor == null) return null;
    final partes = valor.toString().split(':');
    if (partes.length >= 2) return '${partes[0]}:${partes[1]}';
    return valor.toString();
  }
}
