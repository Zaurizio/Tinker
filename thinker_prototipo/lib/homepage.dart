import 'package:flutter/material.dart';
import 'package:thinker_prototipo/bottombar/game.dart';
import 'package:thinker_prototipo/bottombar/perfil.dart';
import 'package:thinker_prototipo/bottombar/home.dart';
import 'package:thinker_prototipo/paginas/desempenho.dart';


class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

   int _selectedIndex = 0;
  void _navigateBottomBar(int index){
  setState(() {
    _selectedIndex = index;
  });
}


final List <Widget> _pages = [
Home(),
Perfil(),
Game(),
Desempenho(),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: 
     _pages[_selectedIndex],
     bottomNavigationBar: BottomNavigationBar(
      selectedItemColor: Colors.white,
      backgroundColor: const Color.fromARGB(255, 47, 128, 177),
            currentIndex: _selectedIndex,
            onTap: _navigateBottomBar,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label : 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label : 'Perfil'),
              BottomNavigationBarItem(icon: Icon(Icons.games), label : 'Game'),
            ],
          
          ),);
  }
}