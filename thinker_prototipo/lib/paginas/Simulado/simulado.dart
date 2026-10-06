import 'package:flutter/material.dart';
import 'package:tinker/Models/simulado_model.dart';
import 'package:tinker/Services/simulado_service.dart';
import 'package:tinker/Services/api_client.dart';
import 'simulado_detalhes.dart';

class Simulado extends StatefulWidget {
  const Simulado({super.key});

  @override
  State<Simulado> createState() => _SimuladoState();
}

class _SimuladoState extends State<Simulado> {
  final buscaCtrl = TextEditingController();

  bool carregando = true;
  String? erro;
  List<SimuladoResumo> todos = [];
  List<SimuladoResumo> filtrados = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => carregando = true);

    try {
      final lista = await buscarSimulados();
      setState(() {
        todos = lista;
        filtrados = List.from(lista);
        carregando = false;
      });
    } catch (e) {
      setState(() {
        erro = 'Não foi possível carregar seus simulados.';
        carregando = false;
      });
    }
  }

  void filtrar(String texto) {
    setState(() {
      filtrados = texto.isEmpty
          ? List.from(todos)
          : todos.where((s) => s.titulo.toLowerCase().contains(texto.toLowerCase())).toList();
    });
  }

  void _criarSimuladoDialog() {
    final tituloCtrl = TextEditingController();
    final descricaoCtrl = TextEditingController();
    bool salvando = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0F2744),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Novo simulado',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Título', style: TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
              const SizedBox(height: 6),
              _campo(tituloCtrl, 'Ex: Simulado ENEM 2026'),
              const SizedBox(height: 14),
              const Text('Descrição (opcional)',
                  style: TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
              const SizedBox(height: 6),
              _campo(descricaoCtrl, 'Ex: Foco em exatas'),
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
                      if (tituloCtrl.text.trim().isEmpty) return;
                      setDialogState(() => salvando = true);

                      try {
                        await criarSimulado(
                          titulo: tituloCtrl.text.trim(),
                          descricao: descricaoCtrl.text.trim().isEmpty
                              ? null
                              : descricaoCtrl.text.trim(),
                        );
                        if (!mounted) return;
                        Navigator.pop(ctx);
                        _carregar();
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

  Widget _campo(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
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
                ],
              ),
              const SizedBox(height: 20),
              const Text('Simulados',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text('Crie e administre seus simulados',
                  style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),
              const SizedBox(height: 20),
              TextField(
                controller: buscaCtrl,
                onChanged: filtrar,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Buscar simulado...',
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
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _criarSimuladoDialog,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F2744),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E3D5C), width: 2),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Color(0xFF4A9EFF), size: 18),
                      SizedBox(width: 8),
                      Text('Adicionar simulado', style: TextStyle(color: Color(0xFF4A9EFF), fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
              else if (filtrados.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('Nenhum simulado encontrado.',
                        style: TextStyle(color: Color(0xFF4A6A8A), fontSize: 14)),
                  ),
                )
              else
                ...filtrados.map(
                  (s) => GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SimuladoDetalhe(simuladoId: s.id)),
                      ).then((_) => _carregar());
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F2744),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1E3D5C), width: 2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A3A6A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.quiz_outlined, color: Color(0xFF4A9EFF), size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.titulo,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 3),
                                Text('${s.quantidadeQuestoes} questões',
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