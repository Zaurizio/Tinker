import 'package:flutter/material.dart';
import 'package:tinker/bottombar/game.dart';
import 'package:tinker/bottombar/perfil.dart';
import 'package:tinker/bottombar/home.dart';
import 'package:tinker/paginas/desempenho.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    if (index == 2) {

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GameTab()),
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    Home(),
    Perfil(),
    GameTab(),
    Desempenho(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0D1B2A),
        selectedItemColor: const Color(0xFF4A9EFF),
        unselectedItemColor: const Color(0xFF4A6A8A),
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.games), label: 'Game'),
        ],
      ),
    );
  }
}