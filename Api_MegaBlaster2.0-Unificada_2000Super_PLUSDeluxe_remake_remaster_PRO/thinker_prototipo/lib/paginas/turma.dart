import 'package:flutter/material.dart';
import 'package:tinker/Models/turma_model.dart';
import 'package:tinker/Services/turma_service.dart';
import 'package:tinker/Services/api_client.dart';
import 'package:tinker/Services/sessao_atual.dart';
import 'package:tinker/paginas/turma_detalhes.dart';

const List<Color> coresAvatarTurma = [
  Color(0xFF2C7AA9),
  Color(0xFF1F9C7A),
  Color(0xFF3A5BA9),
  Color(0xFF7A4AA9),
  Color(0xFFA9682C),
];

Color corDaTurma(String codigo) =>
    coresAvatarTurma[codigo.hashCode.abs() % coresAvatarTurma.length];

class Turma extends StatefulWidget {
  const Turma({super.key});

  @override
  State<Turma> createState() => _TurmaState();
}

class _TurmaState extends State<Turma> {
  final buscaCtrl = TextEditingController();

  bool carregando = true;
  String? erro;
  List<TurmaModel> minhasTurmas = [];
  List<TurmaModel> turmasFiltradas = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => carregando = true);

    try {
      final turmas = await buscarTurmas();
      setState(() {
        minhasTurmas = turmas;
        turmasFiltradas = List.from(turmas);
        carregando = false;
      });
    } catch (e) {
      setState(() {
        erro = 'Não foi possível carregar suas turmas.';
        carregando = false;
      });
    }
  }

  void filtrar(String texto) {
    setState(() {
      if (texto.isEmpty) {
        turmasFiltradas = List.from(minhasTurmas);
      } else {
        turmasFiltradas = minhasTurmas
            .where((t) => t.nome.toLowerCase().contains(texto.toLowerCase()))
            .toList();
      }
    });
  }

  void _abrirCriarTurma() {
    final nomeCtrl = TextEditingController();
    bool salvando = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0F2744),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Criar turma',
              style:
                  TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dê um nome para a sua turma. Um código de 8 dígitos será gerado automaticamente.',
                style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13),
              ),
              const SizedBox(height: 14),
              _campoDialogo(nomeCtrl, 'Nome da turma'),
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
                      if (nomeCtrl.text.trim().isEmpty) return;
                      setDialogState(() => salvando = true);

                      try {
                        final criada = await criarTurma(nomeCtrl.text.trim());
                        if (!mounted) return;
                        Navigator.pop(ctx);
                        await _carregarDados();

                        if (!mounted) return;
                        showDialog(
                          context: context,
                          builder: (ctx2) => AlertDialog(
                            backgroundColor: const Color(0xFF0F2744),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            title: const Text('Turma criada!',
                                style: TextStyle(color: Colors.white, fontSize: 16)),
                            content: Text(
                              'Compartilhe esse código com os alunos:\n\n${criada.codigo}',
                              style: const TextStyle(color: Color(0xFF8AABCC), fontSize: 14),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx2),
                                child: const Text('Fechar',
                                    style: TextStyle(color: Color(0xFF4A9EFF))),
                              ),
                            ],
                          ),
                        );
                      } on ApiException catch (e) {
                        setDialogState(() => salvando = false);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(e.mensagem)));
                      } catch (e) {
                        setDialogState(() => salvando = false);
                      }
                    },
              child: Text(salvando ? 'Criando...' : 'Criar'),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirEntrarTurma() {
    final codigoCtrl = TextEditingController();
    bool entrando = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0F2744),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Entrar em turma',
              style:
                  TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Digite o código de 8 dígitos compartilhado pelo professor.',
                style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13),
              ),
              const SizedBox(height: 14),
              _campoDialogo(codigoCtrl, 'Código da turma',
                  tipoTeclado: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(
              onPressed: entrando ? null : () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8AABCC))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A4A8A),
                foregroundColor: const Color(0xFF4A9EFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: entrando
                  ? null
                  : () async {
                      final codigo = codigoCtrl.text.trim();
                      if (!RegExp(r'^[0-9]{8}$').hasMatch(codigo)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('O código deve ter exatamente 8 dígitos.')),
                        );
                        return;
                      }

                      setDialogState(() => entrando = true);

                      try {
                        await entrarNaTurma(codigo);
                        if (!mounted) return;
                        Navigator.pop(ctx);
                        _carregarDados();
                      } on ApiException catch (e) {
                        setDialogState(() => entrando = false);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(e.mensagem)));
                      } catch (e) {
                        setDialogState(() => entrando = false);
                      }
                    },
              child: Text(entrando ? 'Entrando...' : 'Entrar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoDialogo(TextEditingController ctrl, String hint,
      {TextInputType? tipoTeclado}) {
    return TextField(
      controller: ctrl,
      keyboardType: tipoTeclado,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF4A6A8A), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFF0D1B2A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1E3D5C), width: 2)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1E3D5C), width: 2)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF4A9EFF), width: 2)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ehProfessor = SessaoAtual.ehProfessor;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0F2744),
                        border: Border.all(color: const Color(0xFF1E3D5C), width: 1),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 20),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF1A4A7A),
                    child: Image.asset('assets/images/tinker_images/logo2.png'),
                  ),
                  const SizedBox(width: 8),
                  const Text('TINKER',
                      style: TextStyle(
                          fontFamily: 'Stardom',
                          color: Colors.white,
                          fontSize: 25,
                          letterSpacing: 3)),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Minhas Turmas',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(
                controller: buscaCtrl,
                onChanged: filtrar,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Pesquisar turma...',
                  hintStyle: const TextStyle(color: Color(0xFF4A6A8A), fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF4A6A8A), size: 20),
                  filled: true,
                  fillColor: const Color(0xFF0F2744),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF1E3D5C), width: 2)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF1E3D5C), width: 2)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF4A9EFF), width: 2)),
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: ehProfessor ? _abrirCriarTurma : _abrirEntrarTurma,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A4A8A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(ehProfessor ? 'Criar turma' : 'Entrar em turma',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 20),
              if (carregando)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF4A9EFF))),
                )
              else if (erro != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                      child: Text(erro!, style: const TextStyle(color: Color(0xFFE05C6A), fontSize: 13))),
                )
              else if (turmasFiltradas.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const Icon(Icons.group_outlined, color: Color(0xFF4A6A8A), size: 40),
                        const SizedBox(height: 12),
                        Text(
                            ehProfessor
                                ? 'Você ainda não criou nenhuma turma.'
                                : 'Você ainda não está em nenhuma turma.',
                            style: const TextStyle(color: Color(0xFF4A6A8A), fontSize: 14)),
                      ],
                    ),
                  ),
                )
              else
                ...turmasFiltradas.map(
                  (t) => GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TurmaDetalhes(turma: t)),
                      ).then((_) => _carregarDados());
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F2744),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1E3D5C), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: corDaTurma(t.codigo),
                            child: const Icon(Icons.groups_rounded, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.nome,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 3),
                                Text('Prof. ${t.criadorNome}',
                                    style: const TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
