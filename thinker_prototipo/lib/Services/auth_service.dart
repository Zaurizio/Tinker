import 'package:tinker/Services/api_client.dart';
import 'package:tinker/Services/sessao_atual.dart';
import 'package:tinker/Services/tipo_usuario.dart';

Future<void> fazerLogin({
  required String email,
  required String senha,
  required TipoUsuario tipoUsuario,
}) async {
  final dados = await apiPost(
    '/auth/login',
    {
      'email': email,
      'senha': senha,
      'tipoUsuario': tipoUsuario.valorApi,
    },
    comAuth: false,
  );

  SessaoAtual.token = dados['token'] as String;
  SessaoAtual.emailLogado = dados['email'] as String;
  SessaoAtual.nomeLogado = dados['nome'] as String?;
  SessaoAtual.sobrenomeLogado = dados['sobrenome'] as String?;
  SessaoAtual.tipoUsuario = TipoUsuarioApi.fromApi(dados['tipoUsuario'] as String);

  await SessaoAtual.salvar();
}

Future<void> cadastrar({
  required String nome,
  required String sobrenome,
  required String email,
  required String senha,
  required TipoUsuario tipoUsuario,
  DateTime? nascimento,
}) async {
  await apiPost(
    '/auth/cadastros',
    {
      'nome': nome,
      'sobrenome': sobrenome,
      'email': email,
      'senha': senha,
      'tipoUsuario': tipoUsuario.valorApi,
      if (nascimento != null)
        'nascimento':
            '${nascimento.year.toString().padLeft(4, '0')}-${nascimento.month.toString().padLeft(2, '0')}-${nascimento.day.toString().padLeft(2, '0')}',
    },
    comAuth: false,
  );
}
