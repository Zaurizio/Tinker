import 'package:flutter/material.dart';
import 'package:tinker/paginas/turma_detalhes.dart';

class Turma extends StatefulWidget {
  const Turma({super.key});

  @override
  State<Turma> createState() => _TurmaState();
}

class _TurmaState extends State<Turma> {
  final buscaCtrl = TextEditingController();
  final List<Map<String, String>> turmas = [];
  List<Map<String, String>> turmasFiltradas = [];

  @override
  void initState() {
    super.initState();
    turmasFiltradas = List.from(turmas);
  }

  void filtrar(String texto) {
    setState(() {
      if (texto.isEmpty) {
        turmasFiltradas = List.from(turmas);
      } else {
        turmasFiltradas = turmas
            .where((t) =>
                t["turma"]!.toLowerCase().contains(texto.toLowerCase()) ||
                t["materia"]!.toLowerCase().contains(texto.toLowerCase()))
            .toList();
      }
    });
  }

  void remover(Map<String, String> turma) {
    setState(() {
      turmas.remove(turma);
      filtrar(buscaCtrl.text);
    });
  }

  void criarTurma() {
    final nomeCtrl = TextEditingController();
    final materiaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF0F2744),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Nova turma',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome da turma', style: TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
            SizedBox(height: 6),
            campoDeTurma(nomeCtrl, 'Ex: Turma A'),
            SizedBox(height: 14),
            Text('Matéria', style: TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
            SizedBox(height: 6),
            campoDeTurma(materiaCtrl, 'Ex: Matemática'),
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
                turmas.insert(0, {
                  "turma": nomeCtrl.text.trim(),
                  "materia": materiaCtrl.text.trim().isEmpty
                      ? "Sem matéria"
                      : materiaCtrl.text.trim(),
                });
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

  Widget campoDeTurma(TextEditingController ctrl, String hint) {
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

              Text('Turmas',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              Text('Gerencie suas turmas e matérias',
                  style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),

              SizedBox(height: 20),

              TextField(
                controller: buscaCtrl,
                onChanged: filtrar,
                style: TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Buscar turma ou matéria...',
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

              Text('SUAS TURMAS',
                  style: TextStyle(color: Color(0xFF8AABCC), fontSize: 11, letterSpacing: 1.2)),

              SizedBox(height: 10),

              GestureDetector(
                onTap: criarTurma,
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
                      Text('Adicionar turma',
                          style: TextStyle(color: Color(0xFF4A9EFF), fontSize: 14)),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12),

              if (turmasFiltradas.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.group_outlined, color: Color(0xFF4A6A8A), size: 40),
                        SizedBox(height: 12),
                        Text('Nenhuma turma encontrada.',
                            style: TextStyle(color: Color(0xFF4A6A8A), fontSize: 14)),
                        SizedBox(height: 4),
                        Text('Adicione sua primeira turma acima.',
                            style: TextStyle(color: Color(0xFF4A6A8A), fontSize: 13)),
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
                      );
                    },
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
                            child: Icon(Icons.group_outlined, color: Color(0xFF4A9EFF), size: 18),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t["turma"]!,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                                SizedBox(height: 3),
                                Text(t["materia"]!,
                                    style: TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => remover(t),
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