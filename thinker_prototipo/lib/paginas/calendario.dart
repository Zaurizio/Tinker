
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendario extends StatefulWidget {
  const Calendario({super.key});

  @override
  State<Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  Map<String, List<String>> eventos = {};

  String formatarData(DateTime data) {
    String mes = data.month.toString().padLeft(2, '0');
    String dia = data.day.toString().padLeft(2, '0');
    return "${data.year}-$mes-$dia";
  }

  void mostrarModalAdicionarEvento() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF0F2744),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text("Novo Evento",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          cursorColor: Color(0xFF4A9EFF),
          style: TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: "Digite o evento...",
            hintStyle: TextStyle(color: Color(0xFF4A6A8A)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1E3D5C))),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4A9EFF))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: Color(0xFF8AABCC))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1A4A8A),
              foregroundColor: Color(0xFF4A9EFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () {
              if (selectedDay == null || controller.text.isEmpty) return;
              String chave = formatarData(selectedDay!);
              eventos.putIfAbsent(chave, () => []);
              eventos[chave]!.add(controller.text);
              setState(() {});
              Navigator.pop(context);
            },
            child: Text("Salvar"),
          ),
        ],
      ),
    );
  }

  List<String> getEventosDoDia(DateTime dia) {
    return eventos[formatarData(dia)] ?? [];
  }

  List<Map<String, String>> eventosDoMes() {
    List<Map<String, String>> lista = [];
    eventos.forEach((data, listaEventos) {
      DateTime dataConvertida = DateTime.parse(data);
      if (dataConvertida.month == focusedDay.month &&
          dataConvertida.year == focusedDay.year) {
        for (var evento in listaEventos) {
          lista.add({"data": data, "evento": evento});
        }
      }
    });
    lista.sort((a, b) => a["data"]!.compareTo(b["data"]!));
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1B2A),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF1A4A8A),
        foregroundColor: Color(0xFF4A9EFF),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onPressed: mostrarModalAdicionarEvento,
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
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

              Text('Calendário',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              Text('Organize seus eventos e compromissos',
                  style: TextStyle(color: Color(0xFF8AABCC), fontSize: 13)),

              SizedBox(height: 16),

              
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF0F2744),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Color(0xFF1E3D5C), width: 0.5),
                ),
                child: TableCalendar(
                  locale: 'pt_BR',
                  focusedDay: focusedDay,
                  firstDay: DateTime.utc(2026, 1, 1),
                  lastDay: DateTime.utc(2027, 12, 31),
                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: {CalendarFormat.month: "Mês"},
                  selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                  eventLoader: (day) => getEventosDoDia(day),
                  onDaySelected: (sel, foc) {
                    setState(() {
                      selectedDay = sel;
                      focusedDay = foc;
                    });
                  },
                  onPageChanged: (foc) => setState(() => focusedDay = foc),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: true,
                    outsideTextStyle: TextStyle(color: Color(0xFF4A6A8A)),
                    defaultTextStyle: TextStyle(color: Colors.white),
                    weekendTextStyle: TextStyle(color: Color(0xFF4A9EFF)),
                    todayDecoration: BoxDecoration(
                        color: Color(0xFF1A4A8A), shape: BoxShape.circle),


                    todayTextStyle: TextStyle(color: Colors.white),
                    selectedDecoration: BoxDecoration(
                        color: Color(0xFF4A9EFF), shape: BoxShape.circle),


                    selectedTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    markerDecoration: BoxDecoration(
                        color: Color.fromARGB(255, 40, 172, 233), shape: BoxShape.circle),
                  ),
                  
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Color(0xFF8AABCC), fontSize: 12),
                    weekendStyle: TextStyle(color: Color(0xFF4A9EFF), fontSize: 12),
                  ),
                ),
              ),

              SizedBox(height: 14),

             
              Text('EVENTOS DO MÊS',
                  style: TextStyle(color: Color(0xFF8AABCC), fontSize: 11, letterSpacing: 1.2)),
              SizedBox(height: 10),

              Expanded(
                child: eventosDoMes().isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                color: Color(0xFF4A6A8A), size: 40),
                            SizedBox(height: 12),
                            Text('Nenhum evento este mês',
                                style: TextStyle(color: Color(0xFF4A6A8A), fontSize: 14)),
                          ],
                        ),
                      )
                    : ListView(
                        children: eventosDoMes().map((item) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: Color(0xFF0F2744),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFF1E3D5C), width: 0.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1A3A6A),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.event, color: Color(0xFF4A9EFF), size: 18),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item["evento"]!,
                                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                                      SizedBox(height: 3),
                                      Text(item["data"]!,
                                          style: TextStyle(color: Color(0xFF8AABCC), fontSize: 12)),
                                    ],
                                  ),
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