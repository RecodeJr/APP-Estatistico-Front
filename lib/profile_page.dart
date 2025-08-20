import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'editar_perfil_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app_estatistico_novo/login_page.dart';
import 'editar_perfil_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DadosUsuario {
  final String nome;
  final String sobrenome;
  final String nickname;
  final String instituicao;
  final String nivel;
  final List<AccessPort> accessPorts;

  DadosUsuario({
    required this.nome,
    required this.sobrenome,
    required this.nickname,
    required this.instituicao,
    required this.nivel,
    required this.accessPorts,
  });

  factory DadosUsuario.fromJson(Map<String, dynamic> json) {
    final accessPortsJson = json['data1'] as List<dynamic>;
    final accessPorts =
        accessPortsJson.map((apJson) => AccessPort.fromJson(apJson)).toList();
    return DadosUsuario(
      nome: json['data']['userPrimNome'],
      sobrenome: json['data']['userSobrenome'],
      nickname: json['data']['userName'],
      instituicao: json['data']['userInstituicao'],
      nivel: json['data']['userNivel'],
      accessPorts: accessPorts,
    );
  }
}

class AccessPort {
  final int id;
  final String nome;
  final int dificuldadeId;
  final String estadoDescricao;

  AccessPort({
    required this.id,
    required this.nome,
    required this.dificuldadeId,
    required this.estadoDescricao,
  });

  factory AccessPort.fromJson(Map<String, dynamic> json) {
    return AccessPort(
      id: json['id'],
      nome: json['nome'],
      dificuldadeId: json['dificuldadeId'],
      estadoDescricao: json['descricao'],
    );
  }
}

Future<List<DadosUsuario>> buscarDados(context) async {
  String apiUrl = '${dotenv.env['API_URL']}/user/profile';
  final _sharedPreferences = await SharedPreferences.getInstance();
  final token = _sharedPreferences.getString('token');
  final response = await http.get(Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer $token'}).then((response) {
    if (response.statusCode == 200) {
      Map<String, dynamic> dadosJson = jsonDecode(response.body);
      return [DadosUsuario.fromJson(dadosJson)];
    } else if (response.statusCode == 401) {
      //VERIFICAR FUNCIONAMENTO
      _sharedPreferences.remove('token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
      Map<String, dynamic> dadosJson = jsonDecode(response.body);
      return [DadosUsuario.fromJson(dadosJson)];
    } else {
      throw Exception('Falha ao buscar dados');
    }
  }).catchError((error) {
    throw Exception(error);
  });
  return response;
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<List<DadosUsuario>> futureDados;

  @override
  void initState() {
    super.initState();
    futureDados = buscarDados(context);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: Size(360, 690),
    );
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Meus Dados',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/telas_referencias/NICKNAME.png'),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: Center(
          child: FutureBuilder<List<DadosUsuario>>(
            future: futureDados,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.white,
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.3,
                        left: MediaQuery.of(context).size.height * 0.04,
                        right: MediaQuery.of(context).size.height * 0.04,
                        bottom: MediaQuery.of(context).size.height * 0.04,
                      ),
                      elevation: MediaQuery.of(context).size.height *
                          0.07, // 7% of screen height
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.width *
                                0.04), // 4% of screen width
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.height *
                                0.02), // 2% of screen height
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.account_circle,
                                  size: MediaQuery.of(context).size.width *
                                      0.18, // 18% of screen width
                                  color: Colors.blue[800],
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.04),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${snapshot.data![index].nome} ${snapshot.data![index].sobrenome}',
                                              style: TextStyle(
                                                fontFamily:
                                                    'Fredoka', // replace with your font family
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.026, // replace with your desired size
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.settings),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditProfilePage(
                                                    nome: snapshot
                                                        .data![index].nome,
                                                    nickname: snapshot
                                                        .data![index].nickname,
                                                    sobrenome: snapshot
                                                        .data![index].sobrenome,
                                                  ),
                                                ),
                                              ).then((result) {
                                                if (result == true) {
                                                  // Atualiza os dados do perfil após a edição
                                                  setState(() {
                                                    futureDados =
                                                        buscarDados(context);
                                                  });
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.01), // 1% of screen height
                                      Text(
                                        '${snapshot.data![index].instituicao}',
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              (screenWidth < 600 ? 0.04 : 0.05),
                                          color: Colors.red[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02),
                            ListTile(
                              leading: Icon(
                                Icons.person,
                                color: Colors.blue[800],
                              ),
                              title: Text(
                                'Nickname',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: MediaQuery.of(context).size.width *
                                      (screenWidth < 600 ? 0.04 : 0.05),
                                ),
                              ),
                              subtitle: Text(
                                '${snapshot.data![index].nickname}',
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            (screenWidth < 600 ? 0.04 : 0.05)),
                              ),
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.star,
                                color: Colors.blue[800],
                              ),
                              title: Text(
                                'Nível',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: MediaQuery.of(context).size.width *
                                      (screenWidth < 600 ? 0.04 : 0.05),
                                ),
                              ),
                              subtitle: Text(
                                '${snapshot.data![index].nivel}',
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            (screenWidth < 600 ? 0.04 : 0.05)),
                              ),
                            ),
                            const Divider(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Acesso aos Portos',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            (screenWidth < 600 ? 0.04 : 0.05),
                                    color: Colors.blue[800],
                                  ),
                                ),
                                SizedBox(height: 8),
                                snapshot.data![index].accessPorts.isEmpty
                                    ? Text('Nenhum porto acessado',
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context).size.width * (screenWidth < 600 ? 0.04 : 0.05))) // 4% or 5% of screen width
                                    : Column(
                                        children: snapshot
                                            .data![index].accessPorts
                                            .map((ap) => ListTile(
                                                  leading: Icon(
                                                    Icons.location_on,
                                                    color: Colors.blue[800],
                                                  ),
                                                  title: Text(ap.nome),
                                                  subtitle:
                                                      Text(ap.estadoDescricao),
                                                ))
                                            .toList(),
                                      )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // Por padrão, exiba um indicador de progresso
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
