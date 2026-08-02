import 'package:flutter/material.dart';
import 'package:tinker/Classes/info.dart';
import 'package:tinker/drawer.dart';

class Contato extends StatefulWidget {
  const Contato({super.key});

  @override
  State<Contato> createState() => _ContatoState();
}

class _ContatoState extends State<Contato> {
  final nomeCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final numCtrl = TextEditingController();
  final msgCtrl = TextEditingController();

void Mostrar(){
  listaMensagem.forEach((Mensagem m){
    print("nome:" + m.nomeF);
    print("email:" + m.emailU);
    print("Numero:" + m.numC.toString());
    print("Mensagem:" + m.msg);
  
  });
}

  List<Mensagem> listaMensagem = [];

  Widget campoContato(TextEditingController ctrl, String label, String hint,
      {int maxLines = 1, TextInputType teclado = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
        SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,

          keyboardType: teclado,
          style: TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Color(0xFF4A6A8A), fontSize: 13),
            filled: true,
            fillColor: Color(0xFF0D1B2A),
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),

            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFF1E3D5C), width: 0.5)),


            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFF1E3D5C), width: 0.5)),


            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFF4A9EFF), width: 1)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1B2A),
      drawer: MeuDrawer(),
      appBar: AppBar(
         backgroundColor: Color(0xFF0D1B2A),
         iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),

             
              Row(
                children: [
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

              Text('Fale conosco',
                  style: TextStyle(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              Text('Estamos aqui para ajudar! Preencha o formulário abaixo e nossa equipe entrará em contato.',
                  style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),

              SizedBox(height: 20),

              
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF0F2744),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Color(0xFF1E3D5C), width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    campoContato(nomeCtrl, 'Seu nome', 'Digite seu nome'),
                    SizedBox(height: 16),


                    campoContato(emailCtrl, 'Seu e-mail', 'Digite seu e-mail',
                        teclado: TextInputType.emailAddress),
                    SizedBox(height: 16),

                    campoContato(numCtrl, 'Número de contato', 'Digite seu número de contato',
                        teclado: TextInputType.phone),
                    SizedBox(height: 16),

                    campoContato(msgCtrl, 'Mensagem', 'Escreva sua mensagem aqui...',
                        maxLines: 5),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1A56DB),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (nomeCtrl.text.isEmpty || numCtrl.text.isEmpty) return;
                          Mensagem m = Mensagem(
                            nomeCtrl.text,
                            emailCtrl.text,
                            int.tryParse(numCtrl.text) ?? 0,
                            msgCtrl.text,

                          );

                          setState(() {
                            listaMensagem.add(m);
                            nomeCtrl.clear();
                            emailCtrl.clear();
                            numCtrl.clear();
                            msgCtrl.clear();
                          });
                          Mostrar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Mensagem enviada com sucesso!'),
                              backgroundColor: Color(0xFF0F3A2A),
                            ),
                          );
                        },
                        child: Text('Enviar mensagem',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}