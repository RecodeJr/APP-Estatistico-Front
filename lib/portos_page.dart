import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_estatistico_novo/ask_page.dart';
import 'package:app_estatistico_novo/login_page.dart';

class Porto {
  final int id;
  final String nome;
  final String descricao;
  final int dificuldadeId;
  final bool? publicado;

  Porto({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.dificuldadeId,
    required this.publicado,
  });

  factory Porto.fromJson(Map<String, dynamic> json) {
    return Porto(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      dificuldadeId: json['dificuldadeId'],
      publicado: json['publicado'],
    );
  }
}

class PortosPage extends StatefulWidget {
  const PortosPage({super.key});

  @override
  State<PortosPage> createState() => _PortosPageState();
}

class _PortosPageState extends State<PortosPage> {
  List<Porto> _portos = [];
  bool _carregando = true;
  var portoPendente;
  var portoPendenteNome;
  final String porto = '${dotenv.env['API_URL']}/user/port';

  @override
  void initState() {
    super.initState();
    _buscarPortos();
  }

  Future<void> _buscarPortos() async {
    setState(() {
      _carregando = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('Token não encontrado');
    }
    final response = await http.get(
      Uri.parse(porto),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      final jsonList = jsonData['data'] as List<dynamic>;

      if (jsonData['data1'] != null && jsonData['data1'].isNotEmpty) {
        portoPendente = jsonData['data1'][0]['portoId'];
        portoPendenteNome = jsonData['data1'][0]['nome'];
      }

      final portos = jsonList.map((json) => Porto.fromJson(json)).toList();
      setState(() {
        _portos = portos;
        _carregando = false;
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
      throw Exception('Erro ao buscar portos: ${response.statusCode}');
    }
  }

  _iniciarPorto(context, porto) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response_ = await http.get(
      Uri.parse('${dotenv.env['API_URL']}/user/pendingport'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response_.statusCode == 404) {
      final url = 'https://backend-railway-production-0456.up.railway.app/user/port/startport';
      final headers = {'Authorization': 'Bearer $token'};
      final Map<String, dynamic> postData = {'portoId': '${porto.id}'};
      portoPendente = porto.id;
      portoPendenteNome = porto.nome;

      final response =
      await http.post(Uri.parse(url), headers: headers, body: postData);
      if (response.statusCode == 201) {
        final resultado = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaginaPerguntas(),
          ),
        );

        if (resultado == 1) {
          _buscarPortos();
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
      }
    } else if (response_.statusCode == 401) {
      SharedPreferences _sharedPreferences =
      await SharedPreferences.getInstance();
      await _sharedPreferences.remove('token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
      );
    } else if (porto.id == portoPendente) {
      final resultado = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaginaPerguntas(),
        ),
      );
      if (resultado == 1) {
        _buscarPortos();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('O porto ${portoPendenteNome} está pendente'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Portos'),
      ),
      body: _carregando
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/telas_referencias/portos_niveis.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
            ),
            itemCount: _portos.length,
            itemBuilder: (context, index) {
              final porto = _portos[index];
              return InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: Text('${porto.nome}'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text('${porto.descricao}'),
                              Text(
                                porto.dificuldadeId == 1
                                    ? 'Fácil'
                                    : porto.dificuldadeId == 2
                                    ? 'Médio'
                                    : 'Difícil',
                                style: TextStyle(color: Colors.amber),
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Iniciar Porto'),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              _iniciarPorto(context, porto);
                            },
                          ),
                          TextButton(
                            child: Text('Fechar'),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width * 0.05),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius:
                        MediaQuery.of(context).size.height * 0.070,
                        backgroundColor: Colors.orange[500]!.withOpacity(
                            0.7),
                        child: Icon(
                          Icons.directions_boat_filled_rounded,
                          size: MediaQuery.of(context).size.height * 0.1,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                          height:
                          MediaQuery.of(context).size.height * 0.01),
                      Text(
                        '${porto.nome}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontFamily: 'Fredoka',
                          fontSize: MediaQuery.of(context).size.height *
                              0.026,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}