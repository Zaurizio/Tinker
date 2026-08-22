class Alternativa {
  final String id;
  final String texto;
  final bool correta;
  bool eliminada;

  Alternativa({
    required this.id,
    required this.texto,
    this.correta = false,
    this.eliminada = false,
  });
}

class Questao {
  final String id;
  final String materia;
  final String assunto;
  final String instituicao;
  final String ano;
  final String enunciado;
  final List<Alternativa> alternativas;

  bool salva;
  bool respondida;
  String? alternativaSelecionadaId;

  Questao({
    required this.id,
    required this.materia,
    required this.assunto,
    required this.instituicao,
    required this.ano,
    required this.enunciado,
    required this.alternativas,
    this.salva = false,
    this.respondida = false,
    this.alternativaSelecionadaId,
  });
}