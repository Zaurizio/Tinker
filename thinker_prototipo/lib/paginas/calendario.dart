import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tinker/Models/evento_calendario_model.dart';
import 'package:tinker/Services/calendario_service.dart';
import 'package:tinker/Services/api_client.dart';

const Map<String, Color> coresDisponiveis = {
  '#4A9EFF': Color(0xFF4A9EFF),
  '#4ABA8A': Color(0xFF4ABA8A),
  '#E05C6A': Color(0xFFE05C6A),
  '#FFB74D': Color(0xFFFFB74D),
  '#B07AE0': Color(0xFFB07AE0),
};

Color corDoEvento(String? hex) {
  return coresDisponiveis[hex] ?? const Color(0xFF4A9EFF);
}

const Map<String, String> recorrenciasDisponiveis = {
  'NENHUMA': 'Não repetir',
  'DIARIA': 'Diariamente',
  'SEMANAL': 'Semanalmente',
  'MENSAL': 'Mensalmente',
};

class Calendario extends StatefulWidget {
  const Calendario({super.key});

  @override
  State<Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  List<EventoCalendario> eventos = [];
  bool carregando = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    _carregarEventos();
  }

  Future<void> _carregarEventos() async {
    setState(() => carregando = true);

    try {
      final dados = await buscarEventos();
      setState(() {
        eventos = dados;
        carregando = false;
      });
    } catch (e) {
      setState(() {
        erro = 'Não foi possível carregar os prazos.';
        carregando = false;
      });
    }
  }

  bool _mesmoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _abrirNovoEventoDialog() {
    final tituloCtrl = TextEditingController();
    DateTime data = selectedDay ?? DateTime.now();
    bool diaInteiro = true;
    TimeOfDay? horaInicio;
    TimeOfDay? horaFim;
    String corSelecionada = '#4A9EFF';
    String recorrenciaSelecionada = 'NENHUMA';
    final repeticoesCtrl = TextEditingController(text: '4');
    final disciplinaCtrl = TextEditingController();
    final conteudoCtrl = TextEditingController();
    final descricaoCtrl = TextEditingController();
    bool mostrarDetalhes = false;
    bool salvando = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          Future<void> escolherData() async {
            final escolhida = await showDatePicker(
              context: context,
              initialDate: data,
              firstDate: DateTime(2020),
              lastDate: DateTime(2035),
              builder: (context, child) => Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                      primary: Color(0xFF3A7BD5), surface: Color(0xFF1A2E45)),
                ),
                child: child!,
              ),
            );
            if (escolhida != null) setDialogState(() => data = escolhida);
          }

          Future<void> escolherHora({required bool ehInicio}) async {
            final escolhida = await showTimePicker(
              context: context,
              initialTime: (ehInicio ? horaInicio : horaFim) ?? TimeOfDay.now(),
              builder: (context, child) => Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                      primary: Color(0xFF3A7BD5), surface: Color(0xFF1A2E45)),
                ),
                child: child!,
              ),
            );
            if (escolhida == null) return;
            setDialogState(() {
              if (ehInicio) {
                horaInicio = escolhida;
              } else {
                horaFim = escolhida;
              }
            });
          }

          String formatarData(DateTime d) =>
              '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

          return AlertDialog(
            backgroundColor: const Color(0xFF0F2744),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: const Text('Novo prazo',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Título', style: TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: tituloCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ex: Entrega do trabalho',
                      hintStyle: const TextStyle(color: Color(0xFF4A6A8A), fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFF0D1B2A),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: escolherData,
                    child: _campoValor('Data', formatarData(data)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: diaInteiro,
                        onChanged: (v) => setDialogState(() => diaInteiro = v ?? true),
                        activeColor: const Color(0xFF3A7BD5),
                      ),
                      const Text('Dia inteiro', style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                  if (!diaInteiro) ...[
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => escolherHora(ehInicio: true),
                            child: _campoValor(
                                'Hora início', horaInicio?.format(context) ?? 'Selecionar'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => escolherHora(ehInicio: false),
                            child: _campoValor(
                                'Hora fim', horaFim?.format(context) ?? 'Selecionar'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text('Repetir', style: TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1B2A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: recorrenciaSelecionada,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF0F2744),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        items: recorrenciasDisponiveis.entries
                            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                            .toList(),
                        onChanged: (v) =>
                            setDialogState(() => recorrenciaSelecionada = v ?? 'NENHUMA'),
                      ),
                    ),
                  ),
                  if (recorrenciaSelecionada != 'NENHUMA') ...[
                    const SizedBox(height: 16),
                    const Text('Quantas vezes',
                        style: TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: repeticoesCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF0D1B2A),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text('Cor', style: TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: coresDisponiveis.entries.map((e) {
                      final selecionada = corSelecionada == e.key;
                      return GestureDetector(
                        onTap: () => setDialogState(() => corSelecionada = e.key),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: e.value,
                            shape: BoxShape.circle,
                            border: selecionada
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => setDialogState(() => mostrarDetalhes = !mostrarDetalhes),
                    child: Row(
                      children: [
                        Icon(
                          mostrarDetalhes ? Icons.expand_less : Icons.expand_more,
                          color: const Color(0xFF8AABCC),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        const Text('Disciplina, conteúdo e descrição (opcional)',
                            style: TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
                      ],
                    ),
                  ),
                  if (mostrarDetalhes) ...[
                    const SizedBox(height: 10),
                    _campoTexto(disciplinaCtrl, 'Disciplina', 'Ex: Matemática'),
                    const SizedBox(height: 10),
                    _campoTexto(conteudoCtrl, 'Conteúdo', 'Ex: Funções do 2º grau'),
                    const SizedBox(height: 10),
                    _campoTexto(descricaoCtrl, 'Descrição', 'Ex: Trazer a calculadora'),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: salvando ? null : () => Navigator.pop(ctx),
                child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8AABCC))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A4A8A),
                  foregroundColor: const Color(0xFF4A9EFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: salvando
                    ? null
                    : () async {
                        if (tituloCtrl.text.trim().isEmpty) return;
                        setDialogState(() => salvando = true);

                        try {
                          await criarEvento(
                            titulo: tituloCtrl.text.trim(),
                            data: data,
                            horarioInicio: horaInicio,
                            horarioFim: horaFim,
                            diaInteiro: diaInteiro,
                            cor: corSelecionada,
                            recorrencia: recorrenciaSelecionada,
                            repeticoes: recorrenciaSelecionada == 'NENHUMA'
                                ? null
                                : int.tryParse(repeticoesCtrl.text.trim()),
                            disciplina: disciplinaCtrl.text,
                            conteudo: conteudoCtrl.text,
                            descricao: descricaoCtrl.text,
                          );

                          if (!mounted) return;
                          Navigator.pop(ctx);
                          _carregarEventos();
                        } on ApiException catch (e) {
                          setDialogState(() => salvando = false);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(e.mensagem)));
                        } catch (e) {
                          setDialogState(() => salvando = false);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Erro ao salvar prazo.')),
                          );
                        }
                      },
                child: Text(salvando ? 'Salvando...' : 'Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _campoTexto(TextEditingController ctrl, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF8AABCC), fontSize: 11)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF4A6A8A), fontSize: 12),
            filled: true,
            fillColor: const Color(0xFF0D1B2A),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _campoValor(String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF8AABCC), fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(valor, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
      ],
    );
  }

  Future<void> _removerEvento(EventoCalendario evento) async {
    try {
      await removerEvento(evento.id);
      _carregarEventos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Erro ao remover prazo.')));
    }
  }

  List<EventoCalendario> getEventosDoDia(DateTime dia) {
    return eventos.where((e) => _mesmoDia(e.data, dia)).toList();
  }

  List<EventoCalendario> eventosDoMes() {
    final lista = eventos
        .where((e) => e.data.month == focusedDay.month && e.data.year == focusedDay.year)
        .toList();
    lista.sort((a, b) => a.data.compareTo(b.data));
    return lista;
  }

  String _formatarDataExibicao(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A4A8A),
        foregroundColor: const Color(0xFF4A9EFF),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onPressed: _abrirNovoEventoDialog,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
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
                        border: Border.all(color: const Color(0xFF1E3D5C), width: 1),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF1A4A7A),
                    child: Icon(Icons.school, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text('TINKER',
                      style: TextStyle(
                          fontFamily: 'Stardom',
                          color: Colors.white,
                          fontSize: 25,
                          letterSpacing: 3)),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Calendário',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text('Organize seus prazos e atividades',
                  style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2744),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1E3D5C), width: 2),
                ),
                child: TableCalendar(
                  locale: 'pt_BR',
                  focusedDay: focusedDay,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2035, 12, 31),
                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: const {CalendarFormat.month: "Mês"},
                  selectedDayPredicate: (day) =>
                      selectedDay != null && _mesmoDia(selectedDay!, day),
                  eventLoader: (day) => getEventosDoDia(day),
                  onDaySelected: (sel, foc) {
                    setState(() {
                      selectedDay = sel;
                      focusedDay = foc;
                    });
                  },
                  onPageChanged: (foc) => setState(() => focusedDay = foc),
                  calendarStyle: const CalendarStyle(
                    outsideDaysVisible: true,
                    outsideTextStyle: TextStyle(color: Color(0xFF4A6A8A)),
                    defaultTextStyle: TextStyle(color: Colors.white),
                    weekendTextStyle: TextStyle(color: Color(0xFF4A9EFF)),
                    todayDecoration: BoxDecoration(color: Color(0xFF1A4A8A), shape: BoxShape.circle),
                    todayTextStyle: TextStyle(color: Colors.white),
                    selectedDecoration: BoxDecoration(color: Color(0xFF4A9EFF), shape: BoxShape.circle),
                    selectedTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    markerDecoration: BoxDecoration(color: Color(0xFF4A9EFF), shape: BoxShape.circle),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Color(0xFF8AABCC), fontSize: 12),
                    weekendStyle: TextStyle(color: Color(0xFF4A9EFF), fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text('PRAZOS DO MÊS',
                  style: TextStyle(color: Color(0xFF8AABCC), fontSize: 11, letterSpacing: 1.2)),
              const SizedBox(height: 10),
              Expanded(
                child: carregando
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A9EFF)))
                    : erro != null
                        ? Center(
                            child:
                                Text(erro!, style: const TextStyle(color: Color(0xFFE05C6A), fontSize: 13)))
                        : eventosDoMes().isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.calendar_today_outlined, color: Color(0xFF4A6A8A), size: 40),
                                    SizedBox(height: 12),
                                    Text('Nenhum prazo este mês',
                                        style: TextStyle(color: Color(0xFF4A6A8A), fontSize: 14)),
                                  ],
                                ),
                              )
                            : ListView(
                                children: eventosDoMes().map((item) {
                                  final cor = corDoEvento(item.cor);
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F2744),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFF1E3D5C), width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: cor.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.event, color: cor, size: 18),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item.titulo,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500)),
                                              const SizedBox(height: 3),
                                              Text(
                                                item.diaInteiro
                                                    ? _formatarDataExibicao(item.data)
                                                    : '${_formatarDataExibicao(item.data)} • ${item.horarioInicio ?? ''}${item.horarioFim != null ? ' - ${item.horarioFim}' : ''}',
                                                style: const TextStyle(
                                                    color: Color(0xFF8AABCC), fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => _removerEvento(item),
                                          child: const Icon(Icons.close,
                                              color: Color(0xFF4A6A8A), size: 18),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
