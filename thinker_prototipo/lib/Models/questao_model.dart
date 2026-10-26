class Alternativa {
  final String id;
  final String texto;
  bool eliminada;

  Alternativa({
    required this.id,
    required this.texto,
    this.eliminada = false,
  });

  factory Alternativa.fromApi(Map<String, dynamic> json) {
    return Alternativa(
      id: (json['id'] ?? '').toString(),
      texto: (json['texto'] ?? '').toString(),
    );
  }
}

class Questao {
  final int id;
  final String vestibular;
  final int? ano;
  final String? fase;
  final String materia;
  final String assunto;
  final String enunciado;
  final List<Alternativa> alternativas;

  bool salva;
  bool respondida;
  bool? ultimaRespostaCorreta;
  String? alternativaSelecionadaId;

  Questao({
    required this.id,
    required this.vestibular,
    this.ano,
    this.fase,
    required this.materia,
    required this.assunto,
    required this.enunciado,
    required this.alternativas,
    this.salva = false,
    this.respondida = false,
    this.ultimaRespostaCorreta,
    this.alternativaSelecionadaId,
  });

  factory Questao.fromApi(Map<String, dynamic> json) {
    final alternativasJson = (json['alternativas'] as List?) ?? [];

    return Questao(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      vestibular: (json['vestibular'] ?? '').toString(),
      ano: json['ano'] == null
          ? null
          : (json['ano'] is int ? json['ano'] : int.tryParse(json['ano'].toString())),
      fase: json['fase']?.toString(),
      materia: (json['disciplina'] ?? '').toString(),
      assunto: (json['conteudo'] ?? '').toString(),
      enunciado: (json['enunciado'] ?? '').toString(),
      alternativas:
          alternativasJson.map((a) => Alternativa.fromApi(a)).toList(),
    );
  }

  String get ano_ => ano?.toString() ?? '';
  String get instituicao => vestibular;
}
