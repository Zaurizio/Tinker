class TurmaModel {
  final String codigo;
  final String nome;
  final String criadorNome;

  TurmaModel({
    required this.codigo,
    required this.nome,
    required this.criadorNome,
  });

  factory TurmaModel.fromApi(Map<String, dynamic> json) {
    return TurmaModel(
      codigo: (json['codigo'] ?? '').toString(),
      nome: (json['nome'] ?? '').toString(),
      criadorNome: (json['criadorNome'] ?? '').toString(),
    );
  }
}
