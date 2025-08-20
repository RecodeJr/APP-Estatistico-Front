


import 'dart:convert';

import 'package:app_estatistico_novo/adm.dart';
import 'package:app_estatistico_novo/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DadosUsuario {
  final String id;
  final String nome;
  final String sobrenome;
  final String nickname;
  final String instituicao;
  final String nivel;
  final List<AccessPort> accessPorts;
  final bool isAdmin;
  final bool vistoPorAdminChefe;

  DadosUsuario({
    required this.id,
    required this.nome,
    required this.sobrenome,
    required this.nickname,
    required this.instituicao,
    required this.nivel,
    required this.accessPorts,
    required this.isAdmin,
    required this.vistoPorAdminChefe,
  });

  factory DadosUsuario.fromJson(Map<String, dynamic> json) {
    final accessPortsJson = json['data1'] as List<dynamic>;
    final accessPorts = accessPortsJson.map((apJson) => AccessPort.fromJson(apJson)).toList();
    
    return DadosUsuario(
      id: json['data']['userId'] as String? ?? '',
      nome: json['data']['userPrimNome'] as String? ?? '',
      sobrenome: json['data']['userSobrenome'] as String? ?? '',
      nickname: json['data']['userName'] as String? ?? '',
      instituicao: json['data']['userInstituicao'] as String? ?? '',
      nivel: json['data']['userNivel'] as String? ?? '',
      accessPorts: accessPorts,
      isAdmin: json['data']['isAdmin'] as bool? ?? false,
      vistoPorAdminChefe: json['data']['vistoPorAdminChefe'] as bool? ?? false,
    );
  }
}

class AccessPort {
  final String id;
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
      id: json['id'].toString(),
      nome: json['nome'] as String,
      dificuldadeId: json['dificuldadeId'],
      estadoDescricao: json['descricao'] as String,
    );
  }
}

Future<List<DadosUsuario>> buscarDados(context) async {
  String apiUrl = '${dotenv.env['API_URL']}/admin/listuser/profile';
  final _sharedPreferences = await SharedPreferences.getInstance();
  final token = _sharedPreferences.getString('token');
  final Map<String, dynamic> postData = {'profileId': '${_sharedPreferences.getString('profileId')}'};

  final response = await http.post(Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer $token'},
      body: postData)
      .catchError((error) {
        throw Exception(error);
      });
    if (response.statusCode == 200) {
        Map<String, dynamic> dadosJson = jsonDecode(response.body);

        print(dadosJson);
        final sharedPreferences = await SharedPreferences.getInstance();
        await sharedPreferences.setString('id', dadosJson['data']['id']);

        return [DadosUsuario.fromJson(dadosJson)];
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
        throw Exception('Falha ao buscar dados');
      }
  throw Exception('Erro inesperado'); 
}


class ProfileVisaoAdmin extends StatefulWidget {
  @override
  _ProfileVisaoAdminState createState() => _ProfileVisaoAdminState();
}

class _ProfileVisaoAdminState extends State<ProfileVisaoAdmin> {
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
        title: Text('Dados de Usuario',
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
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              } else if(!snapshot.hasData || snapshot.data!.isEmpty){
                return Text('Nenhum dado encontrado');
              } else {
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
                                const SizedBox(height: 8),
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
                            const SizedBox(height: 16),
                            if(snapshot.data![index].isAdmin == false)
                            ElevatedButton(
                              onPressed: () {
                                promoteToAdmin();
                              },
                              child: Text('Promover a Administrador'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 40, 209, 49), // Cor do botão
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 24,
                                ),
                                textStyle: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width *
                                      (screenWidth < 600 ? 0.04 : 0.05),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if(snapshot.data![index].isAdmin == true && snapshot.data![index].vistoPorAdminChefe == true)
                            ElevatedButton(
                              onPressed: () {
                                removeFromAdmin();
                              },
                              child: Text('Remover de Administrador'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 171, 25, 25), // Cor do botão
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 24,
                                ),
                                textStyle: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width *
                                      (screenWidth < 600 ? 0.04 : 0.05),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }         
            },
          ),
        ),
      ),
    );
  }

  promoteToAdmin()async{
    String apiUrl = '${dotenv.env['API_URL']}/admin/listuser/profile/promote';
    final _sharedPreferences = await SharedPreferences.getInstance();
    final token = _sharedPreferences.getString('token');
    final idUser = _sharedPreferences.getString('id');

    final Map<String, dynamic> postData = {
      'idUpdated': idUser,
    };

    final response = await http.post(Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer $token'},
      body: postData)
      .catchError((error) {
        throw Exception(error);
      });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuário promovido a administrador'),
          backgroundColor: Colors.green,
        ),
      );
      _sharedPreferences.remove('id');
      Navigator.push(context, MaterialPageRoute(builder: (context) => ADM_PAGE()));
    } else if (response.statusCode == 401) {
      SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
      await _sharedPreferences.remove('token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao promover usuário a administrador'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  removeFromAdmin() async {
    String apiUrl = '${dotenv.env['API_URL']}/admin/delete';
    final _sharedPreferences = await SharedPreferences.getInstance();
    final token = _sharedPreferences.getString('token');
    final idUser = _sharedPreferences.getString('id');

    final Map<String, dynamic> postData = {
      'id': idUser,
    };

    final response = await http.delete(Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer $token'},
      body: postData)
      .catchError((error) {
        throw Exception(error);
      });
       if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuário removido de administrador'),
          backgroundColor: Colors.green,
        ),
      );
      _sharedPreferences.remove('id');
      Navigator.push(context, MaterialPageRoute(builder: (context) => ADM_PAGE()));
    } else if (response.statusCode == 401) {
      SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
      await _sharedPreferences.remove('token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao remover usuario de administrador'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}