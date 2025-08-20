import 'dart:io';

import 'package:app_estatistico_novo/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Relatorios_page extends StatefulWidget {
  const Relatorios_page({super.key});
  @override
  _NovaTelaState createState() => _NovaTelaState();
}

class PortoRelatorio {
  final int id;
  final String nome;
  final int dificuldadeId;

  PortoRelatorio({
    required this.id,
    required this.nome,
    required this.dificuldadeId,
  });

  factory PortoRelatorio.fromJson(Map<String, dynamic> json) {
    return PortoRelatorio(
      id: json['id'],
      nome: json['nome'],
      dificuldadeId: json['dificuldadeId'],
    );
  }
}

class _NovaTelaState extends State<Relatorios_page> {
  List<PortoRelatorio> portos = [];

  @override
  void initState() {
    super.initState();
    fetchPortos(context);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Portos'),
      ),
      body: ListView.builder(
        itemCount: portos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(portos[index].nome),
            trailing: IconButton(
              icon: Icon(Icons.arrow_downward),
              onPressed: () async {
                // Aqui você pode chamar a função que faz a requisição ao backend
                await devolveRelatorio(portos[index].id);
              },
            ),
          );
        },
      ),
    );
  }

  // Requisições ao servidor

  Future<void> fetchPortos(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        print('Não há token disponível.');
        return;
      }

      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/admin/relatoriosPortos'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final jsonList = jsonData['data'] as List<dynamic>;

        setState(() {
          portos =
              jsonList.map((item) => PortoRelatorio.fromJson(item)).toList();
        });
      } else if (response.statusCode == 401) {
        SharedPreferences _sharedPreferences =
            await SharedPreferences.getInstance();
        await _sharedPreferences.remove('token');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      } else {
        // Se a chamada ao servidor não foi bem-sucedida, lance uma exceção.
        throw Exception('Falha ao carregar os portos');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> devolveRelatorio(int idRecebido) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        print('Não há token disponível.');
        return;
      }

      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/admin/relatorioPorto'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id': idRecebido,
        }),
      );

      if (response.statusCode == 200) {
        Directory dir = await getApplicationDocumentsDirectory();
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        File file = File('${dir.path}/relatorio.pdf');
        await file.writeAsBytes(response.bodyBytes);
        if (await file.exists()) {
          print('Arquivo baixado com sucesso');
          // Abrir o arquivo
          OpenFile.open(file.path);
        } else {
          print('Erro ao baixar o arquivo');
        }
      } else if (response.statusCode == 401) {
        SharedPreferences _sharedPreferences =
            await SharedPreferences.getInstance();
        await _sharedPreferences.remove('token');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      } else {
        throw Exception('Falha ao chamar a rota');
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
