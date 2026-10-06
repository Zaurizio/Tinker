import 'package:flutter/material.dart';
import 'package:tinker/cadastro.dart';
import 'package:tinker/homepage.dart';
import 'package:email_validator/email_validator.dart';
import 'package:tinker/Services/auth_service.dart';
import 'package:tinker/Services/api_client.dart';
import 'package:tinker/Services/tipo_usuario.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _senhaVisivel = false;
  TipoUsuario tipoSelecionado = TipoUsuario.aluno;
  final GlobalKey<FormState> logKey = GlobalKey<FormState>();
  final TextEditingController campoController1 = TextEditingController();
  final TextEditingController campoController2 = TextEditingController();

  void _erroLogin(String mensagem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:  Color(0xFF1A2E45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title:  Icon(Icons.error_outline_rounded,
            color: Color(0xFF4A90D9), size: 40),
        content:  Text(
          mensagem,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor:  Color(0xFF3A7BD5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                   EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child:  Text('OK',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  bool carregando = false;

  void _fazerLogin() async {
    if (!logKey.currentState!.validate()) return;

    setState(() => carregando = true);

    try {
      await fazerLogin(
        email: campoController1.text.trim(),
        senha: campoController2.text,
        tipoUsuario: tipoSelecionado,
      );

      if (!mounted) return;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Homepage()));
    } on ApiException catch (e) {
      setState(() => carregando = false);
      if (e.statusCode == 401) {
        _erroLogin(e.mensagem);
      } else {
        _erroLogin('Não foi possível entrar. Tente novamente.');
      }
    } catch (e) {
      setState(() => carregando = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível conectar ao servidor.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFF0D1B2E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              SizedBox(height: 48),

              
               CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFF2A7FC1),
                backgroundImage: AssetImage('assets/images/tinker_images/logo2.png'),
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

               SizedBox(height: 40),

              
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Entrar',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 6),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Bem-vindo de volta!',
                  style: TextStyle(fontSize: 14, color: Color(0xFFB0BEC5)),
                ),
              ),

               SizedBox(height: 40),

             
              Form(
                key: logKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => tipoSelecionado = TipoUsuario.aluno),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: tipoSelecionado == TipoUsuario.aluno
                                    ? Color(0xFF3A7BD5)
                                    : Color(0xFF1A2E45),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('Aluno',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                                () => tipoSelecionado = TipoUsuario.professor),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: tipoSelecionado == TipoUsuario.professor
                                    ? Color(0xFF3A7BD5)
                                    : Color(0xFF1A2E45),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('Professor',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 28),

                     Text(
                      'E-mail',
                      style: TextStyle(
                          color: Color(0xFFB0BEC5),
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: campoController1,
                      keyboardType: TextInputType.emailAddress,
                      style:  TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'usuario@gmail.com',
                        hintStyle:
                             TextStyle(color: Color(0xFF6B8299)),
                        prefixIcon:  Icon(Icons.email_outlined,
                            color: Color(0xFF6B8299)),
                        filled: true,
                        fillColor:  Color(0xFF1A2E45),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Color(0xFF3A7BD5), width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Colors.redAccent, width: 1.5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:  BorderSide(
                              color: Colors.redAccent, width: 1.5),
                        ),
                      ),
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

                    SizedBox(height: 35),

                    
                    Text(
                      'Senha',
                      style: TextStyle(
                          color: Color(0xFFB0BEC5),
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                     SizedBox(height: 8),
                    TextFormField(
                      controller: campoController2,
                      obscureText: !_senhaVisivel,
                      style:  TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Insira sua senha',
                        hintStyle:
                             TextStyle(color: Color(0xFF6B8299)),
                        prefixIcon:  Icon(Icons.lock_outline,
                            color: Color(0xFF6B8299)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _senhaVisivel
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color:  Color(0xFF6B8299),
                          ),
                          onPressed: () =>
                              setState(() => _senhaVisivel = !_senhaVisivel),
                        ),
                        filled: true,
                        fillColor:  Color(0xFF1A2E45),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:  BorderSide(
                              color: Color(0xFF3A7BD5), width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:  BorderSide(
                              color: Colors.redAccent, width: 1.5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:  BorderSide(
                              color: Colors.redAccent, width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'A senha é obrigatória';
                        }
                        return null;
                      },
                    ),

                     SizedBox(height: 120),

                  
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: carregando ? null : _fazerLogin,
                        icon: carregando
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Icon(Icons.login_rounded, color: Colors.white),
                        label: Text(
                          carregando ? 'Entrando...' : 'Entrar',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  Color(0xFF3A7BD5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),

                     SizedBox(height: 24),

                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Text(
                          'Não tem uma conta? ',
                          style: TextStyle(
                              color: Color(0xFFB0BEC5), fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Cadastro())),
                          child:  Text(
                            'Cadastre-se',
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