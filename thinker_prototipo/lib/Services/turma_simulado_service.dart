import 'package:tinker/Services/api_client.dart';
import 'package:tinker/Models/publicacao_simulado_model.dart';
import 'package:tinker/Models/questao_model.dart';
import 'package:tinker/Models/resultado_simulado_model.dart';

Future<List<PublicacaoSimulado>> listarSimuladosDaTurma(String codTurma) async {
  final dados = await apiGet('/turmas/$codTurma/simulados') as List;
  return dados.map((item) => PublicacaoSimulado.fromApi(item)).toList();
}

Future<void> publicarSimulado(String codTurma, int simuladoId) async {
  await apiPost('/turmas/$codTurma/simulados', {'simuladoId': simuladoId});
}

Future<void> despublicarSimulado(String codTurma, String idPublicacao) async {
  await apiDelete('/turmas/$codTurma/simulados/$idPublicacao');
}

Future<List<Questao>> listarQuestoesDaPublicacao(String codTurma, String idPublicacao) async {
  final dados = await apiGet('/turmas/$codTurma/simulados/$idPublicacao/questoes') as List;
  return dados.map((item) => Questao.fromApi(item)).toList();
}

Future<bool> corrigirQuestaoPublicada({
  required String codTurma,
  required String idPublicacao,
  required int questaoId,
  required String alternativa,
}) async {
  final dados = await apiPost(
    '/turmas/$codTurma/simulados/$idPublicacao/questoes/$questaoId/correcoes',
    {'alternativa': alternativa},
  );
  return dados['acertou'] as bool;
}

Future<ConclusaoSimulado> concluirSimuladoPublicado({
  required String codTurma,
  required String idPublicacao,
  required List<Map<String, dynamic>> respostas,
}) async {
  final dados = await apiPost(
    '/turmas/$codTurma/simulados/$idPublicacao/conclusoes',
    {'respostas': respostas},
  );
  return ConclusaoSimulado.fromApi(dados);
}

Future<ResultadoIndividualSimulado> consultarResultadoPublicacao(
    String codTurma, String idPublicacao) async {
  final dados = await apiGet('/turmas/$codTurma/simulados/$idPublicacao/resultado');
  return ResultadoIndividualSimulado.fromApi(dados);
}
