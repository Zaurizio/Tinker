import 'package:tinker/Models/questao_model.dart';



List<Questao> buscarQuestoesMock() {
  return [
    Questao(
      id: '1',
      materia: 'Matemática',
      assunto: 'Funções',
      instituicao: 'FUVEST',
      ano: '2025',
      enunciado: 'Considere a função f(x) = 2x + 3. Qual o valor de f(5)?',
      alternativas: [
        Alternativa(id: 'a', texto: 'Alternativa A'),
        Alternativa(id: 'b', texto: 'Alternativa B', correta: true),
        Alternativa(id: 'c', texto: 'Alternativa C'),
        Alternativa(id: 'd', texto: 'Alternativa D'),
      ],
    ),
    Questao(
      id: '2',
      materia: 'Português',
      assunto: 'Interpretação de texto',
      instituicao: 'UNICAMP',
      ano: '2025',
      enunciado: 'Considere o seguinte período retirado do texto acima.',
      alternativas: [
        Alternativa(id: 'a', texto: 'Alternativa A'),
        Alternativa(id: 'b', texto: 'Alternativa B', correta: true),
        Alternativa(id: 'c', texto: 'Alternativa C'),
        Alternativa(id: 'd', texto: 'Alternativa D'),
      ],
    ),
    Questao(
      id: '3',
      materia: 'História',
      assunto: 'Segunda Guerra Mundial',
      instituicao: 'ENEM',
      ano: '2024',
      enunciado:
          'Sobre os eventos que levaram ao início da Segunda Guerra Mundial, assinale a alternativa correta.',
      alternativas: [
        Alternativa(id: 'a', texto: 'Alternativa A', correta: true),
        Alternativa(id: 'b', texto: 'Alternativa B'),
        Alternativa(id: 'c', texto: 'Alternativa C'),
        Alternativa(id: 'd', texto: 'Alternativa D'),
      ],
    ),
    Questao(
      id: '4',
      materia: 'Química',
      assunto: 'Tabela Periódica',
      instituicao: 'UNESP',
      ano: '2024',
      enunciado:
          'Qual das alternativas apresenta corretamente um elemento da família dos gases nobres?',
      alternativas: [
        Alternativa(id: 'a', texto: 'Alternativa A'),
        Alternativa(id: 'b', texto: 'Alternativa B'),
        Alternativa(id: 'c', texto: 'Alternativa C', correta: true),
        Alternativa(id: 'd', texto: 'Alternativa D'),
      ],
    ),
  ];
}