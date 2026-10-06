import 'package:flutter/material.dart';
import 'package:tinker/Models/questao_model.dart';
import 'package:tinker/Models/simulado_model.dart';
import 'package:tinker/paginas/Questoes/card_questao.dart';
import 'package:tinker/Services/simulado_service.dart';
import 'package:tinker/Services/questoes_service.dart';
//import 'package:tinker/Services/api_client.dart';

class SimuladoDetalhe extends StatefulWidget {
  final int simuladoId;

  const SimuladoDetalhe({super.key, required this.simuladoId});

  @override
  State<SimuladoDetalhe> createState() => _SimuladoDetalheState();
}

class _SimuladoDetalheState extends State<SimuladoDetalhe> {
  bool carregando = true;
  String? erro;
  SimuladoDetalheDTO? detalhe;
  List<Questao> questoes = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => carregando = true);

    try {
      final det = await detalharSimulado(widget.simuladoId);
      final qs = await listarQuestoesDoSimulado(widget.simuladoId);
      setState(() {
        detalhe = det;
        questoes = qs;
        carregando = false;
      });
    } catch (e) {
      setState(() {
        erro = 'Não foi possível carregar este simulado.';
        carregando = false;
      });
    }
  }

  void _selecionarAlternativa(Questao questao, Alternativa alt) {
    setState(() => questao.alternativaSelecionadaId = alt.id);
  }

  Future<void> _enviarResposta(Questao questao) async {
    if (questao.alternativaSelecionadaId == null) return;

    try {
      final acertou = await corrigirQuestaoDoSimulado(
        simuladoId: widget.simuladoId,
        questaoId: questao.id,
        alternativaSelecionadaId: questao.alternativaSelecionadaId!,
      );
      setState(() {
        questao.respondida = true;
        questao.ultimaRespostaCorreta = acertou;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Erro ao corrigir a questão.')));
    }
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

  Future<void> _removerQuestao(Questao questao) async {
    try {
      await removerQuestaoDoSimulado(widget.simuladoId, questao.id);
      _carregarDados();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Erro ao remover questão.')));
    }
  }

  void _abrirSeletorDeQuestoes() {
    final busca = TextEditingController();
    List<Questao> resultados = [];
    bool buscando = false;
    final Set<int> jaAdicionadas = questoes.map((q) => q.id).toSet();
    final Set<int> selecionadas = {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F2744),
      shape: const RoundedRectangleBorder(
        
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> buscar() async {
              setModalState(() => buscando = true);
              try {
                final pagina = await buscarQuestoesPaginado(
                  trecho: busca.text,
                  tamanho: 30,
                );
                setModalState(() {
                  resultados =
                      pagina.itens.where((q) => !jaAdicionadas.contains(q.id)).toList();
                  buscando = false;
                });
              } catch (e) {
                setModalState(() => buscando = false);
              }
            }

            if (resultados.isEmpty && !buscando) {
              buscar();
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Adicionar questões',
                        style: TextStyle(
                            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: busca,
                      onSubmitted: (_) => buscar(),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Buscar por trecho...',
                        hintStyle: const TextStyle(color: Color(0xFF4A6A8A), fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFF0D1B2A),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search, color: Color(0xFF4A6A8A)),
                          onPressed: buscar,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: buscando
                          ? const Center(
                              child: CircularProgressIndicator(color: Color(0xFF4A9EFF)))
                          : resultados.isEmpty
                              ? const Center(
                                  child: Text('Nenhuma questão encontrada.',
                                      style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),
                                )
                              : ListView(
                                  children: resultados.map((q) {
                                    final marcada = selecionadas.contains(q.id);
                                    return GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          if (marcada) {
                                            selecionadas.remove(q.id);
                                          } else {
                                            selecionadas.add(q.id);
                                          }
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0D1B2A),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                              color: marcada
                                                  ? const Color(0xFF4A9EFF)
                                                  : const Color(0xFF1E3D5C),
                                              width: marcada ? 1.5 : 2),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              marcada
                                                  ? Icons.check_circle
                                                  : Icons.circle_outlined,
                                              color: marcada
                                                  ? const Color(0xFF4A9EFF)
                                                  : const Color(0xFF4A6A8A),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 10),
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
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selecionadas.isEmpty
                            ? null
                            : () async {
                                try {
                                  await adicionarQuestoesAoSimulado(
                                      widget.simuladoId, selecionadas.toList());
                                  if (!mounted) return;
                                  Navigator.pop(ctx);
                                  _carregarDados();
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Erro ao adicionar questões.')));
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A4A8A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Adicionar (${selecionadas.length})',style: TextStyle(color: Color(0xFF4A9EFF) ),),
                      ),
                    ),
                  ],
                ),
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
            : erro != null
                ? Center(child: Text(erro!, style: const TextStyle(color: Color(0xFFE05C6A))))
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
                      Text(detalhe?.titulo ?? '',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
                      if ((detalhe?.descricao ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(detalhe!.descricao!,
                            style: const TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),
                      ],
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _abrirSeletorDeQuestoes,
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
                              Text('Adicionar questões', style: TextStyle(color: Color(0xFF4A9EFF), fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (questoes.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text('Nenhuma questão adicionada ainda.',
                                style: TextStyle(color: Color(0xFF4A6A8A), fontSize: 14)),
                          ),
                        )
                      else
                        ...questoes.map(
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
                                  onTap: () => _removerQuestao(q),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.delete_outline, color: Color(0xFFE05C6A), size: 18),
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