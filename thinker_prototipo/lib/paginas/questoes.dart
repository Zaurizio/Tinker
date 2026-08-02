import 'package:flutter/material.dart';


class Questoes extends StatefulWidget {
  const Questoes({super.key});

  @override
  State<Questoes> createState() => _QuestoesState();
}

class _QuestoesState extends State<Questoes> {
  bool filtroAberto = false;
  final buscaCtrl = TextEditingController();

  final List<Map<String, String>> questoes = [
    {"assunto": "Derivadas", "materia": "Matemática", "dificuldade": "Médio"},
    {"assunto": "Segunda Guerra Mundial", "materia": "História", "dificuldade": "Fácil"},
    {"assunto": "Tabela Periódica", "materia": "Química", "dificuldade": "Difícil"},
  ];

  List<Map<String, String>> filtradas = [];

  @override
  void initState() {
    super.initState();
    filtradas = List.from(questoes);
  }

  void filtrar(String texto) {
    setState(() {
      if (texto.isEmpty) {
        filtradas = List.from(questoes);
      } else {
        filtradas = questoes
            .where((q) =>
                q["assunto"]!.toLowerCase().contains(texto.toLowerCase()) ||
                q["materia"]!.toLowerCase().contains(texto.toLowerCase()))
            .toList();
      }
    });
  }

  void remover(Map<String, String> questao) {
    setState(() {
      questoes.remove(questao);
      filtrar(buscaCtrl.text);
    });
  }

  void CriarQ() {
    final assuntoCtrl = TextEditingController();
    final materiaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:  Color(0xFF0F2744),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title:  Text('Nova questão',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assunto', style: TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
             SizedBox(height: 6),
            CampoDeQuestao(assuntoCtrl, 'Ex: Derivadas'),
            SizedBox(height: 14),
             Text('Matéria', style: TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
             SizedBox(height: 6),
            CampoDeQuestao(materiaCtrl, 'Ex: Matemática'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:  Text('Cancelar', style: TextStyle(color: Color(0xFF8AABCC))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:  Color(0xFF1A4A8A),
              foregroundColor:  Color(0xFF4A9EFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () {
              if (assuntoCtrl.text.trim().isEmpty) return;
              setState(() {
                questoes.insert(0, {
                  "assunto": assuntoCtrl.text.trim(),
                  "materia": materiaCtrl.text.trim().isEmpty
                      ? "Sem matéria"
                      : materiaCtrl.text.trim(),
                  "dificuldade": "Médio",
                });
                filtrar(buscaCtrl.text);
              });
              Navigator.pop(ctx);
            },
            child: Text('Criar'),
          ),
        ],
      ),
    );
  }

  Widget CampoDeQuestao(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style:  TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:  TextStyle(color: Color(0xFF4A6A8A), fontSize: 14),
        filled: true,
        fillColor:  Color(0xFF0D1B2A),
        contentPadding:  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:  BorderSide(color: Color(0xFF1E3D5C), width: 0.5),
        ),



        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:  BorderSide(color: Color(0xFF1E3D5C), width: 0.5),
        ),


        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:  BorderSide(color: Color(0xFF4A9EFF), width: 1),
        ),
      ),
    );
  }

  Color sombraCor(String dificuldade) {
    switch (dificuldade) {
      case 'Fácil': return  Color(0xFF0F3A2A);
      case 'Difícil': return  Color(0xFF3A1520);
      default: return  Color(0xFF1E4A8A);
    }
  }

  Color cor(String dificuldade) {
    switch (dificuldade) {
      case 'Fácil': return  Color(0xFF4ABA8A);
      case 'Difícil': return  Color(0xFFE05C6A);
      default: return  Color(0xFF4A9EFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFF0D1B2A),
      body: Stack(
        children: [
      SafeArea(
        child: Column(children: [
       
        SingleChildScrollView(
          padding:  EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
               SizedBox(height: 16),
             
                   
               Row(
                children: [
                   GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF0F2744),
                        border: Border.all(color: Color(0xFF1E3D5C), width: 1),
                      ),
                      child: Icon(Icons.arrow_back, color: Colors.white, size: 18),
                    ),
                  ),
                  SizedBox(width: 20,),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:  Color(0xFF1A4A7A),
                    child: Image.asset('assets/images/tinker_images/logo2.png'),
                  ),
                   SizedBox(width: 10),
                   Text('TINKER',
                      style: TextStyle(
                          fontFamily: 'Stardom',
                          color: Colors.white,
                          fontSize: 25,
                          letterSpacing: 3
                      ),
                          ),       
                ],
              ),
              
               SizedBox(height: 20),

               Text('Questões',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
               SizedBox(height: 4),
               Text('Gerencie e estude suas questões',
                  style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),

               SizedBox(height: 20),

              
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: buscaCtrl,
                      onChanged: filtrar,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Buscar por assunto ou matéria...',
                        hintStyle:  TextStyle(color: Color(0xFF4A6A8A), fontSize: 13),
                        prefixIcon:  Icon(Icons.search, color: Color(0xFF4A6A8A), size: 20),
                        filled: true,
                        fillColor:  Color(0xFF0F2744),
                        contentPadding:  EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:  BorderSide(color: Color(0xFF1E3D5C), width: 0.5),
                        ),



                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:  BorderSide(color: Color(0xFF1E3D5C), width: 0.5),
                        ),



                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:  BorderSide(color: Color(0xFF4A9EFF), width: 1),
                        ),
                      ),
                    ),
                  ),
                   SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => setState(() => filtroAberto = !filtroAberto),
                    child: Container(
                      padding:  EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color:  Color(0xFF0F2744),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: filtroAberto
                              ?  Color(0xFF4A9EFF)
                              :  Color(0xFF1E3D5C),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.tune_rounded,
                              color: filtroAberto
                                  ?  Color(0xFF4A9EFF)
                                  : Color(0xFF8AABCC),
                              size: 18),
                           SizedBox(width: 6),
                          Text('Filtros',
                              style: TextStyle(
                                  color: filtroAberto
                                      ?  Color(0xFF4A9EFF)
                                      : Color(0xFF8AABCC),
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              
              AnimatedSize(
                duration:  Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: filtroAberto
                    ? Container(
                        margin:  EdgeInsets.only(top: 10),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:  Color(0xFF0F2744),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color:  Color(0xFF1E3D5C), width: 0.5),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                 Text('Filtrar por',
                                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                                GestureDetector(
                                  onTap: () => setState(() => filtroAberto = false),
                                  child:  Icon(Icons.close, color: Color(0xFFE05C6A), size: 18),
                                ),
                              ],
                            ),
                             Divider(color: Color(0xFF1E3D5C), height: 16),
                            for (final label in ['Disciplina', 'Ano', 'Conteúdo', 'Instituição', 'Dificuldade'])
                              Padding(
                                padding:  EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(label, style:  TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),
                                     Icon(Icons.keyboard_arrow_down, color: Color(0xFF4A6A8A), size: 18),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      )
                    :  SizedBox.shrink(),
              ),

               SizedBox(height: 20),

              
               Text('SUAS QUESTÕES',
                  style: TextStyle(color: Color(0xFF8AABCC), fontSize: 11, letterSpacing: 1.2)),

               SizedBox(height: 10),

              
              GestureDetector(
                onTap: CriarQ,
                child: Container(
                  width: double.infinity,
                  padding:  EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color:  Color(0xFF0F2744),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color:  Color(0xFF1E3D5C),
                        width: 0.5,
                        style: BorderStyle.solid),
                  ),
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Color(0xFF4A9EFF), size: 18),
                      SizedBox(width: 8),
                      Text('Adicionar questão',
                          style: TextStyle(color: Color(0xFF4A9EFF), fontSize: 14)),
                    ],
                  ),
                ),
              ),

               SizedBox(height: 12),

             
              if (filtradas.isEmpty)
                Center(
                  child: Padding(
                    padding:  EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.notes_rounded, color:  Color(0xFF4A6A8A), size: 40),
                         SizedBox(height: 12),
                         Text('Nenhuma questão encontrada.',
                            style: TextStyle(color: Color(0xFF4A6A8A), fontSize: 14)),
                         SizedBox(height: 4),
                         Text('Adicione sua primeira questão acima.',
                            style: TextStyle(color: Color(0xFF4A6A8A), fontSize: 13)),
                      ],
                    ),
                  ),
                )
              else
                ...filtradas.map(
                  (q) => Container(
                    margin:  EdgeInsets.only(bottom: 10),
                    padding:  EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color:  Color(0xFF0F2744),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color:  Color(0xFF1E3D5C), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color:  Color(0xFF1A3A6A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:  Icon(Icons.description_outlined,
                              color: Color(0xFF4A9EFF), size: 18),
                        ),
                         SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(q["assunto"]!,
                                  style:  TextStyle(
                                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                               SizedBox(height: 3),
                              Text(q["materia"]!,
                                  style: TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
                               SizedBox(height: 6),
                              Container(
                                padding:  EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                                decoration: BoxDecoration(
                                  color: sombraCor(q["dificuldade"]!),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text (q["dificuldade"]!,
                                    style: TextStyle(
                                        color: cor(q["dificuldade"]!), fontSize: 11)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => remover(q),
                          icon:  Icon(Icons.close, color: Color(0xFF4A6A8A), size: 18),
                          padding: EdgeInsets.zero,
                          constraints:  BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),

               SizedBox(height: 24),
            ],
          ),
        ),
        ],
        )
      ),
    ])
  );
  }
}