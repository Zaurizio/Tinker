import 'package:flutter/material.dart';
import 'package:tinker/drawer.dart';

class Planos extends StatelessWidget {
  const Planos({super.key});

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

              Text('Escolha seu plano',
                  style: TextStyle(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              Text('Desbloqueie recursos exclusivos e aproveite uma experiência completa.',
                  style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),

              SizedBox(height: 24),

            
              cardPlano(
                imagem: 'assets/images/tinker_images/Pgratuito.png',
                nome: 'Plano Gratuito',
                descricao: 'Comece do jeito certo.\nIdeal para quem quer conhecer o Tinker\n e dar os primeiros passos na preparação para o vestibular.',
                descricao1: "-Crie seus próprios simulados manualmente",
                descricao2: "-Gere simulados automáticos (1 por mês)",
                descricao3: "-Apenas um simulado salvo",
                descricao4: "-Caso seja professor, pode criar apenas de uma turma",
                descricao5:"-Até 7 eventos diários por dia da semana" ,
                preco: 'R\$ 0,00',
                periodo: 'Para sempre',
                textoBotao: 'Continue gratuito',
                botaoPreenchido: false,
                destaque: false,
                onTap: () {},
                
              ),

              SizedBox(height: 12),

              
            

              SizedBox(height: 12),
                cardPlano(
                imagem: 'assets/images/tinker_images/Pestudantil.png',
                nome: 'Plano Estudantil (Premium)',
                descricao: 'A preparação completa para quem quer ir além.\nVoltado a estudantes que buscam desempenho máximo,\n dados detalhados e suporte personalizado.',
                descricao1: "Tudo do plano mensal",
                descricao2: "Criação automática de simulado ilimitada",
                descricao3: "Simulado salvos ilimitados",
                descricao4: "Caso seja professor, turmas ilimitadas",
                descricao5:"Eventos por dia da semana ilimitados" ,
                preco: 'R\$ 15,90',
                periodo: '/mês',
                textoBotao: 'Começar agora',
                botaoPreenchido: true,
                destaque: true,
                onTap: () {},
              ),

              SizedBox(height: 20),

              Center(
                child: Text('Cancele quando quiser. Sem compromisso.',
                    style: TextStyle(color: Color(0xFF4A6A8A), fontSize: 12)),
              ),

              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemBeneficio(String texto) {
    // remove o "-" inicial, caso exista, já que o ícone substitui esse marcador
    final textoLimpo = texto.startsWith('-') ? texto.substring(1) : texto;
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Color(0xFF4A9EFF), size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(textoLimpo,
                style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget cardPlano({
    required String imagem,
    required String nome,
    required String descricao,
    required String descricao1,
    required String descricao2,
    required String descricao3,
    required String descricao4,
    required String descricao5,
    required String preco,
    required String periodo,
    required String textoBotao,
    required bool botaoPreenchido,
    required bool destaque,
    required VoidCallback onTap,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF0F2744),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: destaque ? Color(0xFF4A9EFF) : Color(0xFF1E3D5C),
              width: destaque ? 2 : 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (destaque) SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(imagem, width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nome,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(descricao,
                            style: TextStyle(
                                color: Color(0xFF8AABCC), fontSize: 13, height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
              itemBeneficio(descricao1),
              itemBeneficio(descricao2),
              itemBeneficio(descricao3),
              itemBeneficio(descricao4),
              itemBeneficio(descricao5),
              SizedBox(height: 16),
              Divider(color: Color(0xFF1E3D5C), height: 1),
              SizedBox(height: 14),
              Row(

                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(preco,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),

                        SizedBox(width: 4),
                        Text(periodo,
                            style: TextStyle(
                                color: Color(0xFF8AABCC), fontSize: 13)),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(

                          backgroundColor: botaoPreenchido
                              ? Color(0xFF1A56DB)
                              : Colors.transparent,

                          foregroundColor: botaoPreenchido
                              ? Colors.white
                              : Color(0xFF4A9EFF),

                          side: botaoPreenchido
                              ? BorderSide.none
                              : BorderSide(color: Color(0xFF4A9EFF), width: 1),

                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,

                        ),
                        onPressed: onTap,
                        child: Text(textoBotao,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        
        if (destaque)
          Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF1A56DB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('MAIS POPULAR',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
              ),
            ),
          ),
      ],
    );
  }
}