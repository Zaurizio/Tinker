import 'package:flutter/material.dart';
import 'package:thinker_prototipo/_comum/colors.dart';
import 'package:thinker_prototipo/drawer.dart';
class Planos extends StatefulWidget {
  const Planos({super.key});

  @override
  State<Planos> createState() => _PlanosState();
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
class _PlanosState extends State<Planos> {
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
child:SingleChildScrollView(child: 
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
      child:tituloContornado ,),

          ],
        ),
      ),
    ),
SizedBox(height: 60,),
Center(
  child: Container(
    width: 360,
    height:50,
    decoration: BoxDecoration(
      color:Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white,width:1.5),
      
    ),
    child:
    Center(child: 
     Text("Faça o upgrade",style: TextStyle(color: minhasCores.pretoC,fontSize: 35,fontWeight: FontWeight.bold)),),
    )
    
  ),
   SizedBox(height: 20,),
Center(child: 
                  Container(
                    width:350,
                    height: 180,
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color:minhasCores.cinza,
                    ),
                    child: Row(children: [
                      ClipRRect(borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          child: 
                      Image.asset("assets/images/Pgratuito.png",width: 160,
                      height:180, 
                      fit:BoxFit.cover,)
                      ),
                      Expanded(child: Padding(padding:EdgeInsets.all(10), 
                  child: Column(
                     //crossAxisAlignment: CrossAxisAlignment.start,
                    //  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Text("Plano Gratuito",style: TextStyle(color: Colors.white,fontSize: 25),),
                  Text("Voce ira aproveitar dos serviços basicos do Tinker",style: TextStyle(color: Colors.white,),textAlign: TextAlign.center,),
                  Text("R\$0,00",style: TextStyle(color: minhasCores.pretoC,fontSize: 31,fontWeight: FontWeight.bold)),
],),)
                      )
                      
                    ],   
                    ),
                  )
),
 SizedBox(height: 20,),
Center(child: 
                  Container(
                    width:350,
                    height: 180,
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color:minhasCores.cinza,
                    ),
                    child: Row(children: [
                      ClipRRect(borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          child: 
                      Image.asset("assets/images/Pmensal.png",width: 160,
                      height:180, 
                      fit:BoxFit.cover,)
                      ),
                      Expanded(child: Padding(padding:EdgeInsets.all(10), 
                  child: Column(
                     //crossAxisAlignment: CrossAxisAlignment.start,
                    //  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Text("Plano Mensal",style: TextStyle(color: Colors.white,fontSize: 25),),
                  Text("Voce irá aproveitar dos serviços exclusivos do Tinker e de forma ilimitada",style: TextStyle(color: Colors.white,),textAlign: TextAlign.center,),
                  Text("R\$0,00",style: TextStyle(color: minhasCores.pretoC,fontSize: 31,fontWeight: FontWeight.bold)),
],),)
                      )
                      
                    ],   
                    ),
                  )
),
 SizedBox(height: 20,),
Center(child: 
                  Container(
                    width:350,
                    height: 180,
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color:minhasCores.cinza,
                    ),
                    child: Row(children: [
                      ClipRRect(borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          child: 
                      Image.asset("assets/images/Pestudantil.png",width: 160,
                      height:180, 
                      fit:BoxFit.cover,)
                      ),
                      Expanded(child: Padding(padding:EdgeInsets.all(10), 
                  child: Column(
                     //crossAxisAlignment: CrossAxisAlignment.start,
                    //  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Text("Plano Max",style: TextStyle(color: Colors.white,fontSize: 25),),
                  Text("Voce irá ter a experiência completa do Tinker e pelo melhor preço ",style: TextStyle(color: Colors.white,),textAlign: TextAlign.center,),
                  Text("R\$0,00",style: TextStyle(color: minhasCores.pretoC,fontSize: 31,fontWeight: FontWeight.bold)),
],),)
                      )
                      
                    ],   
                    ),
                  )
)
  ]

  
                      ),
                     )
                    )
)
                   ],
                   
                  ),
                
                 ],
                  
                )
                
               );



  }
}