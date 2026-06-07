import 'package:flutter/material.dart';
import 'package:thinker_prototipo/Classes/info.dart';
import 'package:thinker_prototipo/_comum/colors.dart';
import 'package:thinker_prototipo/drawer.dart';
class Contato extends StatefulWidget {
  const Contato({super.key});

  @override
  State<Contato> createState() => _ContatoState();
}
TextEditingController nome = TextEditingController();
TextEditingController email = TextEditingController();
TextEditingController numContato   = TextEditingController();
TextEditingController msg = TextEditingController();

String nomeF ="";
String emailU = "";
int numC = 0;
String mensagem ="";

List<Mensagem> listaMensagem =[];
void Mostrar(){
  listaMensagem.forEach((Mensagem m){
    print("nome:" + m.nomeF);
    print("email:" + m.emailU);
    print("Numero:" + m.numC.toString());
    print("Mensagem:" + m.msg);
  
  });
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
class _ContatoState extends State<Contato> {
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
    height:600,
    decoration: BoxDecoration(
      color:Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white,width:1.5),
      
    ),
    child:
    Center(
      
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      Center(child: 
     Text("Fale Conosco",style: TextStyle(color: minhasCores.pretoC,fontSize: 30,)),
      ),
SizedBox(height: 20,),
  Padding(padding: EdgeInsets.all(20),
child: 
     TextField(
controller: nome,
 decoration: InputDecoration(
           focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black, width:1.5),
    ),
         floatingLabelStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
          labelText: "Seu nome",
          
            labelStyle: TextStyle(
      color: Colors.black54,
      fontSize: 16,
    ),
          filled: true,
         fillColor: Colors.white,
        border:OutlineInputBorder(borderRadius: BorderRadius.circular(10))
         ),
      ),
),








SizedBox(height: 10,),
  Padding(padding: EdgeInsets.all(20),
child: 
     TextField(
controller: email,
 decoration: InputDecoration(
           focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black, width:1.5),
    ),
         floatingLabelStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
          labelText: "Seu E-mail",
          
            labelStyle: TextStyle(
      color: Colors.black54,
      fontSize: 16,
    ),
          filled: true,
         fillColor: Colors.white,
        border:OutlineInputBorder(borderRadius: BorderRadius.circular(10))
         ),
      ),
),








SizedBox(height: 10,),
  Padding(padding: EdgeInsets.all(20),
child: 
     TextField(
controller: numContato,
 decoration: InputDecoration(
           focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black, width:1.5),
    ),
         floatingLabelStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
          labelText: "Numero de contato",
          
            labelStyle: TextStyle(
      color: Colors.black54,
      fontSize: 16,
    ),
          filled: true,
         fillColor: Colors.white,
        border:OutlineInputBorder(borderRadius: BorderRadius.circular(10))
         ),
      ),
),
SizedBox(height: 10,),








  Padding(padding: EdgeInsets.all(20),
child: 
     TextField(
      maxLines: 5,
controller: msg,
 decoration: InputDecoration(
           focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black, width:1.5),
      
    ),
         floatingLabelStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
          labelText: "Mensagem",
           alignLabelWithHint: true,
          
            labelStyle: TextStyle(
      color: Colors.black54,
      fontSize: 16,
      
    ),
          filled: true,
         fillColor: Colors.white,
        border:OutlineInputBorder(borderRadius: BorderRadius.circular(10))
        
         ),
      ),
),
   
   Center(child: 
   
   ElevatedButton(
    
    onPressed: (){
      String nomeF = nome.text;
      String emailU = email.text;
      int numC = int.parse(numContato.text);
      String mensagem = msg.text;

      Mensagem m = new Mensagem(nomeF,emailU,numC,mensagem);
      listaMensagem.add(m);
      Mostrar();
      setState(() {
        
      });
      listaMensagem.add(m);
   },
   style: ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
   ),
   
    child: Text("Enviar",style: TextStyle(color: Colors.white),))
   )
        ]
     )
    )
 ) )]
    )
    )
)
)  
  ]
)

])
    );
  }
}