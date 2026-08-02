

import 'package:flutter/material.dart';

import 'package:tinker/drawer.dart';






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
    image = "assets/images/tinker_images/Pgratuito.png";

    
  }
  else if(plano == "mensal"){
    texto = "Mensal: 15,99 R\$";
    image = "assets/images/tinker_images/Pmensal.png";
  }
  else if (plano == "estudantil"){
    texto ="Estudantil: 21,90 R\$";
    image = "assets/images/tinker_images/Pestudantil.png";
  }

else{
  texto ="vai dar um erro aq só de sacanagem";
}
  
}


String fotoUser ="assets/images/tinker_images/user.png";
String nomeUser = "nome user";
String emailUser = "Bolas@gmail.com";
String objetivo = "objetivo";
int sequencia = 0;
String cargo = "cargo";
int pontuacao = 0;


class _PerfilState extends State<Perfil> {
  @override
  void initState() {
    super.initState();
    setState(() {
      planos();
    });
  }


  Widget CardsObj(IconData icone, String valor, String label) {
    return Container(
      padding:  EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color:  Color(0xFF0D2035),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color:  Color(0xFF1E3D5C), width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icone,color: Colors.amber),
           SizedBox(height: 4),
           
          Text(valor,
              style:  TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: Color(0xFF8AABCC), fontSize: 11)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFF0D1B2A),
      drawer: MeuDrawer(),
      
      appBar: AppBar(
        backgroundColor:  Color(0xFF0D1B2A),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:  EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               SizedBox(height: 16),

              Center(child: 
              Row(
                children: [
                  
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:  Color(0xFF1A4A7A),
                    child: Image.asset('assets/images/tinker_images/logo2.png', ),
                  ),
                   SizedBox(width: 12),
                   Text('TINKER',
                      style: TextStyle(
                          fontFamily: 'Stardom',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2)),
                ],
              ),
              ),
               SizedBox(height: 20),

               Text('Meu perfil',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
               SizedBox(height: 4),
               Text('Gerencie suas informações e preferências',
                  style: TextStyle(color: Color(0xFF8AABCC), fontSize: 14)),

               SizedBox(height: 20),

              
              Container(
                padding:  EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:  Color(0xFF0F2744),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color:  Color(0xFF1E3D5C), width: 0.5),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor:  Color(0xFF1A4A7A),
                      backgroundImage: AssetImage(fotoUser),
                    ),
                     SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nomeUser,
                              style:  TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold)),
                           SizedBox(height: 3),
                          Text(emailUser,
                              style: TextStyle(
                                  color: Color(0xFF8AABCC), fontSize: 13)),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon:  Icon(Icons.edit_outlined,
                          size: 14, color: Color(0xFF4A9EFF)),
                      label:  Text('Editar perfil',
                          style: TextStyle(
                              color: Color(0xFF4A9EFF), fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        side:  BorderSide(
                            color: Color(0xFF4A9EFF), width: 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding:  EdgeInsets.symmetric(
                            horizontal: 10, vertical: 7),
                      ),
                    ),
                  ],
                ),
              ),

               SizedBox(height: 20),

              
               Text('Seu progresso',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: CardsObj(Icons.auto_awesome_sharp, objetivo, 'Objetivo')),

                   SizedBox(width: 10),

                  Expanded(
                      child: CardsObj(
                  Icons.flash_on_rounded, sequencia.toString(), 'Sequência')),

                   SizedBox(width: 10),

                  Expanded(
                      child: CardsObj(
                          Icons.star_rounded, pontuacao.toString(), 'Pontuação')),
                ],
              ),

               SizedBox(height: 20),

              
               Text('Seu plano',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
               SizedBox(height: 10),

              Container(
                padding:  EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:  Color(0xFF0F2744),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color:  Color(0xFF1E3D5C), width: 0.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor:  Color(0xFF1A3A6A),
                      backgroundImage: AssetImage(image),
                    ),
                     SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(texto,
                              style:  TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                           SizedBox(height: 5),
                          Container(
                            padding:  EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color:  Color(0xFF1E4A8A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child:  Text('Ativo',
                                style: TextStyle(
                                    color: Color(0xFF4A9EFF), fontSize: 11)),
                          ),
                           SizedBox(height: 5),
                           Text('Renovação: 15/07/2026',
                              style: TextStyle(
                                  color: Color(0xFF8AABCC), fontSize: 12)),
                           SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon:  Icon(Icons.credit_card_outlined,
                                size: 14, color: Color(0xFF4A9EFF)),

                            label:  Text('Gerenciar plano',
                                style: TextStyle(
                                    color: Color(0xFF4A9EFF), fontSize: 13)),

                            style: OutlinedButton.styleFrom(
                              side:  BorderSide(
                                  color: Color(0xFF4A9EFF), width:1),

                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),

                              padding:  EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

               SizedBox(height: 12),

             
              Container(
                padding:  EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:  Color(0xFF0F2744),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color:  Color(0xFF1E3D5C), width: 0.5),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor:  Color(0xFF3A1520),
                      child:  Icon(Icons.logout,
                          color: Color(0xFFE05C6A), size: 20),
                    ),
                     SizedBox(width: 14),
                     Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sair da conta',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(height: 2),
                          Text('Encerrar sessão neste dispositivo',
                              style: TextStyle(
                                  color: Color(0xFF8AABCC), fontSize: 12)),
                        ],
                      ),
                    ),
                     Icon(Icons.chevron_right,
                        color: Color(0xFF4A6A8A), size: 22),
                  ],
                ),
              ),

               SizedBox(height: 16),
            ],
          ),
        ),
      ),
      );
  }
}