import 'package:flutter/material.dart';
import 'package:tinker/cadastro.dart';
import 'package:tinker/login.dart';

class LoginCadastro extends StatelessWidget {
  const LoginCadastro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFF0D1B2E),
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              Spacer(flex: 1),

             
               CircleAvatar(
                radius: 70,
                backgroundColor: Color(0xFF2A7FC1),
                backgroundImage: AssetImage('assets/images/tinker_images/logo2.png'),
              ),

              SizedBox(height: 20),

              
               Text(
                'TINKER',
                style: TextStyle(
                  fontFamily: 'Stardom',
                  fontSize: 48,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
              ),

               Spacer(flex: 1),

         
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

              SizedBox(height: 18),

        
               Text(
                'Questões de vestibular, simulados,\n'
                'desempenho e colaboração com sua\n'
                'turma — tudo em um só lugar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFFB0BEC5),
                  height: 1.6,
                ),
              ),

               Spacer(flex: 2),

           
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                     Navigator.push(context,
                       MaterialPageRoute(builder: (context) => Login()));
                  },
                  icon: Icon(Icons.login_rounded, color: Colors.white),
                  label:  Text(
                    'Entrar',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  Color(0xFF3A7BD5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

               SizedBox(height: 14),

              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(context,
                         MaterialPageRoute(builder: (context) => Cadastro()));
                  },
                  icon:  Icon(Icons.person_add_outlined, color: Colors.white),
                  label:  Text(
                    'Criar conta',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side:  BorderSide(color: Color(0xFF3A5A80), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

               SizedBox(height: 28),

             
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Já tem uma conta? ',
                    style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                       Navigator.push(context,
                         MaterialPageRoute(builder: (context) => Login()));
                    },
                    child:  Text(
                      'Faça login',
                      style: TextStyle(
                        color: Color(0xFF4A90D9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

               SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}