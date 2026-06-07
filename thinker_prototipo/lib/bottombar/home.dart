import 'package:flutter/material.dart';
import 'package:thinker_prototipo/paginas/calendario.dart';
import 'package:thinker_prototipo/paginas/desempenho.dart';
import 'package:thinker_prototipo/paginas/questoes.dart';
import 'package:thinker_prototipo/paginas/simulado.dart';
import 'package:thinker_prototipo/paginas/turma.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

   final text = TextStyle(color: Colors.white,);
   final titulo =TextStyle(fontFamily: 'Stardom',fontSize: 90,color:Colors.white,);





  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body:  Stack 
      (
       fit: StackFit.expand,
children:[
     
         
       
        Image.asset('assets/images/constelacao.png',fit: BoxFit.cover,),
       SizedBox(height: 100,),
Stack(children: [
  
  Positioned(
    top: -105,
    left: -40,
    child:IgnorePointer(
    child: Image.asset('assets/images/logo.png',width: 500,)
    )
    )
],

),

        SafeArea(child: Padding(padding:const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          SizedBox(height: 30,),
        Center(child: Text('Tinker',style:titulo,textAlign: TextAlign.center,)

        
                 ),
            SizedBox(height: 30,),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  InkWell(
            borderRadius: BorderRadius.circular(16),
             onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => Calendario())
);
             },
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color:  const Color.fromARGB(255, 47, 128, 177),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromARGB(255, 28, 154, 230), width: 6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/calendario.png',),
              Container(
                child: Column(children: [
               ColoredBox(color: Colors.black),
               IgnorePointer(
                child: 
              Text("Calendário",style: TextStyle(fontSize: 16,color: Colors.white),)
               ),
              ],)
              )
              ,]))
          
          ),


               InkWell(
            borderRadius: BorderRadius.circular(16),
             onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => Questoes())
);
             },
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color:  const Color.fromARGB(255, 47, 128, 177),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromARGB(255, 28, 154, 230), width: 6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IgnorePointer(
                child:
              Image.asset('assets/images/questoes.png',height:125,width: 170,),
              ),
              Text("Questões",style: TextStyle(fontSize: 16,color: Colors.white),)
              
              ,]))
          
          )
          
            ]
            ),


            SizedBox(height: 30,),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  InkWell(
            borderRadius: BorderRadius.circular(16),
             onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => Simulado())
);
             },
        child: Container(
          width: 160,
          height: 170,
          decoration: BoxDecoration(
            color:  const Color.fromARGB(255, 47, 128, 177),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromARGB(255, 28, 154, 230), width: 6),
          ),
          
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            
            children: [
             SizedBox(height: 1,),
             IgnorePointer(
              child:
              Image.asset('assets/images/simulado.png',height: 125,),
             ),
              Text("Simulado",style: TextStyle(fontSize: 16,color: Colors.white),)
              
              ,]))
          
          ),


               InkWell(
            borderRadius: BorderRadius.circular(16),
             onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => Turma())
);
             },
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 47, 128, 177),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromARGB(255, 28, 154, 230), width: 6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IgnorePointer(child: 
              
              
              Image.asset('assets/images/turma.png',height: 125,),
              
              ),
             
              Text("Turma",style: TextStyle(fontSize: 16,color: Colors.white),)
              
              ,]))
          
          )
          
            ]
            ),
            SizedBox(height: 30,),
            Center(child: 
             InkWell(
            borderRadius: BorderRadius.circular(16),
             onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => Desempenho())
);
             },
        child: Container(
          width: 350,
          height: 160,
          decoration: BoxDecoration(
            color:  const Color.fromARGB(255, 47, 128, 177),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromARGB(255, 28, 154, 230), width: 6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IgnorePointer(
                child: 
              Image.asset('assets/images/desempenho.png',height: 125,),
              ),
              Text("Desempenho",style: TextStyle(fontSize: 16,color: Colors.white),)
              
              ,]))
          
          )

          
            ),
            
                ],
              ),
            ),
            
          ),
       
       
       ]

      ),
 
     
    );
  }
}