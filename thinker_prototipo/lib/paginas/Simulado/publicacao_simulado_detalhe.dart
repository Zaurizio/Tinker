import 'package:flutter/material.dart';
import 'package:tinker/Models/questao_model.dart';
import 'package:tinker/paginas/Questoes/card_questao.dart';
import 'package:tinker/Services/turma_simulado_service.dart';
//import 'package:tinker/Models/resultado_simulado_model.dart';


class PublicacaoSimuladoDetalhe extends StatefulWidget {
  final String codTurma;
  final String idPublicacao;
  final String titulo;

  const PublicacaoSimuladoDetalhe({
    super.key,
    required this.codTurma,
    required this.idPublicacao,
    required this.titulo,
  });

  @override
  State<PublicacaoSimuladoDetalhe> createState() => _PublicacaoSimuladoDetalheState();
}

class _PublicacaoSimuladoDetalheState extends State<PublicacaoSimuladoDetalhe> {
  bool carregando = true;
  String? erro;
  List<Questao> questoes = [];

  bool concluido = false;
  bool concluindo = false;
  int? acertosFinal;
  int? errosFinal;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => carregando = true);

    try {
      final resultado =
          await consultarResultadoPublicacao(widget.codTurma, widget.idPublicacao);

      if (resultado.completo) {
        setState(() {
          concluido = true;
          acertosFinal = resultado.acertos;
          errosFinal = resultado.erros;
          carregando = false;
        });
        return;
      }

      final lista = await listarQuestoesDaPublicacao(widget.codTurma, widget.idPublicacao);
      setState(() {
        questoes = lista;
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

  void _toggleEliminar(Questao questao, Alternativa alt) {
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

  Future<void> _enviarResposta(Questao questao) async {
    if (questao.alternativaSelecionadaId == null) return;

    try {
      final acertou = await corrigirQuestaoPublicada(
        codTurma: widget.codTurma,
        idPublicacao: widget.idPublicacao,
        questaoId: questao.id,
        alternativa: questao.alternativaSelecionadaId!,
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

  bool get _todasRespondidas =>
      questoes.isNotEmpty && questoes.every((q) => q.respondida);

  Future<void> _concluirSimulado() async {
    setState(() => concluindo = true);

    try {
      final respostas = questoes
          .map((q) => {
                'questaoId': q.id,
                'alternativa': q.alternativaSelecionadaId,
              })
          .toList();

      final resultado = await concluirSimuladoPublicado(
        codTurma: widget.codTurma,
        idPublicacao: widget.idPublicacao,
        respostas: respostas,
      );

      setState(() {
        concluido = true;
        acertosFinal = resultado.acertos;
        errosFinal = resultado.erros;
        concluindo = false;
      });
    } catch (e) {
      setState(() => concluindo = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Erro ao concluir o simulado.')));
    }
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
                      Text(widget.titulo,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 20),
                      if (concluido)
                        _cardResultado()
                      else ...[
                        ...questoes.map(
                          (q) => QuestaoCard(
                            questao: q,
                            onSalvar: () => _toggleSalvar(q),
                            onSelecionarAlternativa: (alt) => _selecionarAlternativa(q, alt),
                            onEliminarAlternativa: (alt) => _toggleEliminar(q, alt),
                            onEnviarResposta: () => _enviarResposta(q),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (_todasRespondidas && !concluindo) ? _concluirSimulado : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A4A8A),
                              disabledBackgroundColor: const Color(0xFF14335A),
                              foregroundColor: Colors.white,
                              disabledForegroundColor: const Color(0xFF8AABCC),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: Text(
                              concluindo
                                  ? 'Concluindo...'
                                  : _todasRespondidas
                                      ? 'Concluir simulado'
                                      : 'Responda todas as questões pra concluir',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
      ),
    );
  }

  Widget _cardResultado() {
    final acertos = acertosFinal ?? 0;
    final erros = errosFinal ?? 0;
    final total = acertos + erros;
    final percentual = total == 0 ? 0 : ((acertos / total) * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2744),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E3D5C), width: 0.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_outlined, color: Color(0xFF4ABA8A), size: 40),
          const SizedBox(height: 12),
          const Text('Simulado concluído!',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _numero('$acertos', 'Acertos', const Color(0xFF4ABA8A)),
              _numero('$erros', 'Erros', const Color(0xFFE05C6A)),
              _numero('$percentual%', 'Aproveitamento', const Color(0xFF4A9EFF)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _numero(String valor, String legenda, Color cor) {
    return Column(
      children: [
        Text(valor, style: TextStyle(color: cor, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(legenda, style: const TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
      ],
    );
  }
}
