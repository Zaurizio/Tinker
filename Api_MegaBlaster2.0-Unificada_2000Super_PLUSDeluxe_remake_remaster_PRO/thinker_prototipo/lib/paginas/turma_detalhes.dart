import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tinker/Models/turma_model.dart';
import 'package:tinker/Models/membro_turma_model.dart';
import 'package:tinker/Models/publicacao_simulado_model.dart';
import 'package:tinker/Models/simulado_model.dart';
import 'package:tinker/Services/turma_service.dart';
import 'package:tinker/Services/turma_simulado_service.dart';
import 'package:tinker/Services/simulado_service.dart';
import 'package:tinker/Services/sessao_atual.dart';
import 'package:tinker/paginas/Simulado/publicacao_simulado_detalhe.dart';
import 'package:tinker/paginas/Simulado/simulado_detalhes.dart';

const List<List<Color>> gradientesTurma = [
  [Color(0xFF1C4E80), Color(0xFF2C9AE6)],
  [Color(0xFF0F6B52), Color(0xFF4ABA8A)],
  [Color(0xFF2A3A8A), Color(0xFF5C6FE0)],
  [Color(0xFF6A2A8A), Color(0xFFB07AE0)],
  [Color(0xFF8A5A1A), Color(0xFFE0A45C)],
];

List<Color> gradienteDaTurma(String codigo) =>
    gradientesTurma[codigo.hashCode.abs() % gradientesTurma.length];

class TurmaDetalhes extends StatefulWidget {
  final TurmaModel turma;

  const TurmaDetalhes({super.key, required this.turma});

  @override
  State<TurmaDetalhes> createState() => _TurmaDetalhesState();
}

class _TurmaDetalhesState extends State<TurmaDetalhes> {
  bool carregando = true;
  String? erro;
  List<MembroTurmaModel> membros = [];

  @override
  void initState() {
    super.initState();
    _carregarMembros();
  }

  Future<void> _carregarMembros() async {
    setState(() => carregando = true);

    try {
      final lista = await buscarMembros(widget.turma.codigo);
      setState(() {
        membros = lista;
        carregando = false;
      });
    } catch (e) {
      setState(() {
        erro = 'Não foi possível carregar os membros.';
        carregando = false;
      });
    }
  }

  void _sairOuRemover() async {
    final ehProfessor = SessaoAtual.ehProfessor;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F2744),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(ehProfessor ? 'Desativar turma' : 'Sair da turma',
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Text(
          ehProfessor
              ? 'Isso desativa a turma pra todo mundo. Tem certeza?'
              : 'Você vai deixar de fazer parte dessa turma. Tem certeza?',
          style: const TextStyle(color: Color(0xFF8AABCC), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8AABCC))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar', style: TextStyle(color: Color(0xFFE05C6A))),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      if (ehProfessor) {
        await desativarTurma(widget.turma.codigo);
      } else {
        await sairDaTurma(widget.turma.codigo);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Erro ao processar solicitação.')));
    }
  }

  void _removerAluno(MembroTurmaModel membro) async {
    try {
      await removerMembro(widget.turma.codigo, membro.email);
      _carregarMembros();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Erro ao remover aluno.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        body: SafeArea(
          child: Column(
            children: [
              _Header(turma: widget.turma, onSairOuRemover: _sairOuRemover),
              const _AbasTurma(),
              Expanded(
                child: TabBarView(
                  children: [
                    _AbaSimulados(codTurma: widget.turma.codigo),
                    _AbaMembros(
                      carregando: carregando,
                      erro: erro,
                      membros: membros,
                      podeRemover: SessaoAtual.ehProfessor,
                      onRemover: _removerAluno,
                    ),
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
  final TurmaModel turma;
  final VoidCallback onSairOuRemover;
  const _Header({required this.turma, required this.onSairOuRemover});

  @override
  Widget build(BuildContext context) {
    final gradiente = gradienteDaTurma(turma.codigo);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradiente,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                ),
              ),
              GestureDetector(
                onTap: onSairOuRemover,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  child: Icon(
                    SessaoAtual.ehProfessor ? Icons.delete_outline : Icons.logout,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.18),
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                ),
                child: const Icon(Icons.groups_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      turma.nome,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Prof. ${turma.criadorNome} • código ${turma.codigo}',
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
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
        labelColor: Colors.white,
        unselectedLabelColor: Color(0xFF8AABCC),
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: 'Simulados'),
          Tab(text: 'Membros'),
        ],
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String subtitulo;

  const _EstadoVazio({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, color: const Color(0xFF4A6A8A), size: 40),
            const SizedBox(height: 12),
            Text(titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF4A6A8A), fontSize: 14)),
            const SizedBox(height: 4),
            Text(subtitulo,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF4A6A8A), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _AbaSimulados extends StatefulWidget {
  final String codTurma;
  const _AbaSimulados({required this.codTurma});

  @override
  State<_AbaSimulados> createState() => _AbaSimuladosState();
}

class _AbaSimuladosState extends State<_AbaSimulados> {
  bool carregando = true;
  String? erro;
  List<PublicacaoSimulado> publicacoes = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => carregando = true);
    try {
      final lista = await listarSimuladosDaTurma(widget.codTurma);
      setState(() {
        publicacoes = lista;
        carregando = false;
      });
    } catch (e) {
      setState(() {
        erro = 'Não foi possível carregar os simulados desta turma.';
        carregando = false;
      });
    }
  }

  Future<void> _despublicar(PublicacaoSimulado p) async {
    try {
      await despublicarSimulado(widget.codTurma, p.idPublicacao);
      _carregar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Erro ao despublicar.')));
    }
  }

  void _abrirSeletorDeSimulados() {
    List<SimuladoResumo> disponiveis = [];
    bool carregandoModal = true;
    String? erroModal;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F2744),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> carregarModal() async {
              try {
                final meus = await buscarSimulados();
                final jaPublicadosIds = publicacoes.map((p) => p.simuladoId).toSet();
                setModalState(() {
                  disponiveis =
                      meus.where((s) => !jaPublicadosIds.contains(s.id)).toList();
                  carregandoModal = false;
                });
              } catch (e) {
                setModalState(() {
                  erroModal = 'Não foi possível carregar seus simulados.';
                  carregandoModal = false;
                });
              }
            }

            if (carregandoModal && disponiveis.isEmpty && erroModal == null) {
              carregarModal();
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Publicar simulado',
                      style: TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  if (carregandoModal)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                          child: CircularProgressIndicator(color: Color(0xFF4A9EFF))),
                    )
                  else if (erroModal != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(erroModal!,
                          style: const TextStyle(color: Color(0xFFE05C6A), fontSize: 13)),
                    )
                  else if (disponiveis.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('Você não tem mais simulados pra publicar aqui.',
                          style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),
                    )
                  else
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: disponiveis.map((s) {
                          return GestureDetector(
                            onTap: () async {
                              try {
                                await publicarSimulado(widget.codTurma, s.id);
                                if (!mounted) return;
                                Navigator.pop(ctx);
                                _carregar();
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Erro ao publicar.')));
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D1B2A),
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: const Color(0xFF1E3D5C), width: 0.5),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(s.titulo,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14)),
                                  ),
                                  const Icon(Icons.add_circle_outline,
                                      color: Color(0xFF4A9EFF), size: 20),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4A9EFF)));
    }

    if (erro != null) {
      return Center(child: Text(erro!, style: const TextStyle(color: Color(0xFFE05C6A))));
    }

    return Stack(
      children: [
        publicacoes.isEmpty
            ? const _EstadoVazio(
                icone: Icons.quiz_outlined,
                titulo: 'Nenhum simulado publicado nesta turma ainda.',
                subtitulo: 'Se você for o professor, use o botão + pra publicar um.',
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                children: publicacoes.map((p) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SessaoAtual.ehProfessor
                              ? SimuladoDetalhe(simuladoId: p.simuladoId)
                              : PublicacaoSimuladoDetalhe(
                                  codTurma: widget.codTurma,
                                  idPublicacao: p.idPublicacao,
                                  titulo: p.titulo,
                                ),
                        ),
                      ).then((_) => _carregar());
                    },
                    child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2744),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E3D5C), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A3A6A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.quiz_outlined,
                              color: Color(0xFF4A9EFF), size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.titulo,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 3),
                              Text(
                                  'Publicado em ${p.dataPublicacao.day.toString().padLeft(2, '0')}/${p.dataPublicacao.month.toString().padLeft(2, '0')}/${p.dataPublicacao.year}',
                                  style: const TextStyle(
                                      color: Color(0xFF8AABCC), fontSize: 12)),
                            ],
                          ),
                        ),
                        if (SessaoAtual.ehProfessor)
                          GestureDetector(
                            onTap: () => _despublicar(p),
                            child: const Icon(Icons.close, color: Color(0xFF4A6A8A), size: 18),
                          ),
                      ],
                    ),
                    ),
                  );
                }).toList(),
              ),
        if (SessaoAtual.ehProfessor)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'publicarSimulado',
              backgroundColor: const Color(0xFF1A4A8A),
              foregroundColor: const Color(0xFF4A9EFF),
              onPressed: _abrirSeletorDeSimulados,
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }
}

class _AbaMembros extends StatelessWidget {
  final bool carregando;
  final String? erro;
  final List<MembroTurmaModel> membros;
  final bool podeRemover;
  final void Function(MembroTurmaModel) onRemover;

  const _AbaMembros({
    required this.carregando,
    required this.erro,
    required this.membros,
    required this.podeRemover,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4A9EFF)));
    }

    if (erro != null) {
      return Center(child: Text(erro!, style: const TextStyle(color: Color(0xFFE05C6A))));
    }

    if (membros.isEmpty) {
      return const _EstadoVazio(
        icone: Icons.person_outline,
        titulo: 'Nenhum aluno nessa turma ainda.',
        subtitulo: 'Compartilhe o código da turma pra alguém entrar.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Membros',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        const Text('Alunos participantes desta turma',
            style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),
        const SizedBox(height: 16),
        ...membros.map((m) {
          Uint8List? bytesFoto;
          if (m.fotoBase64 != null) {
            try {
              bytesFoto = base64Decode(m.fotoBase64!);
            } catch (_) {
              bytesFoto = null;
            }
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F2744),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E3D5C), width: 2),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF1A3A6A),
                  backgroundImage: bytesFoto != null ? MemoryImage(bytesFoto) : null,
                  child: bytesFoto == null
                      ? const Icon(Icons.person, color: Color(0xFF4A9EFF), size: 18)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(m.nomeCompleto.isNotEmpty ? m.nomeCompleto : m.email,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                ),
                if (podeRemover)
                  GestureDetector(
                    onTap: () => onRemover(m),
                    child: const Icon(Icons.close, color: Color(0xFF4A6A8A), size: 18),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}