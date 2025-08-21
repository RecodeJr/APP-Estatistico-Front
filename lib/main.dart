import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'bemvindo_page.dart'; // ajuste o nome conforme o seu arquivo

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // garante que Flutter foi inicializado
  await dotenv.load(fileName: ".env");       // carrega variáveis de ambiente
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APP Estatístico',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const BemVindoPage(), // sua tela inicial
    );
  }
}
