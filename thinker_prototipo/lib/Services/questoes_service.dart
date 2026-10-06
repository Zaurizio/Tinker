import 'package:tinker/Services/api_client.dart';
import 'package:tinker/Models/questao_model.dart';

class PaginaQuestoes {
  final List<Questao> itens;
  final bool temMais;
  final int total;
  final int pagina;
  final int tamanho;

  PaginaQuestoes({
    required this.itens,
    required this.temMais,
    required this.total,
    required this.pagina,
    required this.tamanho,
  });
}

Future<PaginaQuestoes> buscarQuestoesPaginado({
  String? disciplina,
  String? conteudo,
  String? vestibular,
  int? ano,
  String? trecho,
  int pagina = 0,
  int tamanho = 10,
}) async {
  final partes = <String>['pagina=$pagina', 'tamanho=$tamanho'];

  if (disciplina != null && disciplina.trim().isNotEmpty) {
    partes.add('disciplinas=${Uri.encodeQueryComponent(disciplina.trim())}');
  }
  if (conteudo != null && conteudo.trim().isNotEmpty) {
    partes.add('conteudos=${Uri.encodeQueryComponent(conteudo.trim())}');
  }
  if (vestibular != null && vestibular.trim().isNotEmpty) {
    partes.add('vestibulares=${Uri.encodeQueryComponent(vestibular.trim())}');
  }
  if (ano != null) {
    partes.add('anos=$ano');
  }
  if (trecho != null && trecho.trim().isNotEmpty) {
    partes.add('trecho=${Uri.encodeQueryComponent(trecho.trim())}');
  }

  final dados = await apiGet('/questoes?${partes.join('&')}');

  return PaginaQuestoes(
    itens: (dados['itens'] as List).map((i) => Questao.fromApi(i)).toList(),
    temMais: dados['temMais'] as bool,
    total: dados['total'] as int,
    pagina: dados['pagina'] as int,
    tamanho: dados['tamanho'] as int,
  );
}

Future<Questao> buscarQuestaoPorId(int id) async {
  final dados = await apiGet('/questoes/$id');
  return Questao.fromApi(dados);
}

Future<bool> corrigirQuestaoAvulsa(int questaoId, String alternativaSelecionadaId) async {
  final dados = await apiPost('/questoes/$questaoId/correcoes', {
    'alternativaSelecionadaId': alternativaSelecionadaId,
  });
  return dados['acertou'] as bool;
}
