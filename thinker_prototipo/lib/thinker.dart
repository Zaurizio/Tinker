import 'package:flutter/material.dart';
import 'package:thinker_prototipo/_comum/colors.dart';
import 'package:thinker_prototipo/cadastrologin.dart';

class Thinker extends StatelessWidget {
  Thinker({super.key});

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

       
        
Center(child:
        
        DecoratedBox(decoration: BoxDecoration(
          
          border: Border.all(color: const Color.fromARGB(255, 22, 83, 122)),
          color: const Color.fromARGB(255, 30, 103, 148),
          borderRadius: BorderRadius.circular(20)),
        child: Padding(padding: EdgeInsets.all(30),child:Column( children: [
          
      
        Text('Textinhos legais sobre o projeto que eu não faço ideia sobre já que Tinker foi inspirado na ideia de que o conhecimento deve ser algo definitivamente o que escrever,que Tinker foi inspirado na ideia de que o conhecimento deve ser algo definitivamente.',style: text,textAlign: TextAlign.justify,), 
        SizedBox(height: 20,),
       Text("Mergulhar nunca foi tão bom!!!",style:text,textAlign:TextAlign.justify,) 
        ]

        
         ),     
        )
       ),
      ),

 Spacer(),

 Center(child:  
 
 
      ElevatedButton(onPressed: (){
Navigator.push(context, MaterialPageRoute(builder: (context) => LoginCadastro()),
            );

      }, 
      style: ElevatedButton.styleFrom(
        backgroundColor:  minhasCores.pretoC,
       minimumSize:Size(200, 55), 
      ),
      child: Text("Começe agora",style: TextStyle(color: Colors.white),))
 
       ,),

 
Spacer(),

      
        
        ],
        ),
        
        ),
        
        ),
       
   Positioned( 
    bottom: -125 ,
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