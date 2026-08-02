import 'package:flutter/material.dart';
import 'package:tinker/drawer.dart';

class Info extends StatelessWidget {
  const Info({super.key});

  @override
  Widget build(BuildContext context) {
    final equipe = [
      {
        "nome": "Lucas Gabriel",
        "cargo": "Desenvolvedor Mobile",
        "desc": "Responsável pela interface e experiência do usuário na plataforma mobile.",
        "foto": "assets/images/tinker_images/lucas.jpeg",
      },
      {
        "nome": "Gustavo Zaurizio",
        "cargo": "Desenvolvedor Web Front-End e Desktop",
        "desc": "Responsável pela construção das páginas e componentes do sistema.",
        "foto": "assets/images/tinker_images/zaurizio.jpeg",
      },
      {
        "nome": "Rafael Abrahão",
        "cargo": "Desenvolvedor Desktop, Modelador do Banco de Dados e Back-End",
        "desc": "Responsável pela lógica do sistema, banco de dados e integração de serviços.",
        "foto": "assets/images/tinker_images/rafael.jpeg",
      },
      {
        "nome": "Heitor Prieto",
        "cargo": "Desenvolvedor Mobile e Back-End",
        "desc": "Responsável pelo aplicativo mobile e pela infraestrutura de back-end.",
        "foto": "assets/images/tinker_images/heitor.jpeg",
      },
    ];

    return Scaffold(
      backgroundColor: Color(0xFF0D1B2A),
      drawer: MeuDrawer(),
      appBar: AppBar(
        backgroundColor: Color(0xFF0D1B2A),
         iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),

              
              Row(
                children: [
                  SizedBox(width: 20),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF1A4A7A),
                    child: Image.asset('assets/images/tinker_images/logo2.png'),
                  ),
                  SizedBox(width: 8),
                  Text('TINKER',
                      style: TextStyle(
                          fontFamily: 'Stardom',
                          color: Colors.white,
                          fontSize: 25,
                          letterSpacing: 3)),
                ],
              ),

              SizedBox(height: 28),

            
              Center(
                child: Icon(Icons.info_outline_rounded,
                    color: Colors.white, size: 44),
              ),

              SizedBox(height: 16),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: equipe.map((m) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: Color(0xFF1A4A7A),
                      backgroundImage: AssetImage(m["foto"]!),
                    ),
                  )).toList(),
                ),
              ),

              SizedBox(height: 20),

              
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF0F2744),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Color(0xFF1E3D5C), width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'O Tinker é uma plataforma moderna de estudos voltada para quem se prepara para o vestibular.',
                      style: TextStyle(color: Color(0xFF8AABCC), fontSize: 14, height: 1.6),
                    ),


                    SizedBox(height: 12),


                    Text(
                      'Nosso objetivo é transformar o aprendizado em uma experiência dinâmica, inteligente e envolvente — unindo tecnologia, gamificação e desempenho real.',
                      style: TextStyle(color: Color(0xFF8AABCC), fontSize: 14, height: 1.6),
                    ),


                    SizedBox(height: 12),

                    Text(
                      'No Tinker, o estudante pode organizar seu calendário de estudos, praticar com questões, participar de simulados gamificados e acompanhar sua evolução com métricas claras e motivadoras.',
                      style: TextStyle(color: Color(0xFF8AABCC), fontSize: 14, height: 1.6),
                    ),

                    SizedBox(height: 12),

                    Text(
                      'Tudo foi pensado para ajudar o aluno a estudar com estratégia e constância, tornando a rotina mais produtiva e eficiente.',
                      style: TextStyle(color: Color(0xFF8AABCC), fontSize: 14, height: 1.6),
                    ),

                    SizedBox(height: 12),

                    Text(
                      'O projeto é desenvolvido por uma equipe dedicada de jovens programadores que acreditam no poder da educação e da tecnologia para mudar o futuro.',
                      style: TextStyle(color: Color(0xFF8AABCC), fontSize: 14, height: 1.6),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14),

              Text('EQUIPE',
                  style: TextStyle(
                      color: Color(0xFF8AABCC), fontSize: 11, letterSpacing: 1.2)),
              SizedBox(height: 10),

              ...equipe.map((m) => Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Color(0xFF0F2744),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF1E3D5C), width: 0.5),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFF1A4A7A),
                      backgroundImage: AssetImage(m["foto"]!),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Color(0xFF4A9EFF),
                                  shape: BoxShape.circle,
                                ),
                              ),

                              SizedBox(width: 6),
                              Expanded(
                                child: Text(m["nome"]!,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),

                          SizedBox(height: 2),
                          Text(m["cargo"]!,
                              style: TextStyle(
                                  color: Color(0xFF4A9EFF), fontSize: 11)),

                          SizedBox(height: 4),
                          Text(m["desc"]!,
                              style: TextStyle(
                                  color: Color(0xFF8AABCC), fontSize: 12, height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),

              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}