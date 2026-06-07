import 'package:flutter/material.dart';

import 'package:thinker_prototipo/homepage.dart';
import 'package:thinker_prototipo/thinker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/thinker',
      routes:{
        '/thinker': (context) => Thinker(),
        '/homepage':(context) => Homepage(),
      },
      
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
       debugShowCheckedModeBanner: false,
        locale: Locale('pt', 'BR'),

      supportedLocales: [
        Locale('pt', 'BR'),
      ],

      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Thinker()
    );
  }
}

