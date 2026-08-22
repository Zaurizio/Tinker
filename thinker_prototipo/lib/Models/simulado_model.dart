class SimuladoModel {
  final String id;
  final String nome;
  final String materia;
  final List<String> questoesIds;

  SimuladoModel({
    required this.id,
    required this.nome,
    required this.materia,
    List<String>? questoesIds,
  }) : questoesIds = questoesIds ?? [];
}