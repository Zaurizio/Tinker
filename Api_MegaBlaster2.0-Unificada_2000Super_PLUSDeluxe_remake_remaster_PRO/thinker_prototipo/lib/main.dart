import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tinker/homepage.dart';
import 'package:tinker/thinker.dart';
import 'package:tinker/Services/sessao_atual.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final temSessaoSalva = await SessaoAtual.carregar();

  runApp(MyApp(iniciarLogado: temSessaoSalva));
}

class MyApp extends StatelessWidget {
  final bool iniciarLogado;
  const MyApp({super.key, required this.iniciarLogado});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Tinker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: iniciarLogado ? const Homepage() : const Thinker(),
    );
  }
}
