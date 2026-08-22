import 'package:flutter/material.dart';
import 'package:tinker/Models/simulado_model.dart';
import 'package:tinker/paginas/Simulado/simulado_detalhes.dart';


class Simulado extends StatefulWidget {
  const Simulado({super.key});

  @override
  State<Simulado> createState() => _SimuladoState();
}

class _SimuladoState extends State<Simulado> {
  final buscaCtrl = TextEditingController();
  final List<SimuladoModel> simulados = [];
  List<SimuladoModel> simuladosFiltrados = [];

  @override
  void initState() {
    super.initState();
    simuladosFiltrados = List.from(simulados);
  }

  void filtrar(String texto) {
    setState(() {
      if (texto.isEmpty) {
        simuladosFiltrados = List.from(simulados);
      } else {
        simuladosFiltrados = simulados
            .where((s) =>
                s.nome.toLowerCase().contains(texto.toLowerCase()) ||
                s.materia.toLowerCase().contains(texto.toLowerCase()))
            .toList();
      }
    });
  }

  void remover(SimuladoModel simulado) {
    setState(() {
      simulados.remove(simulado);
      filtrar(buscaCtrl.text);
    });
  }

  void abrirSimulado(SimuladoModel simulado) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SimuladoDetalhe(simulado: simulado)),
    );
    setState(() {});
  }

  void criarSimulado() {
    final nomeCtrl = TextEditingController();
    final materiaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF0F2744),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Novo simulado',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome', style: TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
            SizedBox(height: 6),
            campoDeSimulado(nomeCtrl, 'Ex: Simulado ENEM 2026'),
            SizedBox(height: 14),
            Text('Matéria', style: TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
            SizedBox(height: 6),
            campoDeSimulado(materiaCtrl, 'Ex: Geral'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: Color(0xFF8AABCC))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1A4A8A),
              foregroundColor: Color(0xFF4A9EFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () {
              if (nomeCtrl.text.trim().isEmpty) return;
              setState(() {
                simulados.insert(
                  0,
                  SimuladoModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    nome: nomeCtrl.text.trim(),
                    materia:
                        materiaCtrl.text.trim().isEmpty ? "Geral" : materiaCtrl.text.trim(),
                  ),
                );
                filtrar(buscaCtrl.text);
              });
              Navigator.pop(ctx);
            },
            child: Text('Criar'),
          ),
        ],
      ),
    );
  }

  Widget campoDeSimulado(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Color(0xFF4A6A8A), fontSize: 14),
        filled: true,
        fillColor: Color(0xFF0D1B2A),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF1E3D5C), width: 0.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF1E3D5C), width: 0.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF4A9EFF), width: 1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1B2A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),

              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF0F2744),
                        border: Border.all(color: Color(0xFF1E3D5C), width: 0.5),
                      ),
                      child: Icon(Icons.arrow_back, color: Colors.white, size: 18),
                    ),
                  ),
                  SizedBox(width: 20),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF1A4A7A),
                    child: Image.asset('assets/images/tinker_images/logo2.png'),
                  ),
                  SizedBox(width: 8),
                  Text('TINKER',
                      style: TextStyle(
                          fontFamily: 'Stardom',
                          color: Colors.white,
                          fontSize: 25,
                          letterSpacing: 3)),
                ],
              ),

              SizedBox(height: 20),

              Text('Simulados',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              Text('Pratique e acompanhe seus simulados',
                  style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),

              SizedBox(height: 20),

              TextField(
                controller: buscaCtrl,
                onChanged: filtrar,
                style: TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Buscar simulado ou matéria...',
                  hintStyle: TextStyle(color: Color(0xFF4A6A8A), fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF4A6A8A), size: 20),
                  filled: true,
                  fillColor: Color(0xFF0F2744),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFF1E3D5C), width: 0.5)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFF1E3D5C), width: 0.5)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFF4A9EFF), width: 1)),
                ),
              ),

              SizedBox(height: 20),

              Text('SEUS SIMULADOS',
                  style: TextStyle(color: Color(0xFF8AABCC), fontSize: 11, letterSpacing: 1.2)),

              SizedBox(height: 10),

              GestureDetector(
                onTap: criarSimulado,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Color(0xFF0F2744),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF1E3D5C), width: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Color(0xFF4A9EFF), size: 18),
                      SizedBox(width: 8),
                      Text('Adicionar simulado',
                          style: TextStyle(color: Color(0xFF4A9EFF), fontSize: 14)),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12),

              if (simuladosFiltrados.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.quiz_outlined, color: Color(0xFF4A6A8A), size: 40),
                        SizedBox(height: 12),
                        Text('Nenhum simulado encontrado.',
                            style: TextStyle(color: Color(0xFF4A6A8A), fontSize: 14)),
                        SizedBox(height: 4),
                        Text('Adicione seu primeiro simulado acima.',
                            style: TextStyle(color: Color(0xFF4A6A8A), fontSize: 13)),
                      ],
                    ),
                  ),
                )
              else
                ...simuladosFiltrados.map(
                  (s) => GestureDetector(
                    onTap: () => abrirSimulado(s),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Color(0xFF0F2744),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF1E3D5C), width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Color(0xFF1A3A6A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.quiz_outlined, color: Color(0xFF4A9EFF), size: 18),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.nome,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                                SizedBox(height: 3),
                                Text(s.materia,
                                    style: TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
                                SizedBox(height: 6),
                                Text('${s.questoesIds.length} questão(ões)',
                                    style: TextStyle(color: Color(0xFF4A9EFF), fontSize: 11)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => remover(s),
                            icon: Icon(Icons.close, color: Color(0xFF4A6A8A), size: 18),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}