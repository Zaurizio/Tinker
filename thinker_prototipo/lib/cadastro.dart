import 'package:flutter/material.dart';
import 'package:thinker_prototipo/homepage.dart';
import 'package:thinker_prototipo/login.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}
 bool _senhaVisivel = false;
final text = TextStyle(color: Colors.white,);
    final titulo =TextStyle(fontFamily: 'Stardom',fontSize: 90,color:Colors.white,);

  TextEditingController campoController1 = TextEditingController();
  TextEditingController campoController2 = TextEditingController();
  TextEditingController campoController3 = TextEditingController();
 
class _CadastroState extends State<Cadastro> {
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
        Center(child: Text('Cadastro',style: titulo,textAlign: TextAlign.center,)
          
        
        ),
        Center(child: Column(children: [
        Padding(padding: EdgeInsets.all(20)),
       CircleAvatar(backgroundImage: AssetImage('images/ave.png'),radius: 90,),
       Align(alignment: AlignmentGeometry.centerLeft, child: 
       Text("Usuario:",style: text,),
       ),
       SizedBox(height: 10,),




       TextField(
        controller:campoController1,
        onChanged: (value){
          print(value);
        },
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
           focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width:1.5),
           ),
           floatingLabelStyle: TextStyle(color: Colors.white),
          labelText: "insira seu nome",
           labelStyle: TextStyle(
      color: Colors.white,
      fontSize: 16,
    ),
          filled: true,
         fillColor: const Color.fromARGB(255, 47, 128, 177),
        border:OutlineInputBorder(borderRadius: BorderRadius.circular(10))
         ),
      ),
      SizedBox(height: 60,),
       Align(alignment: AlignmentGeometry.centerLeft, child: 
 Text("nome:", style: text,),
       ),
       SizedBox(height: 10,),


  
       TextField(
        controller:campoController2,
        onChanged: (value){
          print(value);
        },
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
           focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width:1.5),
    ),
         floatingLabelStyle: TextStyle(color: Colors.white),
          labelText: "insira seu email",
          
            labelStyle: TextStyle(
      color: Colors.white,
      fontSize: 16,
    ),
          filled: true,
         fillColor: const Color.fromARGB(255, 47, 128, 177),
        border:OutlineInputBorder(borderRadius: BorderRadius.circular(10))
         ),
      ),
    SizedBox(height: 60,),
    



 Align(alignment: AlignmentGeometry.centerLeft, child: 
 Text("senha:", style: text,),
       ),
       SizedBox(height: 10,),
     TextField(
        controller:campoController3,
        obscureText: !_senhaVisivel,
        onChanged: (value){
          print(value);
        },
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
           focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width:1.5),
    ),
         floatingLabelStyle: TextStyle(color: Colors.white),
          labelText: "Insira sua senha",
          
            labelStyle: TextStyle(
      color: Colors.white,
      fontSize: 16,
    ),
          filled: true,
         fillColor: const Color.fromARGB(255, 47, 128, 177),
        border:OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
         suffixIcon: IconButton(
        icon: Icon(_senhaVisivel ? Icons.visibility : Icons.visibility_off),
          color: Colors.white,
        onPressed: (){
          setState(() {
            _senhaVisivel = !_senhaVisivel;
          });
        },
        ),
         ),
      ),
    SizedBox(height:60 ,),


    ElevatedButton(onPressed: (){
Navigator.push(context, MaterialPageRoute(builder: (context) => Homepage())
);
    },
  style: ElevatedButton.styleFrom(
        backgroundColor:  Color.fromARGB(255, 0, 0, 0),
         padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        
  ),
    child:Text("Entrar",style:TextStyle(color: Colors.white,fontSize:17),),),
   SizedBox(height: 10,),
GestureDetector(
  onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
  },
  child: Text("Já tem uma conta? Login",style: TextStyle(
    color: Colors.white,
    decoration: TextDecoration.underline,
    decorationColor: Colors.white,
    ),),
)

       
       ],)

        
        )
       ],
       
       
           ),
          )
         ),
        ], 
       ),

    );
  }
}