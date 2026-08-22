import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tinker/Models/questao_model.dart';
import 'package:tinker/Models/simulado_model.dart';
import 'package:tinker/paginas/Questoes/card_questao.dart';
import 'package:tinker/paginas/Questoes/questoes_mock.dart';


class SimuladoDetalhe extends StatefulWidget {
  final SimuladoModel simulado;

  const SimuladoDetalhe({super.key, required this.simulado});

  @override
  State<SimuladoDetalhe> createState() => _SimuladoDetalheState();
}

class _SimuladoDetalheState extends State<SimuladoDetalhe> {
  List<Questao> todasQuestoes = [];
  List<Questao> questoesDoSimulado = [];
  bool carregando = true;
  bool gerandoComIA = false;

  @override
  void initState() {
    super.initState();
    _carregarQuestoes();
  }

  Future<void> _carregarQuestoes() async {
    setState(() => carregando = true);

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      todasQuestoes = buscarQuestoesMock();
      _atualizarQuestoesDoSimulado();
      carregando = false;
    });
  }

  void _atualizarQuestoesDoSimulado() {
    questoesDoSimulado = todasQuestoes
        .where((q) => widget.simulado.questoesIds.contains(q.id))
        .toList();
  }

  void _adicionarQuestao(String questaoId) {
    setState(() {
      widget.simulado.questoesIds.add(questaoId);
      _atualizarQuestoesDoSimulado();
    });
  }

  void _removerQuestao(String questaoId) {
    setState(() {
      widget.simulado.questoesIds.remove(questaoId);
      _atualizarQuestoesDoSimulado();
    });
  }

  Future<void> _gerarComIA() async {
    setState(() => gerandoComIA = true);

    await Future.delayed(const Duration(milliseconds: 900));

    final disponiveis = todasQuestoes
        .where((q) => !widget.simulado.questoesIds.contains(q.id))
        .toList()
      ..shuffle(Random());

    final selecionadas = disponiveis.take(3).map((q) => q.id).toList();

    setState(() {
      widget.simulado.questoesIds.addAll(selecionadas);
      _atualizarQuestoesDoSimulado();
      gerandoComIA = false;
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

  void _abrirSeletorDeQuestoes() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F2744),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final disponiveis = todasQuestoes
                .where((q) => !widget.simulado.questoesIds.contains(q.id))
                .toList();

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Adicionar questão',
                      style: TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  if (disponiveis.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('Todas as questões já foram adicionadas.',
                          style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),
                    )
                  else
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: disponiveis.map((q) {
                          return GestureDetector(
                            onTap: () {
                              _adicionarQuestao(q.id);
                              setModalState(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D1B2A),
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: const Color(0xFF1E3D5C), width: 0.5),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(q.assunto,
                                            style: const TextStyle(
                                                color: Colors.white, fontSize: 14)),
                                        const SizedBox(height: 2),
                                        Text(q.materia,
                                            style: const TextStyle(
                                                color: Color(0xFF8AABCC), fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.add_circle_outline,
                                      color: Color(0xFF4A9EFF), size: 20),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: carregando
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A9EFF)))
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                            border: Border.all(color: const Color(0xFF1E3D5C), width: 1),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(widget.simulado.nome,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(widget.simulado.materia,
                      style: const TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _abrirSeletorDeQuestoes,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F2744),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF1E3D5C), width: 0.5),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: Color(0xFF4A9EFF), size: 18),
                                SizedBox(width: 8),
                                Text('Adicionar questão',
                                    style: TextStyle(color: Color(0xFF4A9EFF), fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: gerandoComIA ? null : _gerarComIA,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A4A8A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF1E4A8A), width: 0.5),
                            ),
                            child: gerandoComIA
                                ? const Center(
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Color(0xFF4A9EFF)),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.auto_awesome,
                                          color: Color(0xFF4A9EFF), size: 18),
                                      SizedBox(width: 8),
                                      Text('Gerar com IA',
                                          style: TextStyle(
                                              color: Color(0xFF4A9EFF), fontSize: 14)),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (questoesDoSimulado.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            const Icon(Icons.quiz_outlined, color: Color(0xFF4A6A8A), size: 40),
                            const SizedBox(height: 12),
                            const Text('Nenhuma questão adicionada.',
                                style: TextStyle(color: Color(0xFF4A6A8A), fontSize: 14)),
                            const SizedBox(height: 4),
                            const Text(
                                'Adicione manualmente ou gere um simulado com IA.',
                                style: TextStyle(color: Color(0xFF4A6A8A), fontSize: 13)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...questoesDoSimulado.map(
                      (q) => Stack(
                        children: [
                          QuestaoCard(
                            questao: q,
                            onSalvar: () => _toggleSalvar(q),
                            onSelecionarAlternativa: (alt) => _selecionarAlternativa(q, alt),
                            onEliminarAlternativa: (alt) => _toggleEliminar(q, alt),
                            onEnviarResposta: () => _enviarResposta(q),
                          ),
                          Positioned(
                            top: 0,
                            right: 30,
                            child: GestureDetector(
                              onTap: () => _removerQuestao(q.id),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.delete_outline,
                                    color: Color(0xFFE05C6A), size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}