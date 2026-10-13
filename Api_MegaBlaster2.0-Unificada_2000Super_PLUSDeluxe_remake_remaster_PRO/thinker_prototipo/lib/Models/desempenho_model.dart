class DesempenhoDisciplina {
  final String disciplina;
  final int percentualAcertos;
  final int numeroAcertos;
  final int questoesFeitas;

  DesempenhoDisciplina({
    required this.disciplina,
    required this.percentualAcertos,
    required this.numeroAcertos,
    required this.questoesFeitas,
  });

  factory DesempenhoDisciplina.fromApi(Map<String, dynamic> json) {
    return DesempenhoDisciplina(
      disciplina: (json['disciplina'] ?? '').toString(),
      percentualAcertos: json['percentualAcertos'] ?? 0,
      numeroAcertos: json['numeroAcertos'] ?? 0,
      questoesFeitas: json['questoesFeitas'] ?? 0,
    );
  }
}

class DesempenhoResumo {
  final int questoesRespondidas;
  final int totalAcertos;
  final int percentualGeral;
  final DesempenhoDisciplina? maiorDesempenho;
  final DesempenhoDisciplina? menorDesempenho;
  final List<DesempenhoDisciplina> disciplinas;

  DesempenhoResumo({
    required this.questoesRespondidas,
    required this.totalAcertos,
    required this.percentualGeral,
    this.maiorDesempenho,
    this.menorDesempenho,
    required this.disciplinas,
  });

  factory DesempenhoResumo.fromApi(Map<String, dynamic> json) {
    return DesempenhoResumo(
      questoesRespondidas: json['questoesRespondidas'] ?? 0,
      totalAcertos: json['totalAcertos'] ?? 0,
      percentualGeral: json['percentualGeral'] ?? 0,
      maiorDesempenho: json['maiorDesempenho'] == null
          ? null
          : DesempenhoDisciplina.fromApi(json['maiorDesempenho']),
      menorDesempenho: json['menorDesempenho'] == null
          ? null
          : DesempenhoDisciplina.fromApi(json['menorDesempenho']),
      disciplinas: (json['disciplinas'] as List? ?? [])
          .map((d) => DesempenhoDisciplina.fromApi(d))
          .toList(),
    );
  }
}
