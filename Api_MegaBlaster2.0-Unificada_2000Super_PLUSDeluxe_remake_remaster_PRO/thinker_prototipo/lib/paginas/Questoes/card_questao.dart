import 'package:flutter/material.dart';
import 'package:tinker/Models/questao_model.dart';

class QuestaoCard extends StatelessWidget {
  final Questao questao;
  final bool mostrarSalvar;
  final bool mostrarEliminar;
  final VoidCallback? onSalvar;
  final void Function(Alternativa alternativa)? onSelecionarAlternativa;
  final void Function(Alternativa alternativa)? onEliminarAlternativa;
  final VoidCallback? onEnviarResposta;

  const QuestaoCard({
    super.key,
    required this.questao,
    this.mostrarSalvar = true,
    this.mostrarEliminar = true,
    this.onSalvar,
    this.onSelecionarAlternativa,
    this.onEliminarAlternativa,
    this.onEnviarResposta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
              Expanded(
                child: Wrap(
                  spacing: 10,
                  children: [
                    _tag(questao.materia),
                    _tag(questao.assunto),
                    _tag(questao.instituicao),
                    if (questao.ano != null) _tag(questao.ano.toString()),
                  ],
                ),
              ),
              if (mostrarSalvar)
                GestureDetector(
                  onTap: onSalvar,
                  child: Icon(
                    questao.salva ? Icons.bookmark : Icons.bookmark_border,
                    color: const Color(0xFF4A9EFF),
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            questao.enunciado,
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 14),
          ...questao.alternativas.map((alt) => _linhaAlternativa(alt)),
          const SizedBox(height: 4),
          if (onEnviarResposta != null)
            _botaoResposta()
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1B2A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1E3D5C), width: 2),
              ),
              child: const Text(
                'Correção de questões avulsas em breve',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF4A6A8A), fontSize: 12),
              ),
            ),
          if (questao.respondida) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: questao.ultimaRespostaCorreta == true
                    ? const Color(0xFF0F3A2A)
                    : const Color(0xFF3A1520),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                questao.ultimaRespostaCorreta == true ? 'Você acertou!' : 'Você errou.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: questao.ultimaRespostaCorreta == true
                      ? const Color(0xFF4ABA8A)
                      : const Color(0xFFE05C6A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _botaoResposta() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: questao.alternativaSelecionadaId == null ? null : onEnviarResposta,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF14335A),
          disabledBackgroundColor: const Color(0xFF14335A),
          foregroundColor: const Color(0xFF8AABCC),
          disabledForegroundColor: const Color(0xFF8AABCC),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text('Enviar resposta'),
      ),
    );
  }

  Widget _tag(String texto) {
    return Text(texto, style: const TextStyle(color: Color(0xFF8AABCC), fontSize: 12));
  }

  Widget _linhaAlternativa(Alternativa alt) {
    final selecionada = questao.alternativaSelecionadaId == alt.id;

    Color corBorda = const Color(0xFF1E3D5C);
    if (questao.respondida && selecionada) {
      corBorda = questao.ultimaRespostaCorreta == true
          ? const Color(0xFF4ABA8A)
          : const Color(0xFFE05C6A);
    } else if (selecionada) {
      corBorda = const Color(0xFF4A9EFF);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          if (alt.eliminada || questao.respondida) return;
          onSelecionarAlternativa?.call(alt);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: corBorda, width: selecionada ? 1.5 : 2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selecionada ? Icons.radio_button_checked : Icons.radio_button_off,
                color: alt.eliminada
                    ? const Color(0xFF4A6A8A)
                    : (selecionada ? corBorda : const Color(0xFF4A6A8A)),
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  alt.texto,
                  style: TextStyle(
                    color: alt.eliminada ? const Color(0xFF4A6A8A) : Colors.white,
                    fontSize: 14,
                    decoration:
                        alt.eliminada ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
              ),
              if (mostrarEliminar && !questao.respondida)
                GestureDetector(
                  onTap: () => onEliminarAlternativa?.call(alt),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.close, color: Color(0xFF4A6A8A), size: 18),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
