import 'package:tinker/Services/questoes_service.dart';

class Question {
  final int id;
  final String text;
  final List<String> options;
  final List<String> optionIds;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.optionIds,
  });
}

List<Question> _pool = [];
int _proximaPagina = 0;
bool _acabouAsPaginas = false;

Future<Question?> fetchRandomQuestion() async {
  if (_pool.isEmpty) {
    try {
      final pagina = await buscarQuestoesPaginado(
        pagina: _acabouAsPaginas ? 0 : _proximaPagina,
        tamanho: 30,
      );

      _pool = pagina.itens
          .where((q) => q.alternativas.length >= 2)
          .map((q) => Question(
                id: q.id,
                text: q.enunciado,
                options: q.alternativas.map((a) => a.texto).toList(),
                optionIds: q.alternativas.map((a) => a.id).toList(),
              ))
          .toList();

      if (pagina.temMais) {
        _proximaPagina++;
        _acabouAsPaginas = false;
      } else {
        _proximaPagina = 0;
        _acabouAsPaginas = true;
      }
    } catch (e) {
      return null;
    }
  }

  if (_pool.isEmpty) return null;

  _pool.shuffle();
  return _pool.removeLast();
}
