import 'package:tinker/Services/api_client.dart';
import 'package:tinker/Models/simulado_model.dart';
import 'package:tinker/Models/questao_model.dart';
import 'package:tinker/Services/questoes_service.dart';

Future<List<SimuladoResumo>> buscarSimulados() async {
  final dados = await apiGet('/simulados');
  return (dados as List).map((item) => SimuladoResumo.fromApi(item)).toList();
}

Future<SimuladoDetalheDTO> criarSimulado({
  required String titulo,
  String? descricao,
  double? tempo,
}) async {
  final dados = await apiPost('/simulados', {
    'titulo': titulo,
    if (descricao != null) 'descricao': descricao,
    if (tempo != null) 'tempo': tempo,
  });
  return SimuladoDetalheDTO.fromApi(dados);
}

Future<SimuladoDetalheDTO> detalharSimulado(int id) async {
  final dados = await apiGet('/simulados/$id');
  return SimuladoDetalheDTO.fromApi(dados);
}

Future<List<Questao>> listarQuestoesDoSimulado(int id) async {
  final dados = await apiGet('/simulados/$id/questoes');
  return (dados as List).map((item) => Questao.fromApi(item)).toList();
}

Future<void> adicionarQuestoesAoSimulado(int id, List<int> questoesIds) async {
  await apiPost('/simulados/$id/questoes', {'questoesIds': questoesIds});
}

Future<void> removerQuestaoDoSimulado(int id, int questaoId) async {
  await apiDelete('/simulados/$id/questoes/$questaoId');
}

Future<void> excluirSimulado(int id) async {
  await apiDelete('/simulados/$id');
}

Future<bool> corrigirQuestaoDoSimulado({
  required int simuladoId,
  required int questaoId,
  required String alternativaSelecionadaId,
}) async {
  return corrigirQuestaoAvulsa(questaoId, alternativaSelecionadaId);
}