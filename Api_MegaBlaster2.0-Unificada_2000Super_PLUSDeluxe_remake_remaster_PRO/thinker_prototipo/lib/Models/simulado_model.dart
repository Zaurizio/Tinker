class SimuladoResumo {
  final int id;
  final String titulo;
  final int quantidadeQuestoes;

  SimuladoResumo({
    required this.id,
    required this.titulo,
    required this.quantidadeQuestoes,
  });

  factory SimuladoResumo.fromApi(Map<String, dynamic> json) {
    return SimuladoResumo(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      titulo: (json['titulo'] ?? '').toString(),
      quantidadeQuestoes: json['quantidadeQuestoes'] is int
          ? json['quantidadeQuestoes']
          : int.parse((json['quantidadeQuestoes'] ?? 0).toString()),
    );
  }
}

class SimuladoDetalheDTO {
  final int id;
  final String titulo;
  final String? descricao;
  final double? tempo;
  final int quantidadeQuestoes;
  final List<dynamic> questoes;

  SimuladoDetalheDTO({
    required this.id,
    required this.titulo,
    this.descricao,
    this.tempo,
    required this.quantidadeQuestoes,
    required this.questoes,
  });

  factory SimuladoDetalheDTO.fromApi(Map<String, dynamic> json) {
    return SimuladoDetalheDTO(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      titulo: (json['titulo'] ?? '').toString(),
      descricao: json['descricao']?.toString(),
      tempo: json['tempo'] == null
          ? null
          : (json['tempo'] is num
              ? (json['tempo'] as num).toDouble()
              : double.tryParse(json['tempo'].toString())),
      quantidadeQuestoes: json['quantidadeQuestoes'] is int
          ? json['quantidadeQuestoes']
          : int.parse((json['quantidadeQuestoes'] ?? 0).toString()),
      questoes: (json['questoes'] as List?) ?? [],
    );
  }
}
