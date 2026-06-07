import 'package:flutter/material.dart';
import 'package:thinker_prototipo/_comum/colors.dart';
import 'package:thinker_prototipo/complementosGame/linhas.dart';
import 'package:thinker_prototipo/complementosGame/tela_fase.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}



class _GameState extends State<Game> {

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      body: Stack
      (
        
       fit: StackFit.expand,
       children: [
        Image.asset('assets/images/estrela.gif',fit: BoxFit.cover,),




      SafeArea(child:Padding(padding:EdgeInsets.all(16),
      child: Stack(
        
        children: [
         
       CustomPaint(
  painter: Linhas(),
),
          Positioned(
                bottom: -40,
                left:-30 ,
            child:IgnorePointer(
            child: 
             Image.asset("assets/images/galaxia.png"))


          ),





          Positioned(
            bottom: 210,
            left: 40,
            child: 
          GestureDetector(
            onTap:() =>Navigator.push(context,
    MaterialPageRoute(builder: (_) =>  TelaFase(
      numeroFase: 1,
      pergunta: ' Quem foi a primeira pessoa a viajar no Espaço?',
      alternativas: ['Opção A', 'Opção B', 'Opção C', 'Opção D'],
      respostaCorreta: 0,
    ),
  )),
              
            
            child: Image.asset("assets/images/faseE.png",width: 80,),
          )
          ),





          Positioned(
            bottom: 150,
            right: 70,
            child: 
          GestureDetector(
            onTap: ()  =>Navigator.push(context,
    MaterialPageRoute(builder: (_) =>  TelaFase(
      numeroFase: 2,
      pergunta: 'Qual a montanha mais alta do mundo?',
      alternativas: ['Opção A', 'Opção B', 'Opção C', 'Opção D'],
      respostaCorreta: 0,
    ),
  )),
            child: Image.asset("assets/images/faseE.png",width: 80,),
          )
          ),





          Positioned(
            bottom: 270,
            right: 30,
            child: 
          GestureDetector(
            onTap: ()  =>Navigator.push(context,
    MaterialPageRoute(builder: (_) =>  TelaFase(
      numeroFase: 3,
      pergunta: 'Onde se localiza Machu Picchu',
      alternativas: ['Opção A', 'Opção B', 'Opção C', 'Opção D'],
      respostaCorreta: 0,
    ),
  )),
            child: Image.asset("assets/images/faseE.png",width: 80,),
          )
          ),

   Positioned(
             bottom:370 ,
            right: 130,
            child: 
          GestureDetector(
            onTap: ()  =>Navigator.push(context,
    MaterialPageRoute(builder: (_) =>  TelaFase(
      numeroFase: 4,
      pergunta: 'Que país tem o formato de uma bota?',
      alternativas: ['Opção A', 'Opção B', 'Opção C', 'Opção D'],
      respostaCorreta: 0,
    ),
  )),
            child: Image.asset("assets/images/faseE.png",width: 60,),
          )
          ),

             Positioned(
              bottom: 320,
            left: 70,
           
            child: 
          GestureDetector(
            onTap: ()  =>Navigator.push(context,
    MaterialPageRoute(builder: (_) =>  TelaFase(
      numeroFase: 5,
      pergunta: 'O que é mais pesado: 1 quilo de algodão ou 1 quilo de ferro?',
      alternativas: ['Opção A', 'Opção B', 'Opção C', 'Opção D'],
      respostaCorreta: 0,
    ),
  )),
            child: Image.asset("assets/images/faseE.png",width: 80,),
          )
          ),

             Positioned(
            bottom: 440,
            left: 20,
            child: 
          GestureDetector(
            onTap: ()  =>Navigator.push(context,
    MaterialPageRoute(builder: (_) =>  TelaFase(
      numeroFase: 6,
      pergunta: 'Quem inventou a lâmpada?',
      alternativas: ['Opção A', 'Opção B', 'Opção C', 'Opção D'],
      respostaCorreta: 0,
    ),
  )),
            child: Image.asset("assets/images/faseE.png",width: 80,),
          )
          ),


          Positioned(
            bottom: 460,
            left: 300,
            child: 
          GestureDetector(
            onTap: () =>Navigator.push(context,
    MaterialPageRoute(builder: (_) =>  TelaFase(
      numeroFase: 7,
      pergunta: 'Quanto tempo a Terra demora para dar uma volta completa em torno dela mesma?',
      alternativas: ['Opção A', 'Opção B', 'Opção C', 'Opção D'],
      respostaCorreta: 0,
    ),
  )),
            child: Image.asset("assets/images/faseE.png",width: 80,),
          )
          ),




          Positioned(
            bottom: 560,
            left: 300,
            child: 
          GestureDetector(
            onTap: () =>Navigator.push(context,
    MaterialPageRoute(builder: (_) =>  TelaFase(
      numeroFase: 8,
      pergunta: 'A que temperatura a água ferve?',
      alternativas: ['Opção A', 'Opção B', 'Opção C', 'Opção D'],
      respostaCorreta: 0,
    ),
  )),
            child: Image.asset("assets/images/faseE.png",width: 80,),
          )
          ),



           Positioned(
            bottom: 520,
            left: 89,
            child: 
           
             
              Column(
                children: [
              
              
             
          GestureDetector(
            onTap: () =>Navigator.push(context,
    MaterialPageRoute(builder: (_) =>  TelaFase(
      numeroFase: 9,
      pergunta: 'Quais são as fases da Lua?',
      alternativas: ['Opção A', 'Opção B', 'Opção C', 'Opção D'],
      respostaCorreta: 0,
    ),
  )),
  
            child: Image.asset("assets/images/faseE.png",width: 80,),
          
          ),
          ],),
            ),
      
 Positioned(
            bottom: 650,
            right: 250,
            child: 
           
             
              Column(
                children: [
              
              
             
          GestureDetector(
            onTap: () =>Navigator.push(context,
    MaterialPageRoute(builder: (_) =>  TelaFase(
      numeroFase: 10,
      pergunta: 'Quantos ossos temos no nosso corpo?',
      alternativas: ['Opção A', 'Opção B', 'Opção C', 'Opção D'],
      respostaCorreta: 0,
    ),
  )),
  
            child: Image.asset("assets/images/faseE.png",width: 80,),
          
          ),
          ],),
            ),
      


          Positioned(
                top: -30,
                right:10 ,
            child:IgnorePointer(
            child: 
             
             Image.asset("assets/images/galaxia.png"))
            

          ),
          Positioned(
            top:20,
            right: 70,
            child: 
          Container(
            width: 200,
            height: 40,
              decoration: BoxDecoration(
                color: minhasCores.azulC,
                shape: BoxShape.rectangle,
                border: Border.all(
                  color: minhasCores.azulE2,
                  width: 2,
                  ),
                
                borderRadius: BorderRadius.circular(8)
              ),
              
              child:
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star,color: Colors.white,size: 30,),
               Text("Galaxia 2",style: TextStyle(
                color: minhasCores.pretoC,
                fontFamily: 'Pixelada',
                fontWeight: FontWeight.bold,
                fontSize: 30,
             
              ),
              
              ),
             
              Icon(Icons.star,color: Colors.white,size: 30,),
             
              ]
              )
              
          )
          ),
            Positioned(
            bottom:20,
            left: 30,
            child: 
          Container(
            width: 200,
            height: 40,
              decoration: BoxDecoration(
                color: minhasCores.azulC,
                shape: BoxShape.rectangle,
                border: Border.all(
                  color: minhasCores.azulE2,
                  width: 2,
                  ),
                
                borderRadius: BorderRadius.circular(8)
              ),
              
              child:
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star,color: Colors.white,size: 30,),
               Text("Galaxia 1",style: TextStyle(
                color: minhasCores.pretoC,
                fontFamily: 'Pixelada',
                fontWeight: FontWeight.bold,
                fontSize: 30,
             
              ),
              
              ),
             
              Icon(Icons.star,color: Colors.white,size: 30,),
             
              ]
              )
              
          )
          ),
        ],
      ),) )
      ],
      
    
      
      ),

      
    
   );
   
  }
}



