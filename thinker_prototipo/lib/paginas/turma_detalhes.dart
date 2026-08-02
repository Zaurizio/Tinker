import 'package:flutter/material.dart';

class TurmaDetalhes extends StatelessWidget {
  final Map<String, String> turma;

  const TurmaDetalhes({super.key, required this.turma});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        body: SafeArea(
          child: Column(
            children: [
              _Header(turma: turma),
              const _AbasTurma(),
              const Expanded(
                child: TabBarView(
                  children: [
                    _AbaMural(),
                    _AbaAtividades(),
                    _AbaAlunos(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Map<String, String> turma;
  const _Header({required this.turma});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F2744),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    color: const Color(0xFF0D1B2A),
                    border: Border.all(color: const Color(0xFF1E3D5C), width: 0.5),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3A6A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  turma['materia'] ?? 'Sem matéria',
                  style: const TextStyle(color: Color(0xFF4A9EFF), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1A3A6A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.group_outlined, color: Color(0xFF4A9EFF), size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            turma['turma'] ?? 'Turma',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            '0 alunos · 0 atividades',
            style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _AbasTurma extends StatelessWidget {
  const _AbasTurma();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D1B2A),
      child: const TabBar(
        indicatorColor: Color(0xFF4A9EFF),
        labelColor: Color(0xFF4A9EFF),
        unselectedLabelColor: Color(0xFF8AABCC),
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: 'Mural'),
          Tab(text: 'Atividades'),
          Tab(text: 'Alunos'),
        ],
      ),
    );
  }
}



class _EstadoVazio extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final String textoBotao;

  const _EstadoVazio({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.textoBotao,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF4A6A8A), size: 48),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              subtitulo,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8AABCC), fontSize: 13),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2744),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1E3D5C), width: 0.5),
              ),
              child: Text(
                textoBotao,
                style: const TextStyle(color: Color(0xFF4A9EFF), fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AbaMural extends StatelessWidget {
  const _AbaMural();

  @override
  Widget build(BuildContext context) {
    return const _EstadoVazio(
      icon: Icons.campaign_outlined,
      titulo: 'Nenhum aviso publicado',
      subtitulo: 'Avisos e materiais compartilhados com a turma\naparecerão aqui.',
      textoBotao: 'Publicar aviso ',
    );
  }
}

class _AbaAtividades extends StatelessWidget {
  const _AbaAtividades();

  @override
  Widget build(BuildContext context) {
    return const _EstadoVazio(
      icon: Icons.assignment_outlined,
      titulo: 'Nenhuma atividade criada',
      subtitulo: 'Simulados e questões atribuídos a essa turma\naparecerão aqui.',
      textoBotao: 'Criar atividade ',
    );
  }
}

class _AbaAlunos extends StatelessWidget {
  const _AbaAlunos();

  @override
  Widget build(BuildContext context) {
    return const _EstadoVazio(
      icon: Icons.people_outline,
      titulo: 'Nenhum aluno adicionado',
      subtitulo: 'Convide alunos por código ou link para que\neles apareçam aqui.',
      textoBotao: 'Convidar alunos ',
    );
  }
}