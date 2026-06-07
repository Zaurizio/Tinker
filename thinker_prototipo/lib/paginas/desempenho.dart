import 'package:flutter/material.dart';
import 'package:thinker_prototipo/_comum/colors.dart';


class Desempenho extends StatefulWidget {
  const Desempenho({super.key});

  @override
  State<Desempenho> createState() => _DesempenhoState();
}

class _DesempenhoState extends State<Desempenho> {

List <String> Fsemana= [
"12 questoes de matematica",


"4 questões de história",


"1 simulado concluido"
];

List <String> erros = [
  "poligonos",
  "Quimica organica",
  "Biologia",
];

List <String> acertos = [
  "Geopolitica",
  "Termodinamica",
  "Cartografia",
];

List <String> aprim = [
  "Voce deve melhorar em Português",
  "Você deve melhorar em semelhança de triangulos",
  "Voce deve melhorar em quimica",
];

  final text = TextStyle(color: Colors.white,);
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
          body:  Stack 
      (
       fit: StackFit.expand,
children:[
     
         
      Image.asset('assets/images/constelacao.png', fit: BoxFit.cover),
Stack(children: [

    Positioned(
 top: 50,
 left: 16,
  child:Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color:minhasCores.azul2C,
    ),
  child: IconButton(onPressed: (){
Navigator.pop(context);
  }, icon: Icon(Icons.arrow_back,color: Colors.white,)),
  ),
),
  Positioned(
    top: -50,
    left: 60,
    child:IgnorePointer(
    child: Image.asset('assets/images/logo.png',width: 300,)
    )
    ),
 
],

),

        SafeArea(child: Padding(padding:const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          SizedBox(height: 30,),
        Center(child: tituloContornado,
        
      
                 ),
    SizedBox(height: 60,),
Column(
  
  children: [

  
    Center(child: Stack(
      clipBehavior: Clip.none,
      children: [
Container(
  
          width:360 ,
          height:50 ,
          decoration: BoxDecoration(
            color:  minhasCores.azulC,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color:Colors.white, width: 1.5),
            
          ),



         child: Center(
        child: 
        Text("Desempenho",style: TextStyle(color: Colors.white,fontSize: 35,fontWeight: FontWeight(30)),), 
        
        ),
         ),
         Positioned(
          top:-25,
          left: 0,
          right: 0,
          child:Center(
          child: Icon(Icons.star, color:Colors.white,size:50))
         ),
      ], 
    ),
 ),
 

  ]
    ),       
     

    
            SizedBox(height: 30,),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  InkWell(
            borderRadius: BorderRadius.circular(16),
             onTap: () {
              
             },
        child: Container(
          width:360 ,
          height: 160,
          decoration: BoxDecoration(
            color:  minhasCores.azulC,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromARGB(255, 28, 154, 230), width: 6),
          ),
          child:SingleChildScrollView(
          child: Column(
            children: [
              Center(child: 
                Text("Feitos da Semana", 
                
                style: 
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25)),
                  ),
                  SizedBox(height: 8),
                  ...Fsemana.map((item) => Padding(
                    
                  padding: EdgeInsets.symmetric(vertical:8),
                  child:Row(
                    children: [
                        Icon(Icons.check_circle,
                        color:Colors.white,
                        size: 18,
                         ),
                         SizedBox(width: 8,),
                         Expanded(
                          child:Text(item, style:TextStyle(color: Colors.white)) )
                  
                    ],
                  ),
                ),
              )
            ],
            
            ))
          
          ),


                  )
            ]
            ),


            SizedBox(height: 30,),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  InkWell(
            borderRadius: BorderRadius.circular(16),
             onTap: () {

             },
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color:  const Color.fromARGB(255, 47, 128, 177),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromARGB(255, 28, 154, 230), width: 6),
          ),
          child:SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: 
                Text("Erros",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20)),
              ),
                SizedBox(height: 6,),
                ...erros.map((item) => Padding(
                  padding:EdgeInsets.symmetric(vertical: 8),
                  child:Row(children: [
                    Icon(Icons.cancel,color:Colors.white,size:18),
                    SizedBox(width: 8),
                    Expanded(child: Text(item,style: TextStyle(color: Colors.white),),)
                  ],)
                   )
                
                
                )

            ],
            
            ))
        ),
          ),


               InkWell(
            borderRadius: BorderRadius.circular(16),
             onTap: () {

             },
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 47, 128, 177),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromARGB(255, 28, 154, 230), width: 6),
          ),
          child:SingleChildScrollView(
          child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: 
                Text("Acertos",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize:20)),
              ),
                SizedBox(height: 6,),
                ...acertos.map((item) => Padding(
                  padding:EdgeInsets.symmetric(vertical: 8),
                  child:Row(children: [
                    Icon(Icons.check,color:Colors.white,size:18),
                    SizedBox(width: 8),
                    Expanded(child: Text(item,style: TextStyle(color: Colors.white),),)
                  
            ],)
                   )
            
           )])
          
                  ),
                 ),
               ),
            ]
            ),
            SizedBox(height: 30,),
            Center(child: 
             InkWell(
            borderRadius: BorderRadius.circular(16),
             onTap: () {
             
             },
        child: Container(
          width: 360,
          height: 160,
          decoration: BoxDecoration(
            color:  const Color.fromARGB(255, 47, 128, 177),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromARGB(255, 28, 154, 230), width: 6),
          ),
          child:SingleChildScrollView(
          child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: 
                Text("Aprimoramento",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 25)),
              ),
                SizedBox(height: 6,),
                ...aprim.map((item) => Padding(
                  padding:EdgeInsets.symmetric(vertical: 8),
                  child:Row(children: [
                    Icon(Icons.arrow_right,color:Colors.white,size:18),
                    SizedBox(width: 8),
                    Expanded(child: Text(item,style: TextStyle(color: Colors.white),),)
                  ],)
                   )
           )])
          
          )

          
            ),
            )
            )
                ],
              ),
            ),
            
          ),
       
       
       ]

      ),
 );
  }
}