import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinker/Services/tipo_usuario.dart';

class SessaoAtual {
  static String? token;
  static String emailLogado = '';
  static String? nomeLogado;
  static String? sobrenomeLogado;
  static TipoUsuario? tipoUsuario;

  static bool get logado => token != null;

  static bool get ehProfessor => tipoUsuario == TipoUsuario.professor;

  static Future<void> salvar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token ?? '');
    await prefs.setString('email', emailLogado);
    await prefs.setString('nome', nomeLogado ?? '');
    await prefs.setString('sobrenome', sobrenomeLogado ?? '');
    await prefs.setString('tipoUsuario', tipoUsuario?.valorApi ?? '');
  }

  /// Tenta restaurar a sessão salva. Devolve true se havia uma sessão válida.
  static Future<bool> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenSalvo = prefs.getString('token');

    if (tokenSalvo == null || tokenSalvo.isEmpty) return false;

    token = tokenSalvo;
    emailLogado = prefs.getString('email') ?? '';
    nomeLogado = prefs.getString('nome');
    sobrenomeLogado = prefs.getString('sobrenome');
    final tipoSalvo = prefs.getString('tipoUsuario') ?? '';
    tipoUsuario = tipoSalvo.isEmpty ? null : TipoUsuarioApi.fromApi(tipoSalvo);

    return true;
  }

  static Future<void> limpar() async {
    token = null;
    emailLogado = '';
    nomeLogado = null;
    sobrenomeLogado = null;
    tipoUsuario = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
