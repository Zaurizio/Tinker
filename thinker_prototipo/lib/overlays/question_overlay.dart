import 'package:flutter/material.dart';
import 'package:tinker/data/question.dart';
import 'package:tinker/tinker_game.dart';

enum _OptionState { normal, correct, wrong }

class QuestionOverlay extends StatefulWidget {
  final TinkerGame game;
  const QuestionOverlay({super.key, required this.game});

  @override
  State<QuestionOverlay> createState() => _QuestionOverlayState();
}

class _QuestionOverlayState extends State<QuestionOverlay> {
  int? selectedIndex;
  bool answered = false;

  static const letters = ['A', 'B', 'C', 'D', 'E'];

  void _onOptionTap(int index, Question question) {
    if (answered) return;
    setState(() {
      selectedIndex = index;
      answered = true;
    });

    final correct = index == question.correctIndex;
    final delay = correct
        ? const Duration(milliseconds: 600)
        : const Duration(milliseconds: 1400);

    Future.delayed(delay, () {
      widget.game.resolveQuestion(correct);
    });
  }

  _OptionState _stateFor(int index, Question question) {
    if (!answered) return _OptionState.normal;
    if (index == question.correctIndex) return _OptionState.correct;
    if (index == selectedIndex) return _OptionState.wrong;
    return _OptionState.normal;
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.game.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    final media = MediaQuery.of(context);
    final safeHeight = media.size.height - media.padding.top - media.padding.bottom;
    final safeWidth = media.size.width - media.padding.left - media.padding.right;

    final maxW = (safeWidth * 0.94).clamp(300.0, 640.0);
    final maxH = (safeHeight * 0.82).clamp(360.0, 680.0);

    // Margens internas proporcionais ao tamanho da caixa, em vez de pixels fixos.
    final topCap = maxH * 0.28;
    final bottomCap = maxH * 0.085;
    final sideCap = maxW * 0.1;

    final optionHeight = (maxH * 0.10).clamp(44.0, 58.0);
    final questionFontSize = (maxW * 0.038).clamp(12.5, 15.0);
    final optionFontSize = (maxW * 0.034).clamp(11.5, 14.0);

    return Container(
      color: Colors.black.withOpacity(0.6),
      child: SafeArea(
        child: Center(
          child: SizedBox(
            width: maxW,
            height: maxH,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/UI/Pergaminho.9.png',
                  centerSlice: const Rect.fromLTRB(11, 20, 100, 170),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.none,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: topCap,
                    bottom: bottomCap,
                    left: sideCap,
                    right: sideCap,
                  ),
                  child: ClipRect(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: maxH * 0.36),
                          child: SingleChildScrollView(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.92),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFF5A3A1E), width: 2),
                              ),
                              child: Text(
                                question.text,
                                style: TextStyle(
                                  color: const Color(0xFF1A0E05),
                                  fontSize: questionFontSize,
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: maxH * 0.02),
                        Expanded(
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                for (int i = 0; i < question.options.length; i++)
                                  Padding(
                                    padding: EdgeInsets.only(bottom: maxH * 0.015),
                                    child: _OptionButton(
                                      letter: letters[i],
                                      text: question.options[i],
                                      state: _stateFor(i, question),
                                      height: optionHeight,
                                      fontSize: optionFontSize,
                                      onTap: () => _onOptionTap(i, question),
                                    ),
                                  ),
                                if (answered)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      selectedIndex == question.correctIndex
                                          ? 'Resposta correta!'
                                          : 'Resposta incorreta! Tente novamente.',
                                      style: TextStyle(
                                        color: selectedIndex ==
                                                question.correctIndex
                                            ? Colors.green.shade800
                                            : Colors.red.shade800,
                                        fontSize: optionFontSize,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String letter;
  final String text;
  final _OptionState state;
  final double height;
  final double fontSize;
  final VoidCallback onTap;

  const _OptionButton({
    required this.letter,
    required this.text,
    required this.state,
    required this.height,
    required this.fontSize,
    required this.onTap,
  });

  String get _assetPath => 'assets/images/UI/Alternativa$letter.png';

  Color? get _tint {
    switch (state) {
      case _OptionState.correct:
        return Colors.green.withOpacity(0.45);
      case _OptionState.wrong:
        return Colors.red.withOpacity(0.45);
      case _OptionState.normal:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned.fill(
                child: Image.asset(
                  _assetPath,
                  centerSlice: const Rect.fromLTRB(36, 8, 184, 56),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.none,
                ),
              ),
              if (_tint != null)
                Positioned.fill(
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    decoration: BoxDecoration(
                      color: _tint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              Positioned(
                left: 40,
                right: 10,
                child: Text(
                  text,
                  style: TextStyle(
                    color: const Color(0xFF1A0E05),
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}