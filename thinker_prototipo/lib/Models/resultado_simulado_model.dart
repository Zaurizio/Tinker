class ResultadoIndividualSimulado {
  final int simuladoId;
  final int quantidadeQuestoes;
  final bool completo;
  final int? acertos;
  final int? erros;

  ResultadoIndividualSimulado({
    required this.simuladoId,
    required this.quantidadeQuestoes,
    required this.completo,
    this.acertos,
    this.erros,
  });

  factory ResultadoIndividualSimulado.fromApi(Map<String, dynamic> json) {
    return ResultadoIndividualSimulado(
      simuladoId: json['simuladoId'] is int
          ? json['simuladoId']
          : int.parse(json['simuladoId'].toString()),
      quantidadeQuestoes: json['quantidadeQuestoes'] ?? 0,
      completo: json['completo'] == true,
      acertos: json['acertos'],
      erros: json['erros'],
    );
  }
}

class ConclusaoSimulado {
  final int simuladoId;
  final int quantidadeQuestoes;
  final int acertos;
  final int erros;
  final bool completo;

  ConclusaoSimulado({
    required this.simuladoId,
    required this.quantidadeQuestoes,
    required this.acertos,
    required this.erros,
    required this.completo,
  });

  factory ConclusaoSimulado.fromApi(Map<String, dynamic> json) {
    return ConclusaoSimulado(
      simuladoId: json['simuladoId'] is int
          ? json['simuladoId']
          : int.parse(json['simuladoId'].toString()),
      quantidadeQuestoes: json['quantidadeQuestoes'] ?? 0,
      acertos: json['acertos'] ?? 0,
      erros: json['erros'] ?? 0,
      completo: json['completo'] == true,
    );
  }
}
