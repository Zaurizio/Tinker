import 'package:flutter/material.dart';
import 'package:tinker/login.dart';
import 'package:email_validator/email_validator.dart';
import 'package:tinker/Services/auth_service.dart';
import 'package:tinker/Services/api_client.dart';
import 'package:tinker/Services/tipo_usuario.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final GlobalKey<FormState> cadKey = GlobalKey<FormState>();
  final TextEditingController nomeCtrl = TextEditingController();
  final TextEditingController sobrenomeCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController senhaCtrl = TextEditingController();

  TipoUsuario tipoSelecionado = TipoUsuario.aluno;
  DateTime? nascimento;

  bool _senhaVisivel = false;
  bool aceitouTermos = false;
  bool carregando = false;

  Future<void> _escolherNascimento() async {
    final agora = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: DateTime(agora.year - 15, agora.month, agora.day),
      firstDate: DateTime(1950),
      lastDate: agora,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF3A7BD5),
            surface: Color(0xFF1A2E45),
          ),
        ),
        child: child!,
      ),
    );

    if (escolhida != null) {
      setState(() => nascimento = escolhida);
    }
  }

  void _cadastrar() async {
    if (!aceitouTermos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aceite os Termos de Uso para continuar.'),
          backgroundColor: Color(0xFF1A2E45),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (!cadKey.currentState!.validate()) return;

    if (tipoSelecionado == TipoUsuario.aluno && nascimento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Informe sua data de nascimento.')),
      );
      return;
    }

    setState(() => carregando = true);

    try {
      await cadastrar(
        nome: nomeCtrl.text.trim(),
        sobrenome: sobrenomeCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        senha: senhaCtrl.text,
        tipoUsuario: tipoSelecionado,
        nascimento: nascimento,
      );

      if (!mounted) return;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Login()));
    } on ApiException catch (e) {
      setState(() => carregando = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.mensagem)));
    } catch (e) {
      setState(() => carregando = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível conectar ao servidor.')),
      );
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon,
      {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Color(0xFF6B8299)),
      prefixIcon: Icon(icon, color: Color(0xFF6B8299)),
      suffixIcon: suffix,
      filled: true,
      fillColor: Color(0xFF1A2E45),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF3A7BD5), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Widget _campoTexto({
    required String label,
    required TextEditingController controller,
    required IconData icone,
    String? hint,
    TextInputType? tipoTeclado,
    String? Function(String?)? validator,
    Widget? suffix,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Color(0xFFB0BEC5),
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: tipoTeclado,
          obscureText: obscure,
          style: TextStyle(color: Colors.white),
          decoration: _inputDecoration(hint ?? '', icone, suffix: suffix),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1B2E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
              ),
              SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
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
                    fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 6),
              Text(
                'Preencha os dados abaixo para criar sua conta.',
                style: TextStyle(fontSize: 14, color: Color(0xFFB0BEC5)),
              ),
              SizedBox(height: 28),
              Form(
                key: cadKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sou...',
                        style: TextStyle(
                            color: Color(0xFFB0BEC5),
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                    SizedBox(height: 8),
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
                    SizedBox(height: 20),
                    _campoTexto(
                      label: 'Nome',
                      controller: nomeCtrl,
                      icone: Icons.person_outline,
                      hint: 'Digite seu nome',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
                    ),
                    SizedBox(height: 20),
                    _campoTexto(
                      label: 'Sobrenome',
                      controller: sobrenomeCtrl,
                      icone: Icons.person_outline,
                      hint: 'Digite seu sobrenome',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
                    ),
                    SizedBox(height: 20),
                    _campoTexto(
                      label: 'E-mail',
                      controller: emailCtrl,
                      icone: Icons.email_outlined,
                      hint: 'Digite seu e-mail',
                      tipoTeclado: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
                        if (!EmailValidator.validate(v.trim())) return 'E-mail inválido';
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    _campoTexto(
                      label: 'Senha',
                      controller: senhaCtrl,
                      icone: Icons.lock_outline,
                      hint: 'Digite sua senha',
                      obscure: !_senhaVisivel,
                      suffix: IconButton(
                        icon: Icon(
                          _senhaVisivel
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Color(0xFF6B8299),
                        ),
                        onPressed: () =>
                            setState(() => _senhaVisivel = !_senhaVisivel),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'A senha é obrigatória';
                        if (v.length < 6) return 'Use pelo menos 6 caracteres';
                        return null;
                      },
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Use pelo menos 6 caracteres com letras e números.',
                      style: TextStyle(color: Color(0xFF6B8299), fontSize: 12),
                    ),
                    if (tipoSelecionado == TipoUsuario.aluno) ...[
                      SizedBox(height: 20),
                      Text('Data de nascimento',
                          style: TextStyle(
                              color: Color(0xFFB0BEC5),
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: _escolherNascimento,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: Color(0xFF1A2E45),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.cake_outlined, color: Color(0xFF6B8299)),
                              SizedBox(width: 10),
                              Text(
                                nascimento == null
                                    ? 'Selecionar data'
                                    : '${nascimento!.day.toString().padLeft(2, '0')}/${nascimento!.month.toString().padLeft(2, '0')}/${nascimento!.year}',
                                style: TextStyle(
                                    color: nascimento == null
                                        ? Color(0xFF6B8299)
                                        : Colors.white,
                                    fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                            activeColor: Color(0xFF3A7BD5),
                            checkColor: Colors.white,
                            side: BorderSide(color: Color(0xFF3A5A80), width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'Eu concordo com os ',
                              style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 13),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Text(
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
                                    child: Text(
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
                        onPressed: carregando ? null : _cadastrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3A7BD5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: carregando
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
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
                          style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Login())),
                          child: Text(
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
