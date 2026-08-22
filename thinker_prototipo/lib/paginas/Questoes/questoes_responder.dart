import 'package:flutter/material.dart';
import 'package:tinker/Models/questao_model.dart';
import 'package:tinker/paginas/Questoes/card_questao.dart';

import 'questoes_mock.dart';


class QuestoesResponder extends StatefulWidget {
  final String? questaoId;

  const QuestoesResponder({super.key, this.questaoId});

  @override
  State<QuestoesResponder> createState() => _QuestoesResponderState();
}

class _QuestoesResponderState extends State<QuestoesResponder> {
  bool carregando = true;
  String? erro;
  List<Questao> questoes = [];

  @override
  void initState() {
    super.initState();
    _carregarQuestoes();
  }

  Future<void> _carregarQuestoes() async {
    setState(() => carregando = true);

    await Future.delayed(const Duration(milliseconds: 400));

    setState(() {
      final todas = buscarQuestoesMock();
      questoes = widget.questaoId != null
          ? todas.where((q) => q.id == widget.questaoId).toList()
          : todas;
      carregando = false;
    });
  }

  void _selecionarAlternativa(Questao questao, Alternativa alt) {
    setState(() => questao.alternativaSelecionadaId = alt.id);
  }

  void _enviarResposta(Questao questao) {
    if (questao.alternativaSelecionadaId == null) return;
    setState(() => questao.respondida = true);
  }

  void _toggleEliminar(Questao questao, Alternativa alt) {
    if (questao.respondida) return;
    setState(() {
      alt.eliminada = !alt.eliminada;
      if (questao.alternativaSelecionadaId == alt.id) {
        questao.alternativaSelecionadaId = null;
      }
    });
  }

  void _toggleSalvar(Questao questao) {
    setState(() => questao.salva = !questao.salva);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: carregando
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4A9EFF)),
              )
            : erro != null
                ? Center(
                    child: Text(erro!,
                        style: const TextStyle(color: Color(0xFFE05C6A))),
                  )
                : RefreshIndicator(
                    color: const Color(0xFF4A9EFF),
                    backgroundColor: const Color(0xFF0F2744),
                    onRefresh: _carregarQuestoes,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      children: [
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
                                  border: Border.all(
                                      color: const Color(0xFF1E3D5C),
                                      width: 1),
                                ),
                                child: const Icon(Icons.arrow_back,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text('Questões',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        const Text('Responda e acompanhe seu desempenho',
                            style: TextStyle(
                                color: Color(0xFF8AABCC), fontSize: 13)),
                        const SizedBox(height: 20),
                        ...questoes.map((q) => QuestaoCard(
                              questao: q,
                              onSalvar: () => _toggleSalvar(q),
                              onSelecionarAlternativa: (alt) =>
                                  _selecionarAlternativa(q, alt),
                              onEliminarAlternativa: (alt) =>
                                  _toggleEliminar(q, alt),
                              onEnviarResposta: () => _enviarResposta(q),
                            )),
                      ],
                    ),
                  ),
      ),
    );
  }
}