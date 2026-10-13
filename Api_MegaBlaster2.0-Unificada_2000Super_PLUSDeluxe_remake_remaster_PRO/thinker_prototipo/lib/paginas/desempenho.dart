import 'package:flutter/material.dart';
import 'package:tinker/Models/desempenho_model.dart';
import 'package:tinker/Services/desempenho_service.dart';

class Desempenho extends StatefulWidget {
  const Desempenho({super.key});

  @override
  State<Desempenho> createState() => _DesempenhoState();
}

class _DesempenhoState extends State<Desempenho> {
  bool carregando = true;
  String? erro;
  DesempenhoResumo? resumo;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => carregando = true);

    try {
      final dados = await buscarDesempenho();
      setState(() {
        resumo = dados;
        carregando = false;
      });
    } catch (e) {
      setState(() {
        erro = 'Não foi possível carregar seu desempenho.';
        carregando = false;
      });
    }
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
                  const SizedBox(width: 20),
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF1A4A7A),
                    child: Icon(Icons.school, color: Colors.white),
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
              const SizedBox(height: 20),
              const Text('Desempenho',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text('Acompanhe sua evolução nos estudos',
                  style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),
              const SizedBox(height: 24),
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
              else if (resumo == null || resumo!.questoesRespondidas == 0)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        Icon(Icons.bar_chart, color: Color(0xFF4A6A8A), size: 40),
                        SizedBox(height: 12),
                        Text('Você ainda não respondeu nenhuma questão.',
                            style: TextStyle(color: Color(0xFF4A6A8A), fontSize: 14)),
                      ],
                    ),
                  ),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: _cardResumo(
                        icone: Icons.check_circle_outline,
                        corIcone: const Color(0xFF4A9EFF),
                        valor: '${resumo!.questoesRespondidas}',
                        legenda: 'questões feitas',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _cardResumo(
                        icone: Icons.trending_up_rounded,
                        corIcone: const Color(0xFF4A9EFF),
                        valor: '${resumo!.percentualGeral}%',
                        legenda: 'acerto geral',
                      ),
                    ),
                  ],
                ),
                if (resumo!.maiorDesempenho != null || resumo!.menorDesempenho != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (resumo!.maiorDesempenho != null)
                        Expanded(
                          child: _cardDestaque(
                            titulo: 'Melhor disciplina',
                            icone: Icons.emoji_events_outlined,
                            cor: const Color(0xFF4A9EFF),
                            disciplina: resumo!.maiorDesempenho!,
                          ),
                        ),
                      if (resumo!.maiorDesempenho != null && resumo!.menorDesempenho != null)
                        const SizedBox(width: 10),
                      if (resumo!.menorDesempenho != null)
                        Expanded(
                          child: _cardDestaque(
                            titulo: 'Precisa melhorar',
                            icone: Icons.trending_down_rounded,
                            cor: const Color(0xFF4A9EFF),
                            disciplina: resumo!.menorDesempenho!,
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                const Text('POR DISCIPLINA',
                    style: TextStyle(color: Color(0xFF8AABCC), fontSize: 11, letterSpacing: 1.2)),
                const SizedBox(height: 10),
                ...resumo!.disciplinas.map((d) => _cardDisciplina(d)),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardResumo({
    required IconData icone,
    required Color corIcone,
    required String valor,
    required String legenda,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2744),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E3D5C), width: 2),
      ),
      child: Column(
        children: [
          Icon(icone, color: corIcone, size: 26),
          const SizedBox(height: 8),
          Text(valor,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(legenda, style: const TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _cardDestaque({
    required String titulo,
    required IconData icone,
    required Color cor,
    required DesempenhoDisciplina disciplina,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2744),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3D5C), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: cor, size: 16),
              const SizedBox(width: 6),
              Text(titulo, style: TextStyle(color: cor, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Text(disciplina.disciplina,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('${disciplina.percentualAcertos}% de acerto',
              style: const TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _cardDisciplina(DesempenhoDisciplina d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2744),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3D5C), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(d.disciplina,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              Text('${d.percentualAcertos}%',
                  style: const TextStyle(color: Color(0xFF4A9EFF), fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: d.percentualAcertos / 100,
              minHeight: 6,
              backgroundColor: const Color(0xFF0D1B2A),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF4A9EFF)),
            ),
          ),
          const SizedBox(height: 6),
          Text('${d.numeroAcertos} de ${d.questoesFeitas} questões',
              style: const TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
        ],
      ),
    );
  }
}
