

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:thinker_prototipo/_comum/colors.dart';

class Calendario extends StatefulWidget {
  const Calendario({super.key});

  @override
  State<Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<String, List<String>> eventos = {};

  final text = TextStyle(color: Colors.white);

  final tituloContornado = Stack(
    alignment: Alignment.center,
    children: [
      Text(
        'Tinker',
        style: TextStyle(
          fontFamily: 'Stardom',
          fontSize: 45,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..color = Colors.black,
        ),
      ),
      Text(
        'Tinker',
        style: TextStyle(
          fontFamily: 'Stardom',
          fontSize: 45,
          color: Colors.white,
        ),
      ),
    ],
  );

  String _formatarData(DateTime data) {
  String mes = data.month.toString().padLeft(2, '0');
  String dia = data.day.toString().padLeft(2, '0');

  return "${data.year}-$mes-$dia";
}

  void _mostrarModalAdicionarEvento() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: minhasCores.azulE,
          title: Text("Novo Evento", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Digite o evento...",
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)
                
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color:Colors.white),
              )
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar",style: TextStyle(color: Colors.white),),
            ),
            ElevatedButton(
              onPressed: () {
                if (_selectedDay == null || controller.text.isEmpty) return;

                String chave = _formatarData(_selectedDay!);

                eventos.putIfAbsent(chave, () => []);
                eventos[chave]!.add(controller.text);

                setState(() {});
                Navigator.pop(context);
              },
              child: Text("Salvar",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),),
            ),
          ],
        );
      },
    );
  }

  List<String> _getEventosDoDia(DateTime dia) {
    return eventos[_formatarData(dia)] ?? [];
  }

  List<Map<String, String>> _eventosDoMes() {
    List<Map<String, String>> lista = [];

    eventos.forEach((data, listaEventos) {
      DateTime dataConvertida = DateTime.parse(data);

      if (dataConvertida.month == _focusedDay.month &&
          dataConvertida.year == _focusedDay.year) {
        for (var evento in listaEventos) {
          lista.add({
            "data": data,
            "evento": evento,
          });
        }
      }
    });

    lista.sort((a, b) => a["data"]!.compareTo(b["data"]!));

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/constelacao.png', fit: BoxFit.cover),
    Positioned(
 top: 50,
 left: 16,
  child:Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color:minhasCores.azul2C,
    ),
  child: IconButton(onPressed: (){
Navigator.pop(context);
  }, icon: Icon(Icons.arrow_back,color: Colors.white,)),
  ),
),
  Positioned(
    top: -50,
    left: 60,
    child:IgnorePointer(
    child: Image.asset('assets/images/logo.png',width: 300,)
    )
    ),
          Positioned(
            top: -50,
            left: 60,
            child: IgnorePointer(
              child: Image.asset('assets/images/logo.png', width: 300),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Center(child: tituloContornado),
                  SizedBox(height: 60),

                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: minhasCores.azulE,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TableCalendar(
                      locale: 'pt_BR',
                      focusedDay: _focusedDay,
                      firstDay: DateTime.utc(2026, 1, 1),
                      lastDay: DateTime.utc(2027, 12, 31),
                      calendarFormat: CalendarFormat.month,
                      availableCalendarFormats: const {
                        CalendarFormat.month: "Mês",
                      },
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      eventLoader: (day) => _getEventosDoDia(day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        markerDecoration: BoxDecoration(
                          color: minhasCores.azulClarinhoqsim,
                          shape: BoxShape.circle,
                        ),
                        defaultTextStyle: TextStyle(color: Colors.white),
                        weekendTextStyle:
                            TextStyle(color: minhasCores.pretoC),
                        todayDecoration: BoxDecoration(
                          color: minhasCores.azul2C,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: minhasCores.azulC,
                          shape: BoxShape.circle
                        )
                      ),
                      headerStyle: HeaderStyle(
                        titleTextStyle: TextStyle(color: Colors.white),
                        leftChevronIcon:
                            Icon(Icons.chevron_left, color: Colors.white),
                        rightChevronIcon:
                            Icon(Icons.chevron_right, color: Colors.white),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(color: Colors.white),
                        weekendStyle:
                            TextStyle(color: minhasCores.azul2C),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: minhasCores.azulE,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: _eventosDoMes().isEmpty
                          ? Center(
                              child: Text(
                                "Nenhum evento",
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                          : ListView(
                              children:
                                  _eventosDoMes().map((item) {
                                return Container(
                                  margin:
                                      EdgeInsets.symmetric(vertical: 5),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: minhasCores.azulC,
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.event,
                                          color: Colors.white),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item["evento"]!,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              item["data"]!,
                                              style: TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    
      floatingActionButton: FloatingActionButton(
        backgroundColor: minhasCores.azulC,
        onPressed: _mostrarModalAdicionarEvento,
        child: Icon(Icons.add),
      ),
    );
  }
}