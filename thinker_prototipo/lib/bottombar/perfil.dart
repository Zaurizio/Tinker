

import 'package:flutter/material.dart';
import 'package:thinker_prototipo/_comum/colors.dart';
import 'package:thinker_prototipo/drawer.dart';


class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}
String plano = "mensal";
String texto ="";
String image ="";
void planos(){
  if (plano == "gratuito"){
    texto = "Gratuito: 0.00 R\$";
    image = "assets/images/Pgratuito.png";

    
  }
  else if(plano == "mensal"){
    texto = "Mensal: 15,99 R\$";
    image = "assets/images/Pmensal.png";
  }
  else if (plano == "estudantil"){
    texto ="Estudantil: 21,90 R\$";
    image = "assets/images/Pestudantil.png";
  }

else{
  texto ="vai dar um erro aq só de sacanagem";
}
  
}


String fotoUser ="assets/images/user.png";
String nomeUser ="Nome Usuario";
String objetivo = "objetivo";
int sequencia = 0;
String cargo = "cargo";
int pontuacao = 0;



Widget infoBox(String texto ,{ IconData? icone}) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 4),
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: minhasCores.azulC,
      borderRadius: BorderRadius.circular(10),
    ),
    child:  Row(
      children: [
        Icon(icone,color: Colors.white,),
        Expanded(child: 
    Text(
      texto,
      style: TextStyle(color: Colors.white),
    )
    ),
    ],)
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


   
   
class _PerfilState extends State<Perfil> {
  @override
  void initState(){
    super.initState();
    setState(() {
       planos();
    });
   
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
      backgroundColor: minhasCores.azulE,
       iconTheme: IconThemeData(color: Colors.white70,size: 30),
     ),
     
       drawer:
    
        MeuDrawer(),
         
       body: 
       
        Stack 
   
      (
        
       fit: StackFit.expand,
children:[
     
         
       Container(decoration: BoxDecoration(gradient:LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        
        colors: [
        minhasCores.azulE,
        minhasCores.azulC,
       ]) ),),
Stack(children: [
  
  Positioned(
    top: -50,
    left: 60,
    child:IgnorePointer(
    child: Image.asset('assets/images/logo.png',width: 300,)
    )
    )
],

),

        SafeArea(child: Padding(padding:EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          SizedBox(height: 30,),
        Center(child: tituloContornado,
        
      
                 ),
                 SizedBox(height: 30,),
Center(child: Column(children: [
  CircleAvatar(radius: 90,backgroundColor: Colors.black, 
  
  child: 
            CircleAvatar(
             backgroundImage: AssetImage(fotoUser),
             radius: 90,backgroundColor: minhasCores.azulE,), 
  ) ,
 Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: minhasCores.azulE,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        children: [

        
          Text(nomeUser, style: TextStyle(color: Colors.white, fontSize: 18), ),

          SizedBox(height: 15),

          
          Row(
            children: [
              
              Expanded(child: infoBox("Objetivo",icone:Icons.auto_awesome)),
              SizedBox(width: 8),
              Expanded(child: infoBox(objetivo)),
            ],
          ),

          Row(
            children: [
             
              Expanded(child: infoBox("Sequência",icone:Icons.bolt)),
              SizedBox(width: 8),
              Expanded(child: infoBox(sequencia.toString())),
            ],
          ),

          Row(
            children: [
             
              Expanded(child: infoBox(" Cargo",icone:Icons.people_alt_outlined)),
              SizedBox(width: 8),
              Expanded(child: infoBox(cargo)),
            ],
          ),

          SizedBox(height: 10),

          
          Container(
            padding: EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: minhasCores.azulC,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
             
              child:Row(mainAxisAlignment: MainAxisAlignment.center,    children: [
              
              Icon(Icons.star,color: Colors.white, ), 
              Text("Pontuação: ",style: TextStyle(color: Colors.white),),
              Text(pontuacao.toString() ,style: TextStyle(color: Colors.white),),
              ]
              ),
            ),
          ),
        ],
      ),
    ),

    SizedBox(height: 10),

    // BOTÕES
    Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Editar", style: text),
                  SizedBox(width: 5),
                  Icon(Icons.edit, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 1),
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Sair", style: text),
                  SizedBox(width: 5),
                  Icon(Icons.logout, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ],
    ),

    SizedBox(height: 20),

    
    Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(texto, style: TextStyle(color: Colors.white),),
          CircleAvatar(
            radius: 35,
            backgroundImage: AssetImage(image),
          )
        ],
      ),
    ),
  ],
)
)
            ],),
)  
        )
        ],
        ),
        );
   
  }
}