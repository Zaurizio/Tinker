import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tinker/drawer.dart';
import 'package:tinker/login.dart';
import 'package:tinker/Models/perfil_model.dart';
import 'package:tinker/Models/desempenho_model.dart';
import 'package:tinker/Services/perfil_service.dart';
import 'package:tinker/Services/desempenho_service.dart';
import 'package:tinker/Services/simulado_service.dart';
import 'package:tinker/Services/turma_service.dart';
import 'package:tinker/Services/sessao_atual.dart';
import 'package:tinker/Services/api_client.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  bool carregando = true;
  String? erro;
  PerfilModel? perfil;
  bool enviandoFoto = false;

  // resumo
  DesempenhoResumo? desempenho;
  int? quantidadeSimulados;
  int? quantidadeTurmas;

  @override
  void initState() {
    super.initState();
    _carregarTudo();
  }

  Future<void> _carregarTudo() async {
    setState(() => carregando = true);
    try {
      final dados = await buscarPerfil();
      setState(() => perfil = dados);

      if (SessaoAtual.ehProfessor) {
        final simulados = await buscarSimulados();
        final turmas = await buscarTurmas();
        setState(() {
          quantidadeSimulados = simulados.length;
          quantidadeTurmas = turmas.length;
        });
      } else {
        final resumo = await buscarDesempenho();
        setState(() => desempenho = resumo);
      }

      setState(() => carregando = false);
    } catch (e) {
      setState(() {
        erro = 'Não foi possível carregar seu perfil.';
        carregando = false;
      });
    }
  }

  Future<void> _trocarFoto() async {
    final picker = ImagePicker();
    final XFile? escolhida = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (escolhida == null) return;

    final Uint8List bytes = await escolhida.readAsBytes();

    if (bytes.length > 2 * 1024 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A imagem precisa ter no máximo 2MB.')),
      );
      return;
    }

    setState(() => enviandoFoto = true);
    try {
      final atualizado = await atualizarFotoPerfil(bytes);
      setState(() {
        perfil = atualizado;
        enviandoFoto = false;
      });
    } on ApiException catch (e) {
      setState(() => enviandoFoto = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensagem)));
    } catch (e) {
      setState(() => enviandoFoto = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Erro ao enviar a foto.')));
    }
  }

  void _abrirEditarPerfil() {
    if (perfil == null) return;

    final nomeCtrl = TextEditingController(text: perfil!.nome);
    final sobrenomeCtrl = TextEditingController(text: perfil!.sobrenome);
    DateTime? nascimento = perfil!.nascimento;
    bool salvando = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0F2744),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Editar perfil',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nome', style: TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
              const SizedBox(height: 6),
              _campo(nomeCtrl),
              const SizedBox(height: 14),
              const Text('Sobrenome', style: TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
              const SizedBox(height: 6),
              _campo(sobrenomeCtrl),
              if (perfil!.tipoUsuario == 'ALUNO') ...[
                const SizedBox(height: 14),
                const Text('Nascimento', style: TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final escolhida = await showDatePicker(
                      context: context,
                      initialDate: nascimento ?? DateTime(2005, 1, 1),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                      builder: (context, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                              primary: Color(0xFF3A7BD5), surface: Color(0xFF1A2E45)),
                        ),
                        child: child!,
                      ),
                    );
                    if (escolhida != null) setDialogState(() => nascimento = escolhida);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1B2A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF1E3D5C), width: 0.5),
                    ),
                    child: Text(
                      nascimento == null
                          ? 'Selecionar data'
                          : '${nascimento!.day.toString().padLeft(2, '0')}/${nascimento!.month.toString().padLeft(2, '0')}/${nascimento!.year}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: salvando ? null : () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8AABCC))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A4A8A),
                foregroundColor: const Color(0xFF4A9EFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: salvando
                  ? null
                  : () async {
                      if (nomeCtrl.text.trim().isEmpty || sobrenomeCtrl.text.trim().isEmpty) return;
                      setDialogState(() => salvando = true);
                      try {
                        await atualizarPerfil(
                          nome: nomeCtrl.text.trim(),
                          sobrenome: sobrenomeCtrl.text.trim(),
                          nascimento: nascimento,
                        );
                        if (!mounted) return;
                        Navigator.pop(ctx);
                        _carregarTudo();
                      } on ApiException catch (e) {
                        setDialogState(() => salvando = false);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(e.mensagem)));
                      } catch (e) {
                        setDialogState(() => salvando = false);
                      }
                    },
              child: Text(salvando ? 'Salvando...' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF0D1B2A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1E3D5C), width: 0.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1E3D5C), width: 0.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF4A9EFF), width: 1)),
      ),
    );
  }

  void _sair() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F2744),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Sair da conta', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text('Tem certeza que deseja sair?',
            style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8AABCC))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair', style: TextStyle(color: Color(0xFFE05C6A))),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await SessaoAtual.limpar();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => Login()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      drawer: MeuDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: carregando
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A9EFF)))
            : erro != null
                ? Center(child: Text(erro!, style: const TextStyle(color: Color(0xFFE05C6A))))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Text('Meu perfil',
                            style: TextStyle(
                                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Gerencie suas informações',
                            style: TextStyle(color: Color(0xFF8AABCC), fontSize: 14)),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F2744),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF1E3D5C), width: 0.5),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _avatar(),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(perfil?.nomeCompleto ?? '',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 3),
                                        Text(perfil?.email ?? '',
                                            style: const TextStyle(
                                                color: Color(0xFF8AABCC), fontSize: 13)),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1E4A8A),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                              perfil?.tipoUsuario == 'PROFESSOR'
                                                  ? 'Professor'
                                                  : 'Aluno',
                                              style: const TextStyle(
                                                  color: Color(0xFF4A9EFF), fontSize: 11)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: _abrirEditarPerfil,
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 14, color: Color(0xFF4A9EFF)),
                                    label: const Text('Editar',
                                        style: TextStyle(color: Color(0xFF4A9EFF), fontSize: 13)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFF4A9EFF), width: 1),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 7),
                                    ),
                                  ),
                                ],
                              ),
                              if (perfil?.nascimento != null) ...[
                                const SizedBox(height: 14),
                                const Divider(color: Color(0xFF1E3D5C), height: 1),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    const Icon(Icons.cake_outlined,
                                        color: Color(0xFF8AABCC), size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${perfil!.nascimento!.day.toString().padLeft(2, '0')}/${perfil!.nascimento!.month.toString().padLeft(2, '0')}/${perfil!.nascimento!.year}'
                                      '${perfil!.idade != null ? ' • ${perfil!.idade} anos' : ''}',
                                      style: const TextStyle(
                                          color: Color(0xFF8AABCC), fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _cartaoResumo(),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _sair,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F2744),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF1E3D5C), width: 0.5),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Color(0xFF3A1520),
                                  child: Icon(Icons.logout, color: Color(0xFFE05C6A), size: 20),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Sair da conta',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600)),
                                      SizedBox(height: 2),
                                      Text('Encerrar sessão neste dispositivo',
                                          style:
                                              TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: Color(0xFF4A6A8A), size: 22),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _avatar() {
    Uint8List? bytes;
    if (perfil?.fotoBase64 != null) {
      try {
        bytes = base64Decode(perfil!.fotoBase64!);
      } catch (_) {
        bytes = null;
      }
    }

    return GestureDetector(
      onTap: enviandoFoto ? null : _trocarFoto,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF1A4A7A),
            backgroundImage: bytes != null ? MemoryImage(bytes) : null,
            child: bytes == null
                ? const Icon(Icons.person, color: Colors.white, size: 30)
                : null,
          ),
          if (enviandoFoto)
            const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4A9EFF))
          else
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A4A8A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cartaoResumo() {
    if (SessaoAtual.ehProfessor) {
      return Row(
        children: [
          Expanded(
            child: _numeroResumo(
              icone: Icons.quiz_outlined,
              valor: '${quantidadeSimulados ?? 0}',
              legenda: 'simulados criados',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _numeroResumo(
              icone: Icons.groups_outlined,
              valor: '${quantidadeTurmas ?? 0}',
              legenda: 'turmas',
            ),
          ),
        ],
      );
    }

    if (desempenho == null || desempenho!.questoesRespondidas == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F2744),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E3D5C), width: 0.5),
        ),
        child: const Text('Você ainda não respondeu nenhuma questão.',
            style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _numeroResumo(
            icone: Icons.check_circle_outline,
            valor: '${desempenho!.questoesRespondidas}',
            legenda: 'questões feitas',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _numeroResumo(
            icone: Icons.trending_up_rounded,
            valor: '${desempenho!.percentualGeral}%',
            legenda: 'acerto geral',
          ),
        ),
      ],
    );
  }

  Widget _numeroResumo({required IconData icone, required String valor, required String legenda}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2744),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E3D5C), width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icone, color: const Color(0xFF4A9EFF), size: 22),
          const SizedBox(height: 6),
          Text(valor,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(legenda,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8AABCC), fontSize: 11)),
        ],
      ),
    );
  }
}
