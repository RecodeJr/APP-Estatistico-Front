import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Instituicao {
  final String id;
  final String nome;
  final String sigla;

  Instituicao({required this.id ,required this.nome, required this.sigla});

  factory Instituicao.fromJson(Map<String, dynamic> json) {
    return Instituicao(
      id: json['id'].toString(),
      nome: json['nome'],
      sigla: json['sigla'],
    );
  }
}

Future<List<Instituicao>> fetchInstituicoes() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final response = await http.get(
    Uri.parse('${dotenv.env['API_URL']}/admin/listarTodasInstituicoes'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((item) => Instituicao.fromJson(item)).toList();
  } else {
    throw Exception('Falha ao carregar instituições do backend');
  }
}

class InstituicoesScreen extends StatefulWidget {
  @override
  _InstituicoesScreenState createState() => _InstituicoesScreenState();
}

class _InstituicoesScreenState extends State<InstituicoesScreen> {
  late Future<List<Instituicao>> futureInstituicoes;
  final nomeController = TextEditingController();
  final siglaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureInstituicoes = fetchInstituicoes();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));

    return Scaffold(
      appBar: AppBar(
        title: Text('Instituições'),
      ),
      body: Center(
        child: FutureBuilder<List<Instituicao>>(
          future: futureInstituicoes,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final instituicao = snapshot.data![index];
                  return ListTile(
                    title: Text(instituicao.nome),
                    subtitle: Text(instituicao.sigla),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        nomeController.text = instituicao.nome;
                        siglaController.text = instituicao.sigla;

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Editar Instituição'),
                              content: Column(
                                children: <Widget>[
                                  TextField(
                                    controller: nomeController,
                                    decoration: InputDecoration(hintText: "Nome"),
                                  ),
                                  TextField(
                                    controller: siglaController,
                                    decoration: InputDecoration(hintText: "Sigla"),
                                  ),
                                ],
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Cancelar'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('Salvar'),
                                  onPressed: () async {
                                    String nome = nomeController.text;
                                    String sigla = siglaController.text;

                                    await updateInstituicao(instituicao.id, nome, sigla);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            return CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          nomeController.clear();
          siglaController.clear();

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Nova Instituição'),
                content: Column(
                  children: <Widget>[
                    TextField(
                      controller: nomeController,
                      decoration: InputDecoration(hintText: "Nome"),
                    ),
                    TextField(
                      controller: siglaController,
                      decoration: InputDecoration(hintText: "Sigla"),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancelar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Salvar'),
                    onPressed: () async {
                      String nome = nomeController.text;
                      String sigla = siglaController.text;

                      await submitData(nome, sigla);

                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void reloadScreen() {
    setState(() {
      futureInstituicoes = fetchInstituicoes(); 
    });
  }

  Future<void> submitData(String nome, String sigla) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/admin/criarInstituicao'),
      headers: {'Authorization': 'Bearer $token'},
      body: {
        'nome': nome,
        'sigla': sigla.toUpperCase()
      },
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        /*Const*/ SnackBar(
          content: Text("Instituição já Cadastrada"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Instituição Cadastrada com sucesso, recarregue a página para visualizar a nova instituição"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      reloadScreen();
    }
  }

  Future<void> updateInstituicao(String id, String nome, String sigla) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/admin/atualizarInstituicao'),
      headers: {'Authorization': 'Bearer $token'},
      body: {
        'id': id,
        'nome': nome,
        'sigla': sigla.toUpperCase(),
      },
    ).timeout(const Duration(seconds: 2));

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao atualizar a instituição"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Instituição atualizada com sucesso"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      reloadScreen();
    }
  }

}
