import 'package:flutter/material.dart';
import 'package:tinker/cadastrologin.dart';

class Thinker extends StatelessWidget {
  const Thinker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1B2E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2A7FC1),
                    ),
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/tinker_images/logo2.png'),
                      backgroundColor: Color(0xFF2A7FC1),
                      radius: 50,
                    ),
                  ),
                  SizedBox(width: 14),
                  Text(
                    'TINKER',
                    style: TextStyle(
                      fontFamily: 'Stardom',
                      fontSize: 60,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 3,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32),

              Text(
                'Estude com mais foco.\nChegue mais longe.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),

              SizedBox(height: 20),

              Text(
                'Questões de vestibular, simulados,\n'
                'desempenho e colaboração\n'
                'com sua turma — tudo em um só lugar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFFB0BEC5),
                  height: 1.6,
                ),
              ),

              SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginCadastro()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3A7BD5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Começar agora',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
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