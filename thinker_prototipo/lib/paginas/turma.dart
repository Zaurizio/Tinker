import 'package:flutter/material.dart';
import 'package:thinker_prototipo/_comum/colors.dart';

class Turma extends StatefulWidget {
  const Turma({super.key});

  @override
  State<Turma> createState() => _TurmaState();
}

class _TurmaState extends State<Turma> {
  final List<Map<String, String>> _turmas = [];

  dynamic adicionarTurma() {
    final nomeCtrl = TextEditingController();
    final materiaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: minhasCores.pretoC,
        title: Text("Nova Turma", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(color: Colors.white),
              controller: nomeCtrl,
              decoration: InputDecoration(
                labelText: "Turma",
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
                () => _turmas.add({
                  "turma": nomeCtrl.text,
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
              padding: const EdgeInsets.all(16),
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
                              width: 150,
                              height: 50,
                              decoration: BoxDecoration(
                                color: minhasCores.azulC,
                                borderRadius: BorderRadius.circular(16),
                              ),

                              child: Center(
                                child: Text(
                                  "Turmas",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 35,
                                    fontWeight: FontWeight(30),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 360,
                          height: 600,
                          decoration: BoxDecoration(
                            color: minhasCores.azulC,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SingleChildScrollView(
                            child: Center(
                              child: Column(
                                children: [
                                  ..._turmas.map(
                                    (s) => Container(
                                     width: double.infinity,
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6,),
                                     
                                      
                                    
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                 
                                      child: Stack(
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
                                            s["turma"]!,
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
                                          () => _turmas.removeAt(
                                            _turmas.indexOf(s),
                                          ),
                                        ),
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.white54,
                                              ),
                                            ),
                                          ),
                                        ]
                                      )
                                    )
                                  )
                                        ],
                                      ),
                                    ),
                                  ),
                        ),
                        SizedBox(height: 20,),
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
                                    adicionarTurma();
                                  },
                                  icon: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                                ],
                              ),
                            ),
                ]
                
                          ),
                          
                        ),
                    
                        
                       ) 
                                   
                      ],
                      
                    ),
                    
                  );
                
              
  }
}
