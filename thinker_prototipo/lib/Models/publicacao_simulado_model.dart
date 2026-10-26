class PublicacaoSimulado {
  final String idPublicacao;
  final int simuladoId;
  final String titulo;
  final String? descricao;
  final DateTime dataPublicacao;
  final int quantidadeQuestoes;
  final bool concluido;

  PublicacaoSimulado({
    required this.idPublicacao,
    required this.simuladoId,
    required this.titulo,
    this.descricao,
    required this.dataPublicacao,
    this.quantidadeQuestoes = 0,
    this.concluido = false,
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
      quantidadeQuestoes: json['quantidadeQuestoes'] is int
          ? json['quantidadeQuestoes']
          : int.tryParse((json['quantidadeQuestoes'] ?? 0).toString()) ?? 0,
      concluido: json['concluido'] == true,
    );
  }
}
