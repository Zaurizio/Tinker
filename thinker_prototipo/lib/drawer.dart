import 'package:flutter/material.dart';
import 'package:thinker_prototipo/_comum/colors.dart';

import 'package:thinker_prototipo/bottombar/perfil.dart';
import 'package:thinker_prototipo/telasDrawer/planos.dart';
import 'package:thinker_prototipo/telasDrawer/info.dart';
import 'package:thinker_prototipo/telasDrawer/contato.dart';
class MeuDrawer extends StatelessWidget {
  const MeuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer( backgroundColor: minhasCores.pretoC,
      width: 300,
      child: Column(
        children: [
        
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Padding(padding: EdgeInsets.all(16),
              child: 
          CircleAvatar(
            
             backgroundImage: AssetImage(fotoUser),
             radius: 50,backgroundColor: minhasCores.azulE,
             
             ),
              ), 
           Text(nomeUser, style: TextStyle(color: Colors.white, fontSize: 18), ),
           SizedBox(width: 20,)
            ],
            ),
SizedBox(height: 100,),
Row(children: [

GestureDetector(onTap: () {
Navigator.push(context, MaterialPageRoute(builder: (context)=> Planos())
);
} ,
child: Row(children: [
SizedBox(width: 35,),
 Icon(Icons.monetization_on_outlined,color: Colors.white,size: 40,),
SizedBox(width: 10,),
Text("Faça o upgrade",style: TextStyle(color: Colors.white, fontSize: 18),),
SizedBox(width: 40,),
Icon(Icons.arrow_forward_ios,color: Colors.white70,size: 15,),
],)
)
],),

SizedBox(height: 100,),
Row(children: [

GestureDetector(onTap: () {
Navigator.push(context, MaterialPageRoute(builder: (context)=> Contato())
);
} ,
child: Row(children: [
SizedBox(width: 35,),
 Icon(Icons.message_rounded,color: Colors.white,size: 40,),
SizedBox(width: 10,),
Text("Fale conosco",style: TextStyle(color: Colors.white, fontSize: 18),),
SizedBox(width: 57,),
Icon(Icons.arrow_forward_ios,color: Colors.white70,size: 15,),
]
)
)
],),


SizedBox(height: 100,),

Row(children: [

GestureDetector(onTap: () {
Navigator.push(context, MaterialPageRoute(builder: (context)=> Info())
);
} ,
child: Row(children: [
SizedBox(width: 35,),
 Icon(Icons.info_outline_rounded,color: Colors.white,size: 40,),
SizedBox(width: 10,),
Text("Sobre",style: TextStyle(color: Colors.white, fontSize: 18),),
SizedBox(width: 118,),
Icon(Icons.arrow_forward_ios,color: Colors.white70,size: 15,),

],

),

)
],

),
SizedBox(height: 100,),
ElevatedButton(onPressed: (){
 Navigator.pushReplacementNamed(context, '/homepage'
);
},
 child: Text("Voltar a home")),

  SizedBox(height: 150,),
Text("versao 0.0.0.012",style: TextStyle(color: Colors.white12),),
      
       ],
       )
       );
        
      
    
  }
}