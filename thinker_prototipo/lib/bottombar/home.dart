import 'package:flutter/material.dart';
import 'package:tinker/paginas/calendario.dart';
import 'package:tinker/paginas/desempenho.dart';
import 'package:tinker/paginas/questoes.dart';
import 'package:tinker/paginas/simulado.dart';
import 'package:tinker/paginas/turma.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget cardMateria({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String description,
  required VoidCallback onTap,
  bool wide = false,
}) {
  final iconWidget = CircleAvatar(
    radius: 23,
    backgroundColor: iconColor,
    child: Icon(icon, color: Colors.white, size: 22),
  );

  final textSection = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,
          style:  TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
       SizedBox(height: 4),
      Text(description,
          style:  TextStyle(color: Color(0xFF7A9AB8), fontSize: 14)),
       SizedBox(height: 10),
      Icon(Icons.arrow_forward_ios_rounded, color:Color.fromARGB(255, 43, 117, 201),size: 14,)
    ],
  );

  return InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap,
    child: Container(
      padding: wide
          ?  EdgeInsets.all(16)
          :  EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        color:  Color(0xFF0F2744),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color:  Color(0xFF1E3D5C), width: 0.5),
      ),
      child: wide
          ? Row(children: [
              iconWidget,
               SizedBox(width: 14),
              Expanded(child: textSection),
            ])
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconWidget,
                 SizedBox(height: 12),
                textSection,
              ],
            ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFF0D1B2A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:  EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               SizedBox(height: 16),

             
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor:  Color(0xFF1A4A7A),
                    child: Image.asset('assets/images/tinker_images/logo2.png', ),
                  ),
                   SizedBox(width: 12),
                   Text(
                    'TINKER',
                    style: TextStyle(
                      fontFamily: 'Stardom',
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              
             Text(
                'Olá, estudante!',
               style: TextStyle(
                  fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white70
              ),
              ),
          SizedBox(height: 4),
              Text(
          'Pronto para mais um dia de estudos?',
              style: TextStyle(color: Color(0xFF8AABCC), fontSize: 14),
              ),

             SizedBox(height: 24),
        Text(
                'Escolha uma área',
                style: TextStyle(
                  color: Colors.white,
                fontSize: 15,
                  fontWeight: FontWeight.w600,
               ),
             ),
          SizedBox(height: 12),

             
              Row(
                children: [
                  Expanded(
                    child: cardMateria(
                      icon: Icons.description_outlined,
            iconColor:  Color(0xFF2563EB),
                      title: 'Questões',
                      description: 'Pratique com milhares de questões',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => Questoes())),
                    ),
                  ),
                   SizedBox(width: 12),
                  Expanded(
                    child: cardMateria(
                      icon: Icons.assignment_outlined,
                      iconColor:  Color(0xFF16A34A),
                      title: 'Simulados',
                      description: 'Faça simulados personalizados',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) =>  Simulado())),
                    ),
                  ),
                ],
              ),

               SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: cardMateria(
                      icon: Icons.calendar_month_outlined,
                      iconColor:  Color(0xFF7C3AED),
                      title: 'Calendário',
                      description: 'Organize seus estudos e datas',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => Calendario())),
                    ),
                  ),
                   SizedBox(width: 12),
                  Expanded(
                    child: cardMateria(
                      icon: Icons.group_outlined,
                      iconColor:  Color(0xFFEA580C),
                      title: 'Turma',
                      description: 'Acompanhe sua turma e atividades',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) =>Turma())),
                    ),
                  ),
                ],
              ),

             SizedBox(height: 12),

             
              cardMateria(
                icon: Icons.bar_chart_outlined,
                iconColor:  Color(0xFF0D9488),
                title: 'Desempenho',
                description: 'Acompanhe seu progresso e evolução',
                wide: true,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) =>  Desempenho())),
              ),

               SizedBox(height: 16),
            ],
          ),
        ),
      ),
          
            );
            
  }
}
