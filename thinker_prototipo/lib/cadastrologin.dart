import 'package:flutter/material.dart';
import 'package:thinker_prototipo/cadastro.dart';
import 'package:thinker_prototipo/login.dart';

class LoginCadastro extends StatelessWidget {
  LoginCadastro({super.key});

  final text = TextStyle(color: Colors.white,);
    final titulo =TextStyle(fontFamily: 'Stardom',fontSize: 90,color:Colors.white,);

    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack
      (
       fit: StackFit.expand,
       children: [
        Image.asset('assets/images/constelacao.png',fit: BoxFit.cover,),

        SafeArea(child: Padding(padding:const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children:[
        Center(child: Text('Tinker',style: titulo,textAlign: TextAlign.center,)

        
        ),

       
        

        
     

      SizedBox(height:200 ,),
      Row(mainAxisAlignment: MainAxisAlignment.center ,children: [

 Center(child:  
      ElevatedButton(onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => Login())

        );
      }, 
      
      style: ElevatedButton.styleFrom(
        backgroundColor:  Color.fromARGB(255, 0, 0, 0),
       minimumSize:Size(100, 55), 
      ),
      child: Text("Entrar",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),))
 
       ,),

       SizedBox(width: 50,),

Center(child:  
      ElevatedButton(onPressed: (){

 Navigator.push(context, MaterialPageRoute(builder: (context) => Cadastro())
 );

      }, 
      style: ElevatedButton.styleFrom(
        backgroundColor:  Color.fromARGB(255, 0, 0, 0),
        minimumSize:Size(150, 55), 
      ),
      child: Text("Cadastrar-se",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),))
        ,),    
       ],
     ),
        ]
        )  ,
        
   ), 
 ),

   Positioned( 
    bottom: -125,
    right: -475,
    child: IgnorePointer(
child:Transform.rotate(angle: 0.30,
child:  Image.asset("assets/images/logo.png",width: 1100,alignment: Alignment.bottomRight)),
    )
)
       ], 
      ), 
    );
  }
}