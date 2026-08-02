import 'package:flutter/material.dart';
import 'package:tinker/bottombar/perfil.dart';
import 'package:tinker/telasDrawer/planos.dart';
import 'package:tinker/telasDrawer/info.dart';
import 'package:tinker/telasDrawer/contato.dart';

class MeuDrawer extends StatelessWidget {
  const MeuDrawer({super.key});

  Widget ItensDrawer({
    required BuildContext context,
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Divider(
          color: Color(0xFF1E3D5C),
          thickness: 0.8,
          height: 1,
          indent: 20,
          endIndent: 20,
        ),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor:  Color(0xFF1A3A6A),
                  child: Icon(icone, color: Colors.white, size: 22),
                ),
                 SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                       SizedBox(height: 3),
                      Text(subtitulo,
                          style:  TextStyle(
                              color: Color(0xFF8AABCC), fontSize: 12)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: Color(0xFF8AABCC), size: 14),
              ],
            ),
          ),
        ),
         Divider(
          color: Color(0xFF1E3D5C),
          thickness: 0.8,
          height: 1,
          indent: 20,
          endIndent: 20,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor:  Color(0xFF0D1B2A),
      width: 300,
      child: SafeArea(
        child: Column(
          children: [
           
            Padding(
              padding:  EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor:  Color(0xFF1A4A7A),
                    backgroundImage: AssetImage(fotoUser),
                  ),
                   SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nomeUser,
                          style:  TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold)),
                       SizedBox(height: 4),   
                    ]
                  ),
                ],
              ),
            ),

             SizedBox(height: 50),

             

          
            ItensDrawer(
              context: context,
              icone: Icons.trending_up_rounded,
              titulo: 'Faça o upgrade',
              subtitulo: 'Tenha acesso a conteúdos\nexclusivos e mais recursos.',
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) =>  Planos())),
            ),


            
            


            SizedBox(height: 50,),
            
            
            ItensDrawer(
              context: context,
              icone: Icons.message_rounded,
              titulo: 'Fale conosco',
              subtitulo: 'Envie dúvidas, sugestões\ne feedbacks.',
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) =>  Contato())),
            ),
            
            
             SizedBox(height: 50,),
              
            ItensDrawer(
              context: context,
              icone: Icons.info_outline_rounded,
              titulo: 'Sobre',
              subtitulo: 'Conheça mais sobre o Tinker\ne nossa equipe.',
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) =>  Info())),
            ),

            
             Spacer(),

           
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/homepage'),
                  icon:  Icon(Icons.home_rounded,
                      color: Colors.white, size: 20),
                  label:  Text('Voltar para a home',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1A3A6A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ),

             SizedBox(height: 16),

           
             Text('Versão 0.0.0.012',
                style: TextStyle(color: Color(0x33FFFFFF), fontSize: 12)),

             SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}