class AlunoModel {
  final String email;
  final String? nome;
  final String? sobrenome;

  AlunoModel({required this.email, this.nome, this.sobrenome});

  factory AlunoModel.fromApi(Map<String, dynamic> json) {
    return AlunoModel(
      email: (json['email'] ?? '').toString(),
      nome: json['nome']?.toString(),
      sobrenome: json['sobrenome']?.toString(),
    );
  }
}
