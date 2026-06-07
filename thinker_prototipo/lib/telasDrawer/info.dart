import 'package:flutter/material.dart';
import 'package:thinker_prototipo/_comum/colors.dart';
import 'package:thinker_prototipo/drawer.dart';
class Info extends StatefulWidget {
  const Info({super.key});

  @override
  State<Info> createState() => _InfoState();
}
Widget _bullet(String texto) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• ", style: TextStyle(fontSize: 14)),
        Expanded(
          child: Text(texto, style: TextStyle(fontSize: 14, height: 1.6)),
        ),
      ],
    ),
  );
}
final text = TextStyle(color: Colors.white,);
final tituloContornado = Stack(
  alignment: Alignment.center,
  children: [
  
    Text(
      'Tinker',
      style: TextStyle(
        fontFamily: 'Stardom',
        fontSize: 90,
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
        fontSize: 90,
        color: Colors.white,
      ),
    ),
  ],
);
class _InfoState extends State<Info> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
backgroundColor: minhasCores.pretoC,
       iconTheme: IconThemeData(color: Colors.white70,size: 30),
),
drawer: MeuDrawer(),
backgroundColor: minhasCores.pretoC,
                body:
                 
                  Stack 
      (
       fit: StackFit.expand,
children:[
     
         
    
Stack(children: [

    Positioned(
 top: 50,
 left: 16,
  child:Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color:minhasCores.azul2C,
    ),

  ),
),
SafeArea(child: Padding(padding: EdgeInsets.all(16),
child:
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    SizedBox(height: 30,),
    Center(
      child: Container(
        width: 400,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
child: Stack(
  clipBehavior: Clip.none,
  alignment: Alignment.center,
  children: [
    Positioned(
      top: -90,
      left: 1,
      child:IgnorePointer(
        child: Image.asset("assets/images/logo.png",
        width: 400,
       
        ),
      ), 
    ),

    Center(
      child:tituloContornado ,
      
      
      
                          ),
                         


                          
                        ]
                      )
                    )
                    
                  ),
                  SizedBox(height: 30,),
                   Center(child:
                   Column(
                      
                      children: [

                                Icon(Icons.info_outline_rounded,color:Colors.white,size: 70,),
                  SizedBox(height: 15,),
                  Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          
  
  
            CircleAvatar(
             backgroundImage: AssetImage('assets/images/heitor.jpeg'),
             radius: 40,backgroundColor: minhasCores.azulE,), 
              
              SizedBox(width: 20,),

            CircleAvatar(
             backgroundImage: AssetImage('assets/images/rafael.jpeg'),
             radius: 40,backgroundColor: minhasCores.azulE,), 

              SizedBox(width: 20,),

            CircleAvatar(
             backgroundImage: AssetImage('assets/images/zaurizio.jpeg'),
             radius: 40,backgroundColor: minhasCores.azulE,), 

              SizedBox(width: 20,),

            CircleAvatar(
             backgroundImage: AssetImage('assets/images/lucas.jpeg'),
             radius: 40,backgroundColor: minhasCores.azulE,), 
                            ]
                  ),
                  SizedBox(height: 15,),
                  Container(
                    width: 370,
                    height: 450,
                    decoration: BoxDecoration(
                      color: Colors.white,
                       borderRadius: BorderRadius.circular(16),
                       border: Border.all(color: Colors.white,width:1.5),
                    ),
                    child:Padding(
    padding: EdgeInsets.all(16),
    child:
    SingleChildScrollView(child:  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "O Thinker é uma plataforma moderna de estudos voltada para quem se prepara para o vestibular.\nNosso objetivo é transformar o aprendizado em uma experiência dinâmica, inteligente e envolvente — unindo tecnologia, gamificação e desempenho real.\nNo Thinker, o estudante pode organizar seu calendário de estudos, praticar com questões, participar de simulados gamificados e acompanhar sua evolução com métricas claras e motivadoras. Tudo foi pensado para ajudar o aluno a estudar com estratégia e constância.\nO projeto é desenvolvido por uma equipe dedicada de jovens programadores:",
          style: TextStyle(fontSize: 14, height: 1.6),
        ),

        SizedBox(height: 8),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bullet("Lucas Gabriel — Desenvolvedor Web Front-End"),
            _bullet("Gustavo Zaurizio — Desenvolvedor Web Front-End"),
            _bullet("Rafael Abrahão — Desenvolvedor Desktop, Modelador do Banco de Dados e Back-End"),
            _bullet("Heitor Prieto — Desenvolvedor Mobile e Back-End"),
          ],
        ),

        SizedBox(height: 8),

        Text(
          "Unindo criatividade, tecnologia e paixão por educação, o Thinker nasceu para ser mais do que uma plataforma de estudos — é um novo jeito de aprender.",
          style: TextStyle(fontSize: 14, height: 1.6),
        ),
      ],
                                      ),
                                    )
                                  ),
                                )
                              ]
                            )
                          )
                        ]
                      )
                    )
                  )
                ]   
              )
            ]  
          )
        );
    
  


  
  
      

  }
}