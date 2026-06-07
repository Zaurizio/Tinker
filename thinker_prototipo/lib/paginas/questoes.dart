import 'package:flutter/material.dart';
import 'package:thinker_prototipo/_comum/colors.dart';

class Questoes extends StatefulWidget {
  const Questoes({super.key});

  @override
  State<Questoes> createState() => _QuestoesState();
}

class _QuestoesState extends State<Questoes> {
  bool _filtroAberto = false;
   final List<Map<String, String>> _questoes = [];

  dynamic adicionarQuestao() {
    final nomeCtrl = TextEditingController();
    final materiaCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: minhasCores.pretoC,
        title: Text("Adicionar Questão", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(color: Colors.white),
              controller: nomeCtrl,
              decoration: InputDecoration(
                labelText: "assunto",
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            TextField(
              style: TextStyle(color: Colors.white),
              controller: materiaCtrl,
              decoration: InputDecoration(
                labelText: "Matéria",
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancelar", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () {
              if (nomeCtrl.text.isEmpty) return;
              setState(
                () => _questoes.add({
                  "questao": nomeCtrl.text,
                  "materia": materiaCtrl.text,
                }),
              );
              Navigator.pop(ctx);
            },

            child: Text("Criar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  final text = TextStyle(color: Colors.white);
  final tituloContornado = Stack(
    alignment: Alignment.center,
    children: [
      Text(
        'Tinker',
        style: TextStyle(
          fontFamily: 'Stardom',
          fontSize: 45,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..color = Colors.black,
        ),
      ),

      Text(
        'Tinker',
        style: TextStyle(
          fontFamily: 'Stardom',
          fontSize: 45,
          color: Colors.white,
        ),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/constelacao.png', fit: BoxFit.cover),
          Stack(
            children: [
              Positioned(
                top: 50,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: minhasCores.azulC,
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                top: -50,
                left: 60,
                child: IgnorePointer(
                  child: Image.asset('assets/images/logo.png', width: 300),
                ),
              ),
            ],
          ),

          SafeArea(
            child: Padding(
              padding:  EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  Center(child: tituloContornado),
                  SizedBox(height: 60),
                  Column(
                    children: [
                      Center(
                        child: Stack(
                        
                          
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                            width: 200,
                              
                              decoration: BoxDecoration(
                                color: minhasCores.azulC,
                                borderRadius: BorderRadius.circular(16),
                              ),

                              child: Center(
                                
                                child:Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                 Text(
                                  "Questões",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 35,
                                    fontWeight: FontWeight(30),
                                    
                                  ), 
                                ),
                                
                                 Container(
                                
                                    decoration: BoxDecoration(
                                 color: minhasCores.azulE,
                               
                                borderRadius: BorderRadius.circular(8),
                                    ),
                                 child: 
                               IconButton(onPressed:(){
                                  _filtroAberto =!_filtroAberto;
                                  setState(() {
                                    
                                  });


                                }, icon: Icon(Icons.filter_alt,color: Colors.white,size: 25,))
                                 )
                                ],
                                
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: minhasCores.pretoC,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: minhasCores.azul2C,
                                  width: 1,
                                ),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  adicionarQuestao();
                                },
                                icon: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                            ..._questoes.map(
                              
                              (s) => Container(
                                
                                width: double.infinity,
                               
                                margin: EdgeInsets.only(top: 12),
                               
                                decoration: BoxDecoration(
                                  color:Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                 
                                ),
                                 clipBehavior: Clip.antiAlias,
                                 
                               
                                  child: 
                                   Stack(
                                  
                                  children: [
                                     Column(
                                        
                                            crossAxisAlignment:CrossAxisAlignment.start ,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            width: double.infinity,
                                            color: minhasCores.pretoC,
                                            child: 
                                          Text(
                                            s["questao"]!,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          ),
                                          Padding(
                                            padding:EdgeInsets.all(20),
                                       child:  Text(
                                            s["materia"]!,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                          )
                                        ],
                                      ),
                                    

                                    Positioned(
                                      top: -4,
                                      right: -6,

                                      child: IconButton(
                                        onPressed: () => setState(
                                          () => _questoes.removeAt(
                                            _questoes.indexOf(s),
                                          ),
                                        ),
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.white54,
                                        )
                                        ),
                                      ),
                                  ]
                                    ),
                              
                            )
                            )
                                  ],
                                ),
                              ),
                                            

                          ]              
                            ),
                ]
                      )
            )
          ),
           if(_filtroAberto)
              GestureDetector(
                onTap: () => setState(()  => _filtroAberto = false),
                  child: Container(color: Colors.black.withOpacity(0.4)),
                ),

                AnimatedPositioned(
                  duration:Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  top: 160,
                  right: _filtroAberto ? 16 : -220, 
                  child: Container(

                    width: 190,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(color: minhasCores.pretoC,
                    borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Filtros",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                          GestureDetector(
                            onTap:() => setState(() => _filtroAberto = false),
                            child: Icon(Icons.close, color: Colors.red, size: 20),
                          ),
                        ],
                      ),
                      Divider(color: Colors.white,),
                      for (var label in ["Disciplina","Ano","Conteúdo","Instituição","Dificuldade"])
                      Padding(padding: EdgeInsetsGeometry.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(label,style: TextStyle(color: Colors.white)),
                          Icon(Icons.keyboard_arrow_down,color: Colors.white70,size: 20,),
                        ],
                      ),)
                    ],),
                  ))
            ],),
            );

                          
  }
}