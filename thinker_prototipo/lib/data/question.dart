import 'dart:math';

class Question {
  final String text;
  final List<String> options; 
  final int correctIndex; 

  const Question({
    required this.text,
    required this.options,
    required this.correctIndex,
  }) : assert(options.length == 5, 'Precisa ter exatamente 5 alternativas');
}

final List<Question> questionBank = [
  Question(
    text: 'Em uma estação de tratamento de água, uma das etapas consiste na adição de determinadas substâncias químicas' 
    'que promovem a aglomeração de pequenas partículas de sujeira em flocos maiores.'
    'Esses flocos tornam-se mais pesados e se depositam no fundo dos tanques,'
    'facilitando sua remoção antes das etapas finais de filtração e desinfecção.\n',

    options: ['Eliminar todos os microrganismos presentes na água.', 
    'Aumentar a concentração de sais minerais.',
     'Facilitar a remoção de partículas em suspensão.',
     'Tornar a água mais ácida.',
    'Evaporar parte da água tratada.'],
    correctIndex: 2,
  ),
  Question(
    text: 'Em uma reserva ambiental, pesquisadores monitoraram durante vários anos duas populações de aves que se alimentavam da mesma espécie de sementes.'
     'Após uma longa estiagem, observou-se que as sementes maiores passaram a ser muito mais abundantes do que as menores.'
      'Nos anos seguintes, verificou-se que a população de aves com bicos maiores aumentou,'
       'enquanto a de aves com bicos menores diminuiu significativamente.\n'

            
            'Com base na teoria da evolução, a melhor explicação para esse fenômeno é:\n',

    options: ['As aves desenvolveram bicos maiores porque precisavam quebrar sementes maiores.', 
    'A seca provocou mutações que aumentaram o tamanho dos bicos',
     'A seleção natural favoreceu indivíduos que já possuíam bicos maiores.', 
     'Todas as aves modificaram o tamanho do bico durante a vida.', 
     'O ambiente alterou diretamente o DNA de todos os indivíduos da população.'],
    correctIndex: 2,
  ),
  Question(
    text: 'Um ciclista desloca-se por uma estrada retilínea mantendo velocidade constante de 8 m/s.'
    'Ao perceber um animal atravessando a pista, ele aciona imediatamente os freios,' 
    'passando a sofrer uma desaceleração constante de 2 m/s² até parar completamente.\n'

    'Desprezando a resistência do ar e considerando que a pista é horizontal,'
    'a distância percorrida pelo ciclista desde o instante em que começou a frear até parar é:,\n',
    options: ['8 m', '12 m', '16 m', '20 m', '24 m'],
    correctIndex: 2,
  ),
  Question(
    text: 'Uma empresa de energia elétrica realizou uma campanha para incentivar seus clientes a reduzir o consumo mensal de eletricidade.' 
    'Antes da campanha, uma residência consumia, em média, 480 kWh por mês.'
    ' Após a adoção de medidas como substituição de lâmpadas,'
      'redução do tempo de banho e uso mais consciente de aparelhos elétricos, o consumo caiu 15%.\n'

'Sabendo que a tarifa de energia é de R\$ 0,80 por kWh,'
 'qual foi a economia aproximada na conta de energia dessa residência em um mês?\n',

    options: ['R\$ 48,00', 'R\$ 57,60', 'R\$ 60,00', 'R\$ 72,00', 'R\$ 81,60'],
    correctIndex: 1,
  ),
  Question(
    text: 'Durante um teste de segurança em uma rodovia, um automóvel percorreu um trecho retilíneo mantendo velocidade constante de 72 km/h.'
     'Em determinado instante, o motorista percebeu um obstáculo na pista e levou exatamente 1 segundo para reagir e começar a frear.' 
     'Após esse intervalo, o carro sofreu desaceleração constante de 5 m/s² até parar completamente.\n'

  'Desprezando a resistência do ar e considerando que a pista era horizontal,'
  'qual foi a distância total percorrida pelo veículo'
  'desde o momento em que o motorista viu o obstáculo até sua parada completa?\n',
    options: ['40 m', '50 m', '60 m', '70 m', '80 m'],
    correctIndex: 2,
  ),
  Question(
    text: 'Leia o trecho.\n'

  'Em uma sociedade marcada pelo excesso de informações, distinguir fatos de opiniões tornou-se uma habilidade indispensável.' 
  'Redes sociais permitem que qualquer pessoa publique conteúdos instantaneamente, o que amplia o acesso à informação,'
  'mas também facilita a circulação de notícias falsas. '
  'Nesse contexto, cabe ao cidadão desenvolver senso crítico para avaliar fontes,'
  'verificar evidências e evitar o compartilhamento precipitado de informações.\n'

    'A principal ideia defendida pelo texto é:\n',

    options: ['As redes sociais devem ser proibidas.', 
    'O excesso de informação elimina a necessidade de senso crítico.',
     'O acesso à informação exige capacidade de análise e verificação.', 
     'Notícias falsas surgem apenas em jornais.', 
     'A internet tornou impossível distinguir fatos de opiniões.'],
    correctIndex: 2,
  ),
  Question(
    text: 'Ao longo do século XVIII, diversos pensadores europeus defenderam ideias como liberdade de expressão, limitação do poder dos reis,'
    ' igualdade perante as leis e valorização da razão como instrumento para compreender o mundo. '
    ' Essas ideias influenciaram movimentos políticos importantes, '
    ' como a Independência dos Estados Unidos e a Revolução Francesa,'
      'além de inspirarem constituições e declarações de direitos em diferentes países.\n'
      'O conjunto dessas ideias ficou conhecido como:',

    options: ['Mercantilismo', 
    'Absolutismo.',
     'Renascimento.', 
     'Iluminismo.',
      'Feudalismo.'],

    correctIndex: 3,
  ),
  Question(
    text: 'Química (Enem)\nUma indústria alimentícia pretende substituir embalagens metálicas por embalagens biodegradáveis para reduzir o impacto ambiental causado pelo descarte de resíduos sólidos. '
    ' Entretanto, alguns pesquisadores alertam que a simples substituição do material não garante redução dos impactos ambientais,'
     'pois fatores como consumo de energia, transporte, reciclagem e tempo de decomposição '
     'também devem ser considerados na avaliação do ciclo de vida do produto.'
     'Com base nessas informações, a melhor conclusão é que:',

    options: ['Todo material biodegradável é ambientalmente superior.',
     'Apenas o tempo de decomposição deve ser analisado.',
      'A avaliação ambiental depende de vários fatores ao longo do ciclo de vida do produto.', 
      'Embalagens metálicas nunca podem ser recicladas.', 
      'O consumo de energia não interfere na sustentabilidade.'],
    correctIndex: 2,
  ),
  Question(
    text: 'Biologia (UNICAMP)\nEm uma região agrícola, pesquisadores observaram que o uso indiscriminado de inseticidas reduziu drasticamente a população de diversas espécies de insetos.'
    'Alguns anos depois, verificou-se que uma determinada espécie de praga voltou a apresentar crescimento populacional, mesmo com a aplicação contínua'
    ' do mesmo produto químico.\nOs pesquisadores concluíram que esse fenômeno está relacionado à seleção natural.'
    'Com base na teoria evolutiva, a explicação mais adequada é:',
    options: ['Os inseticidas fizeram surgir mutações que produziram indivíduos resistentes.',
     'Todos os indivíduos adquiriram resistência durante a vida.',
      'Indivíduos naturalmente resistentes sobreviveram e deixaram mais descendentes.', 
      'Os insetos aprenderam a evitar o inseticida.',
      'O inseticida perdeu completamente sua composição química.'],
    correctIndex: 2,
  ),
];

final Random _rng = Random();
Question? _lastQuestion;

Question pickRandomQuestion() {
  if (questionBank.length == 1) return questionBank.first;
  Question q;
  do {
    q = questionBank[_rng.nextInt(questionBank.length)];
  } while (q == _lastQuestion);
  _lastQuestion = q;
  return q;
}