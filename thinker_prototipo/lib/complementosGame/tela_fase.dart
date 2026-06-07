import 'package:flutter/material.dart';
import 'dart:async';

import 'package:thinker_prototipo/_comum/colors.dart';

class TelaFase extends StatefulWidget {
  final int numeroFase;
  final String pergunta;
  final List<String> alternativas;
  final int respostaCorreta; 
  final int tempoSegundos;

  const TelaFase({
    super.key,
    required this.numeroFase,
    required this.pergunta,
    required this.alternativas,
    required this.respostaCorreta,
    this.tempoSegundos = 30,
  });

  @override
  State<TelaFase> createState() => _TelaFaseState();
}

class _TelaFaseState extends State<TelaFase> {
  int? _respostaSelecionada;
  bool _respondeu = false;
  late int _tempoRestante;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tempoRestante = widget.tempoSegundos;
    _iniciarTimer();
  }

  void _iniciarTimer() {
    _timer = Timer.periodic( Duration(seconds: 1), (timer) {
      if (_tempoRestante <= 0) {
        timer.cancel();
        _mostrarResultado(false);
      } else {
        setState(() => _tempoRestante--);
      }
    });
  }

  void _responder(int index) {
    if (_respondeu) return;
    _timer?.cancel();
    setState(() {
      _respostaSelecionada = index;
      _respondeu = true;
    });

    Future.delayed( Duration(seconds: 1), () {
      _mostrarResultado(index == widget.respostaCorreta);
    });
  }

  void _mostrarResultado(bool acertou) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor:minhasCores.azul3C,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),),
        
        title: Text(
          acertou ? 'Correto!' : 'Errou!',
          textAlign: TextAlign.center,
          style:  TextStyle(color: Colors.white, fontSize: 24),
        ),
        content: Text(
          acertou
              ? 'Muito bem! Continue assim.'
              : 'A resposta correta era: ${_letra(widget.respostaCorreta)}',
          textAlign: TextAlign.center,
          style:TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: minhasCores.pretoC,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                     EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context); 
                Navigator.pop(context); 
              },
              child: Text('Voltar ao mapa',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  String _letra(int index) {
    return ['A', 'B', 'C', 'D'][index];
  }

  Color _corAlternativa(int index) {
    if (!_respondeu) return const Color(0xFF0d2137);
    if (index == widget.respostaCorreta) return Colors.green.shade700;
    if (index == _respostaSelecionada) return Colors.red.shade700;
    return const Color(0xFF0d2137);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progresso = _tempoRestante / widget.tempoSegundos;

    return Scaffold(
      body: Container(
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a3a5c), Color(0xFF2d6a9f)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:  EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

               
                Row(
                  children: [
                  
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding:  EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.close,
                            color: Colors.white, size: 28),
                      ),
                    ),
                    Spacer(),
                    
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Nível ${widget.numeroFase}',
                        style:TextStyle(
                          fontFamily:'Pixelada',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1a3a5c),
                        ),
                      ),
                    ),
                    Spacer(),
                   
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                         
                        ),
                        Text(
                          '$_tempoRestante',
                          style:  TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),

                 SizedBox(height: 12),

               
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progresso,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    color: progresso > 0.4 ? Colors.white : Colors.redAccent,
                  ),
                ),

               SizedBox(height: 20),

               
                Container(
                  width: double.infinity,
                  padding:  EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0d2137),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.pergunta,
                    style:  TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.5,
                    ),
                  ),
                ),

                 SizedBox(height: 24),

              
                ...List.generate(widget.alternativas.length, (index) {
                  return Padding(
                    padding:  EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => _responder(index),
                      child: AnimatedContainer(
                        duration:  Duration(milliseconds: 300),
                        padding:  EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: _corAlternativa(index),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _respostaSelecionada == index && !_respondeu
                                ? Colors.white
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                         
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white54, width: 2),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _letra(index),
                                style:  TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                             SizedBox(width: 16),
                           
                            Expanded(
                              child: Text(
                                widget.alternativas[index],
                                style:  TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}