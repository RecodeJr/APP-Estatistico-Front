
import 'dart:convert';

import 'package:app_estatistico_novo/profile_visao_admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Administradores {
    final String id;
    final String userName;
    final String sigla;

    Administradores({required this.id, required this.userName, required this.sigla});

    factory Administradores.fromJson(Map<String, dynamic> json) {
        return Administradores(
          id: json['id'].toString(),
          userName: json['userName'],
          sigla: json['institution']['sigla'],
        );
    }
}

Future <List<Administradores>> fetchAdministradores() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/admin/listadmin'),
        headers: {'Authorization': 'Bearer $token'},
    );

    print(
      response.body
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> adminList = jsonResponse['data'] ?? [];

      return adminList.map((item) => Administradores.fromJson(item)).toList();
    } else if(response.statusCode == 404) {
        return [];
    }else {
        throw Exception('Falha ao carregar administradores do backend');
    }
}

class ListaAdminsScreen extends StatefulWidget {
  @override
  _ListaAdminsScreenState createState() => _ListaAdminsScreenState();
}

class _ListaAdminsScreenState extends State<ListaAdminsScreen> {
    late Future<List<Administradores>> futureAdministradores;

    @override
    void initState() {
    super.initState();
    futureAdministradores = fetchAdministradores();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Administradores'),
      ),
      body: Center(
        child: FutureBuilder<List<Administradores>>(
          future: futureAdministradores,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar administradores: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Nenhum administrador encontrado'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final admin = snapshot.data![index];
                  return ListTile(
                    title: Text(admin.userName),
                    subtitle: Text(admin.sigla),
                    onTap: () {
                        perfilAAcessar(admin.id);
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => ProfileVisaoAdmin(),
                          ),
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  perfilAAcessar(String profileId) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('profileId', profileId);
  }
}