class MembroTurmaModel {
  final String email;
  final String nome;
  final String sobrenome;
  final String? fotoBase64;

  MembroTurmaModel({
    required this.email,
    required this.nome,
    required this.sobrenome,
    this.fotoBase64,
  });

  factory MembroTurmaModel.fromApi(Map<String, dynamic> json) {
    return MembroTurmaModel(
      email: (json['email'] ?? '').toString(),
      nome: (json['nome'] ?? '').toString(),
      sobrenome: (json['sobrenome'] ?? '').toString(),
      fotoBase64: json['foto']?.toString(),
    );
  }

  String get nomeCompleto => '$nome $sobrenome'.trim();
}