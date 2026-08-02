import 'package:flutter/material.dart';
import 'package:tinker/Classes/usuariosCadastro.dart';
import 'package:tinker/login.dart';
import 'package:email_validator/email_validator.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final GlobalKey<FormState> cadKey = GlobalKey<FormState>();
  final TextEditingController campoController1 = TextEditingController(); // nome
  final TextEditingController campoController2 = TextEditingController(); // email
  final TextEditingController campoController3 = TextEditingController(); // senha

  bool _senhaVisivel = false;
  bool aceitouTermos = false;

  void _cadastrar() {
    if (!aceitouTermos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:  Text('Aceite os Termos de Uso para continuar.'),
          backgroundColor:  Color(0xFF1A2E45),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (cadKey.currentState!.validate()) {
      final novoUsuario = Usuarioscadastro(
        campoController1.text,
        campoController3.text.trim(),
        campoController2.text,
      );
      cadastros.add(novoUsuario);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Login()));
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon,
      {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle:  TextStyle(color: Color(0xFF6B8299)),
      prefixIcon: Icon(icon, color: Color(0xFF6B8299)),
      suffixIcon: suffix,
      filled: true,
      fillColor:  Color(0xFF1A2E45),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
             BorderSide(color: Color(0xFF3A7BD5), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
             BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFF0D1B2E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:  EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),

             
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon:  Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
              ),

               SizedBox(height: 16),

             
              Center(
                child: Column(
                  children:  [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: Color(0xFF2A7FC1),
                      backgroundImage:
                          AssetImage('assets/images/tinker_images/logo2.png'),
                    ),
                    SizedBox(height: 14),
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
                  ],
                ),
              ),

               SizedBox(height: 32),

              
               Text(
                'Criar conta',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
               SizedBox(height: 6),
               Text(
                'Preencha os dados abaixo para criar sua conta.',
                style:
                    TextStyle(fontSize: 14, color: Color(0xFFB0BEC5)),
              ),

               SizedBox(height: 28),

           
              Form(
                key: cadKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome
                    Text('Nome completo',
                        style: TextStyle(
                            color: Color(0xFFB0BEC5),
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                     SizedBox(height: 8),
                    TextFormField(
                      controller: campoController1,
                      style:  TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                          'Digite seu nome completo', Icons.person_outline),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                    ),

                     SizedBox(height: 20),

                    
                    Text('E-mail',
                        style: TextStyle(
                            color: Color(0xFFB0BEC5),
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: campoController2,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                          'Digite seu e-mail', Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Campo obrigatório';
                        }
                        if (!EmailValidator.validate(value.trim())) {
                          return 'E-mail inválido';
                        }
                        return null;
                      },
                    ),

                     SizedBox(height: 20),

                    // Senha
                    Text('Senha',
                        style: TextStyle(
                            color: Color(0xFFB0BEC5),
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                     SizedBox(height: 8),
                    TextFormField(
                      controller: campoController3,
                      obscureText: !_senhaVisivel,
                      style:  TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                        'Digite sua senha',
                        Icons.lock_outline,
                        suffix: IconButton(
                          icon: Icon(
                            _senhaVisivel
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color:  Color(0xFF6B8299),
                          ),
                          onPressed: () => setState(
                              () => _senhaVisivel = !_senhaVisivel),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'A senha é obrigatória';
                        }
                        if (value.length < 6) {
                          return 'Use pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                     SizedBox(height: 6),
                     Text(
                      'Use pelo menos 6 caracteres com letras e números.',
                      style: TextStyle(
                          color: Color(0xFF6B8299), fontSize: 12),
                    ),

                    SizedBox(height: 24),

                
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: aceitouTermos,
                            onChanged: (value) =>
                                setState(() => aceitouTermos = value ?? false),
                            activeColor:  Color(0xFF3A7BD5),
                            checkColor: Colors.white,
                            side:  BorderSide(
                                color: Color(0xFF3A5A80), width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                         SizedBox(width: 10),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'Eu concordo com os ',
                              style: TextStyle(
                                  color: Color(0xFFB0BEC5), fontSize: 13),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () {},
                                    child:  Text(
                                      'Termos de Uso',
                                      style: TextStyle(
                                          color: Color(0xFF4A90D9),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                                 TextSpan(text: ' e '),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () {},
                                    child:  Text(
                                      'Política de Privacidade',
                                      style: TextStyle(
                                          color: Color(0xFF4A90D9),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                     SizedBox(height: 28),

                    
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _cadastrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  Color(0xFF3A7BD5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child:  Text(
                          'Criar conta',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Text(
                          'Já tem uma conta? ',
                          style: TextStyle(
                              color: Color(0xFFB0BEC5), fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push( context,MaterialPageRoute(builder: (context) => Login())),
                          child:  Text(
                            'Entrar',
                            style: TextStyle(
                              color: Color(0xFF4A90D9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}