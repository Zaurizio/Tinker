class PublicacaoSimulado {
  final String idPublicacao;
  final int simuladoId;
  final String titulo;
  final String? descricao;
  final DateTime dataPublicacao;

  PublicacaoSimulado({
    required this.idPublicacao,
    required this.simuladoId,
    required this.titulo,
    this.descricao,
    required this.dataPublicacao,
  });

  factory PublicacaoSimulado.fromApi(Map<String, dynamic> json) {
    return PublicacaoSimulado(
      idPublicacao: (json['idPublicacao'] ?? '').toString(),
      simuladoId: json['simuladoId'] is int
          ? json['simuladoId']
          : int.parse(json['simuladoId'].toString()),
      titulo: (json['titulo'] ?? '').toString(),
      descricao: json['descricao']?.toString(),
      dataPublicacao: DateTime.parse(json['dataPublicacao']),
    );
  }
}
