import 'package:flutter/material.dart';

class Linhas extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2.5;
       canvas.drawLine(const Offset(75, 600), const Offset(80, 700),  paint);
        canvas.drawLine(const Offset(90, 600),  const Offset(285, 660), paint); 
        canvas.drawLine(const Offset(285, 660), const Offset(335, 530), paint); 
        canvas.drawLine(const Offset(325, 528), const Offset(233, 430), paint); 
        canvas.drawLine(const Offset(233, 445), const Offset(98, 500), paint); 
        canvas.drawLine(const Offset(100, 490), const Offset(60, 380),  paint); 
        canvas.drawLine(const Offset(70, 375),  const Offset(350, 350), paint); 
        canvas.drawLine(const Offset(340, 340), const Offset(340, 240), paint); 
        canvas.drawLine(const Offset(330, 253), const Offset(125, 300), paint); 
        canvas.drawLine(const Offset(125, 300), const Offset(105, 170),  paint);
        canvas.drawLine(const Offset(105, 170), const Offset(180, 80),  paint);

  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}