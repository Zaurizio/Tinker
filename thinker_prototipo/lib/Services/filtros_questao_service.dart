import 'package:tinker/Services/api_client.dart';

class FiltrosQuestao {
  final List<String> disciplinas;
  final List<String> vestibulares;
  final List<String> conteudos;
  final List<int> anos;

  FiltrosQuestao({
    required this.disciplinas,
    required this.vestibulares,
    required this.conteudos,
    required this.anos,
  });

  factory FiltrosQuestao.fromApi(Map<String, dynamic> json) {
    return FiltrosQuestao(
      disciplinas: List<String>.from(json['disciplinas'] ?? []),
      vestibulares: List<String>.from(json['vestibulares'] ?? []),
      conteudos: List<String>.from(json['conteudos'] ?? []),
      anos: List<int>.from(json['anos'] ?? []),
    );
  }
}

Future<FiltrosQuestao> buscarFiltrosDisponiveis() async {
  final dados = await apiGet('/questoes/filtros');
  return FiltrosQuestao.fromApi(dados);
}
