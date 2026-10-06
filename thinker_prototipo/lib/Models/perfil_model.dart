class PerfilModel {
  final String email;
  final String nome;
  final String sobrenome;
  final String tipoUsuario;
  final DateTime? nascimento;
  final int ativo;
  final String? fotoBase64;

  PerfilModel({
    required this.email,
    required this.nome,
    required this.sobrenome,
    required this.tipoUsuario,
    this.nascimento,
    required this.ativo,
    this.fotoBase64,
  });

  factory PerfilModel.fromApi(Map<String, dynamic> json) {
    return PerfilModel(
      email: (json['email'] ?? '').toString(),
      nome: (json['nome'] ?? '').toString(),
      sobrenome: (json['sobrenome'] ?? '').toString(),
      tipoUsuario: (json['tipoUsuario'] ?? '').toString(),
      nascimento:
          json['nascimento'] == null ? null : DateTime.tryParse(json['nascimento'].toString()),
      ativo: json['ativo'] is int ? json['ativo'] : int.parse((json['ativo'] ?? 1).toString()),
      fotoBase64: json['foto']?.toString(),
    );
  }

  String get nomeCompleto => '$nome $sobrenome'.trim();

  int? get idade {
    if (nascimento == null) return null;
    final hoje = DateTime.now();
    int anos = hoje.year - nascimento!.year;
    if (hoje.month < nascimento!.month ||
        (hoje.month == nascimento!.month && hoje.day < nascimento!.day)) {
      anos--;
    }
    return anos;
  }
}
