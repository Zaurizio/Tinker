import 'dart:convert';
import 'package:tinker/Services/api_client.dart';
import 'package:tinker/Models/perfil_model.dart';

Future<PerfilModel> buscarPerfil() async {
  final dados = await apiGet('/me');
  return PerfilModel.fromApi(dados);
}

Future<PerfilModel> atualizarPerfil({
  required String nome,
  required String sobrenome,
  DateTime? nascimento,
}) async {
  final dados = await apiPut('/me', {
    'nome': nome,
    'sobrenome': sobrenome,
    if (nascimento != null)
      'nascimento':
          '${nascimento.year.toString().padLeft(4, '0')}-${nascimento.month.toString().padLeft(2, '0')}-${nascimento.day.toString().padLeft(2, '0')}',
  });
  return PerfilModel.fromApi(dados);
}

Future<PerfilModel> atualizarFotoPerfil(List<int> bytes) async {
  final dados = await apiPut('/me/foto', {
    'foto': base64Encode(bytes),
  });
  return PerfilModel.fromApi(dados);
}

Future<void> alterarSenha({
  required String senhaAtual,
  required String novaSenha,
}) async {
  await apiPut('/me/senha', {
    'senhaAtual': senhaAtual,
    'novaSenha': novaSenha,
  });
}

Future<void> inativarConta() async {
  await apiDelete('/me');
}
