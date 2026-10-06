import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tinker/Services/api_config.dart';
import 'package:tinker/Services/sessao_atual.dart';
import 'package:tinker/main.dart';
import 'package:tinker/login.dart';

class ApiException implements Exception {
  final int statusCode;
  final String codigo;
  final String mensagem;
  final Map<String, dynamic>? campos;

  ApiException({
    required this.statusCode,
    required this.codigo,
    required this.mensagem,
    this.campos,
  });

  @override
  String toString() => mensagem;
}

Map<String, String> _cabecalhos({bool comAuth = true}) {
  final headers = {'Content-Type': 'application/json'};
  if (comAuth && SessaoAtual.token != null) {
    headers['Authorization'] = 'Bearer ${SessaoAtual.token}';
  }
  return headers;
}

dynamic _tratarResposta(http.Response resposta) {
  if (resposta.statusCode >= 200 && resposta.statusCode < 300) {
    if (resposta.bodyBytes.isEmpty) return null;
    return jsonDecode(utf8.decode(resposta.bodyBytes));
  }

  String codigo = 'ERRO';
  String mensagem = 'Erro ${resposta.statusCode}';
  Map<String, dynamic>? campos;

  try {
    final corpo = jsonDecode(utf8.decode(resposta.bodyBytes));
    if (corpo is Map) {
      codigo = (corpo['codigo'] ?? codigo).toString();
      mensagem = (corpo['mensagem'] ?? mensagem).toString();
      if (corpo['campos'] is Map) {
        campos = Map<String, dynamic>.from(corpo['campos']);
      }
    }
  } catch (_) {
    // corpo não veio em JSON; mantém a mensagem genérica
  }

  if (resposta.statusCode == 401 && SessaoAtual.token != null) {
    _forcarLogout();
  }

  throw ApiException(
    statusCode: resposta.statusCode,
    codigo: codigo,
    mensagem: mensagem,
    campos: campos,
  );
}

bool _redirecionandoParaLogin = false;

void _forcarLogout() {
  if (_redirecionandoParaLogin) return;
  _redirecionandoParaLogin = true;

  SessaoAtual.limpar().then((_) {
    final navegador = navigatorKey.currentState;
    if (navegador == null) {
      _redirecionandoParaLogin = false;
      return;
    }

    navegador.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => Login()),
      (route) => false,
    );

    Future.delayed(const Duration(seconds: 1), () {
      _redirecionandoParaLogin = false;
    });
  });
}

Future<dynamic> apiGet(String caminho) async {
  final resposta = await http.get(
    Uri.parse('${ApiConfig.baseUrl}$caminho'),
    headers: _cabecalhos(),
  );
  return _tratarResposta(resposta);
}

Future<dynamic> apiPost(String caminho, Map<String, dynamic> corpo,
    {bool comAuth = true}) async {
  final resposta = await http.post(
    Uri.parse('${ApiConfig.baseUrl}$caminho'),
    headers: _cabecalhos(comAuth: comAuth),
    body: jsonEncode(corpo),
  );
  return _tratarResposta(resposta);
}

Future<dynamic> apiPut(String caminho, Map<String, dynamic> corpo) async {
  final resposta = await http.put(
    Uri.parse('${ApiConfig.baseUrl}$caminho'),
    headers: _cabecalhos(),
    body: jsonEncode(corpo),
  );
  return _tratarResposta(resposta);
}

Future<dynamic> apiPatch(String caminho, Map<String, dynamic> corpo) async {
  final resposta = await http.patch(
    Uri.parse('${ApiConfig.baseUrl}$caminho'),
    headers: _cabecalhos(),
    body: jsonEncode(corpo),
  );
  return _tratarResposta(resposta);
}

Future<void> apiDelete(String caminho) async {
  final resposta = await http.delete(
    Uri.parse('${ApiConfig.baseUrl}$caminho'),
    headers: _cabecalhos(),
  );
  _tratarResposta(resposta);
}
