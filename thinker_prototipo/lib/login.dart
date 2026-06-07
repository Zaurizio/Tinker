import 'package:flutter/material.dart';
import 'package:thinker_prototipo/cadastro.dart';
import 'package:thinker_prototipo/homepage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}
bool _senhaVisivel = false;

 final text = TextStyle(color: Colors.white,);
    final titulo =TextStyle(fontFamily: 'Stardom',fontSize: 90,color:Colors.white,);

  TextEditingController campoController1 = TextEditingController();
  TextEditingController campoController2 = TextEditingController();
 

class _LoginState extends State<Login> {
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
        Center(child: Text('Login',style: titulo,textAlign: TextAlign.center,)
          
        
        ),
        Center(child: Column(children: [
        Padding(padding: EdgeInsets.all(20)),
       CircleAvatar(backgroundImage: AssetImage('images/ave.png'),radius: 90,),
       Align(alignment: AlignmentGeometry.centerLeft, child: 
       Text("E-mail:",style: text,),
       ),
       TextFormField(
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
          labelText: "usuario@gmail.com",
           labelStyle: TextStyle(
      color: Colors.white,
      fontSize: 16,
    ),
          filled: true,
         fillColor: const Color.fromARGB(255, 47, 128, 177),
        border:OutlineInputBorder(borderRadius: BorderRadius.circular(10))
         ),
          validator: (value){
            if(value!.isEmpty){
              return "Campo obrigatório";
            }
            else{
              return null;
            }
          },


      ),
      SizedBox(height: 60,),
       Align(alignment: AlignmentGeometry.centerLeft, child: 
 Text("Senha:", style: text,),
       ),
  
       TextFormField(
        controller:campoController2,
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
         validator:(value){
          if(value!.isEmpty){
            return "A senha é obrigatória";
          }
          else{
            return null;
          }
         }
      ),
    SizedBox(height: 120,),

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
    Navigator.push(context, MaterialPageRoute(builder: (context)=> Cadastro()));
  },
  child: Text("Não tem uma conta? Cadastre-se",style: TextStyle(
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