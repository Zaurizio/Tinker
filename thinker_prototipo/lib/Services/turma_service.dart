import 'package:tinker/Services/api_client.dart';
import 'package:tinker/Models/turma_model.dart';
import 'package:tinker/Models/membro_turma_model.dart';

Future<List<TurmaModel>> buscarTurmas() async {
  final dados = await apiGet('/turmas');
  return (dados as List).map((item) => TurmaModel.fromApi(item)).toList();
}

Future<TurmaModel> criarTurma(String nome) async {
  final dados = await apiPost('/turmas', {'nome': nome});
  return TurmaModel.fromApi(dados);
}

Future<TurmaModel> entrarNaTurma(String codigo) async {
  final dados = await apiPost('/turmas/entradas', {'codigo': codigo});
  return TurmaModel.fromApi(dados);
}

Future<TurmaModel> buscarTurma(String codigo) async {
  final dados = await apiGet('/turmas/$codigo');
  return TurmaModel.fromApi(dados);
}

Future<List<MembroTurmaModel>> buscarMembros(String codigo) async {
  final dados = await apiGet('/turmas/$codigo/membros');
  return (dados as List).map((item) => MembroTurmaModel.fromApi(item)).toList();
}

Future<void> sairDaTurma(String codigo) async {
  await apiDelete('/turmas/$codigo/membros/me');
}

Future<void> removerMembro(String codigo, String emailAluno) async {
  await apiDelete('/turmas/$codigo/membros/$emailAluno');
}

Future<void> desativarTurma(String codigo) async {
  await apiDelete('/turmas/$codigo');
}
