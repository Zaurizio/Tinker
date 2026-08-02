import 'package:flutter/material.dart';

class Desempenho extends StatelessWidget {
  Desempenho({super.key});

  final List<String> feitos = [
    "12 questões de Matemática",
    "4 questões de História",
    "1 simulado concluído",
  ];

  final List<String> erros = [
    "Polígonos",
    "Química orgânica",
    "Biologia",
  ];

  final List<String> acertos = [
    "Geopolítica",
    "Termodinâmica",
    "Cartografia",
  ];

  final List<String> aprimorar = [
    "Melhorar em Português",
    "Semelhança de triângulos",
    "Química geral",
  ];

  Widget cartao({
    required String titulo,
    required IconData icone,
    required Color corIcone,
    required Color corFundo,
    required List<String> itens,
    required IconData iconeItem,
    required Color corIconeItem,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF0F2744),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Color(0xFF1E3D5C), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: corFundo,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icone, color: corIcone, size: 16),
              ),
              SizedBox(width: 10),
              Text(titulo,
                  style: TextStyle(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 12),
          Divider(color: Color(0xFF1E3D5C), height: 1),
          SizedBox(height: 10),
          ...itens.map(
            (item) => Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(iconeItem, color: corIconeItem, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(item,
                        style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        ],
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

              Text('Desempenho',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              Text('Acompanhe sua evolução nos estudos',
                  style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),

              SizedBox(height: 20),

             
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Color(0xFF0F2744),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF1E3D5C), width: 0.5),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.bolt_rounded, color: Color(0xFFFFB74D), size: 24),
                          SizedBox(height: 6),
                          Text('7',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('dias seguidos',
                              style: TextStyle(color: Color(0xFF8AABCC), fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Color(0xFF0F2744),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF1E3D5C), width: 0.5),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline, color: Color(0xFF4ABA8A), size: 24),
                          SizedBox(height: 6),
                          Text('16',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('questões feitas',
                              style: TextStyle(color: Color(0xFF8AABCC), fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Color(0xFF0F2744),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF1E3D5C), width: 0.5),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.emoji_events_outlined, color: Color(0xFF4A9EFF), size: 24),
                          SizedBox(height: 6),
                          Text('1',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('simulado feito',
                              style: TextStyle(color: Color(0xFF8AABCC), fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 14),

             
              cartao(
                titulo: 'Feitos da semana',
                icone: Icons.calendar_today_outlined,
                corIcone: Color(0xFF4A9EFF),
                corFundo: Color(0xFF1A3A6A),
                itens: feitos,
                iconeItem: Icons.check_circle_outline,
                corIconeItem: Color(0xFF4ABA8A),
              ),

              SizedBox(height: 12),

              
              Row(
                children: [
                  Expanded(
                    child: cartao(
                      titulo: 'Erros',
                      icone: Icons.cancel_outlined,
                      corIcone: Color(0xFFE05C6A),
                      corFundo: Color(0xFF3A1520),
                      itens: erros,
                      iconeItem: Icons.close,
                      corIconeItem: Color(0xFFE05C6A),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: cartao(
                      titulo: 'Acertos',
                      icone: Icons.check_circle_outlined,
                      corIcone: Color(0xFF4ABA8A),
                      corFundo: Color(0xFF0F3A2A),
                      itens: acertos,
                      iconeItem: Icons.check,
                      corIconeItem: Color(0xFF4ABA8A),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

             
              cartao(
                titulo: 'Pontos a melhorar',
                icone: Icons.trending_up_rounded,
                corIcone: Color(0xFFFFB74D),
                corFundo: Color(0xFF3A2A0A),
                itens: aprimorar,
                iconeItem: Icons.arrow_right_rounded,
                corIconeItem: Color(0xFFFFB74D),
              ),

              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}