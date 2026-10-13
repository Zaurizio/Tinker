import 'package:flutter/material.dart';
import 'package:tinker/Models/questao_model.dart';
import 'package:tinker/paginas/Questoes/card_questao.dart';
import 'package:tinker/Services/questoes_service.dart';
import 'package:tinker/Services/filtros_questao_service.dart';

class QuestoesResponder extends StatefulWidget {
  const QuestoesResponder({super.key});

  @override
  State<QuestoesResponder> createState() => _QuestoesResponderState();
}

class _QuestoesResponderState extends State<QuestoesResponder> {
  bool carregando = true;
  bool carregandoMais = false;
  String? erro;

  List<Questao> questoes = [];
  bool temMais = false;
  int paginaAtual = 0;

  final trechoCtrl = TextEditingController();
  String? disciplinaSelecionada;
  String? conteudoSelecionado;
  String? vestibularSelecionado;
  int? anoSelecionado;

  FiltrosQuestao? filtrosDisponiveis;

  @override
  void initState() {
    super.initState();
    _carregarFiltrosDisponiveis();
    _buscar(reiniciar: true);
  }

  Future<void> _carregarFiltrosDisponiveis() async {
    try {
      final filtros = await buscarFiltrosDisponiveis();
      setState(() => filtrosDisponiveis = filtros);
    } catch (e) {
      // se os filtros não carregarem, a busca continua funcionando sem eles
    }
  }

  Future<void> _buscar({bool reiniciar = false}) async {
    if (reiniciar) {
      setState(() {
        carregando = true;
        erro = null;
        paginaAtual = 0;
      });
    } else {
      setState(() => carregandoMais = true);
    }

    try {
      final resultado = await buscarQuestoesPaginado(
        disciplina: disciplinaSelecionada,
        conteudo: conteudoSelecionado,
        vestibular: vestibularSelecionado,
        ano: anoSelecionado,
        trecho: trechoCtrl.text,
        pagina: reiniciar ? 0 : paginaAtual + 1,
      );

      setState(() {
        if (reiniciar) {
          questoes = resultado.itens;
        } else {
          questoes = [...questoes, ...resultado.itens];
        }
        temMais = resultado.temMais;
        paginaAtual = resultado.pagina;
        carregando = false;
        carregandoMais = false;
      });
    } catch (e) {
      setState(() {
        erro = 'Não foi possível carregar as questões.';
        carregando = false;
        carregandoMais = false;
      });
    }
  }

  void _limparFiltros() {
    setState(() {
      disciplinaSelecionada = null;
      conteudoSelecionado = null;
      vestibularSelecionado = null;
      anoSelecionado = null;
      trechoCtrl.clear();
    });
    _buscar(reiniciar: true);
  }

  void _selecionarAlternativa(Questao questao, Alternativa alt) {
    setState(() => questao.alternativaSelecionadaId = alt.id);
  }

  Future<void> _enviarResposta(Questao questao) async {
    if (questao.alternativaSelecionadaId == null) return;

    try {
      final acertou =
          await corrigirQuestaoAvulsa(questao.id, questao.alternativaSelecionadaId!);
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
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A9EFF)))
            : erro != null
                ? Center(
                    child: Text(erro!, style: const TextStyle(color: Color(0xFFE05C6A))))
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
                                border:
                                    Border.all(color: const Color(0xFF1E3D5C), width: 1),
                              ),
                              child: const Icon(Icons.arrow_back,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('Buscar Questões',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 20),
                      _painelDeFiltros(),
                      const SizedBox(height: 20),
                      ...questoes.map((q) => QuestaoCard(
                            questao: q,
                            onSalvar: () => _toggleSalvar(q),
                            onSelecionarAlternativa: (alt) =>
                                _selecionarAlternativa(q, alt),
                            onEliminarAlternativa: (alt) => _toggleEliminar(q, alt),
                            onEnviarResposta: () => _enviarResposta(q),
                          )),
                      if (questoes.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(Icons.search_off, color: Color(0xFF4A6A8A), size: 40),
                                SizedBox(height: 12),
                                Text('Nenhuma questão encontrada.',
                                    style:
                                        TextStyle(color: Color(0xFF4A6A8A), fontSize: 14)),
                              ],
                            ),
                          ),
                        )
                      else if (temMais)
                        Center(
                          child: TextButton(
                            onPressed: carregandoMais ? null : () => _buscar(),
                            child: carregandoMais
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Color(0xFF4A9EFF)),
                                  )
                                : const Text('Carregar mais',
                                    style: TextStyle(color: Color(0xFF4A9EFF))),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }

  Widget _painelDeFiltros() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2744),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E3D5C), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _dropdown<String>(
                label: 'Disciplina',
                valor: disciplinaSelecionada,
                opcoes: filtrosDisponiveis?.disciplinas ?? [],
                exibir: (v) => v,
                onChanged: (v) => setState(() => disciplinaSelecionada = v),
              ),
              const SizedBox(width: 12),
              _dropdown<String>(
                label: 'Conteúdo',
                valor: conteudoSelecionado,
                opcoes: filtrosDisponiveis?.conteudos ?? [],
                exibir: (v) => v,
                onChanged: (v) => setState(() => conteudoSelecionado = v),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _dropdown<String>(
                label: 'Vestibular',
                valor: vestibularSelecionado,
                opcoes: filtrosDisponiveis?.vestibulares ?? [],
                exibir: (v) => v,
                onChanged: (v) => setState(() => vestibularSelecionado = v),
              ),
              const SizedBox(width: 12),
              _dropdown<int>(
                label: 'Ano',
                valor: anoSelecionado,
                opcoes: filtrosDisponiveis?.anos ?? [],
                exibir: (v) => v.toString(),
                onChanged: (v) => setState(() => anoSelecionado = v),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _campoTrecho('Trecho da questão', trechoCtrl),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _limparFiltros,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1B2A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1E3D5C), width: 1),
                  ),
                  child: const Text('Limpar filtros',
                      style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _buscar(reiniciar: true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A4A8A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Buscar questões',
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T? valor,
    required List<T> opcoes,
    required String Function(T) exibir,
    required void Function(T?) onChanged,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B2A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1E3D5C), width: 2),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: valor,
                isExpanded: true,
                hint: const Text('Todas',
                    style: TextStyle(color: Color(0xFF4A6A8A), fontSize: 13)),
                dropdownColor: const Color(0xFF0F2744),
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF4A6A8A)),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                items: [
                  DropdownMenuItem<T>(
                    value: null,
                    child: const Text('Todas', style: TextStyle(color: Colors.white)),
                  ),
                  ...opcoes.map((o) => DropdownMenuItem<T>(value: o, child: Text(exibir(o)))),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoTrecho(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Digite um trecho da questão',
            hintStyle: const TextStyle(color: Color(0xFF4A6A8A), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF0D1B2A),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1E3D5C), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1E3D5C), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4A9EFF), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
