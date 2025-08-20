
import 'dart:convert';

import 'package:app_estatistico_novo/profile_visao_admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Usuarios {
    final String id;
    final String userName;
    final String sigla;

    Usuarios({required this.id, required this.userName, required this.sigla});

    factory Usuarios.fromJson(Map<String, dynamic> json) {
        return Usuarios(
          id: json['id'].toString(),
          userName: json['userName'],
          sigla: json['institution']['sigla'],
        );
    }
}

Future <List<Usuarios>> fetchUsuarios() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/admin/listuser'),
        headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> usersList = jsonResponse['data'] ?? [];

      return usersList.map((item) => Usuarios.fromJson(item)).toList();
    } else if(response.statusCode == 404) {
        return [];
    }else {
        throw Exception('Falha ao carregar usuarios do backend');
    }
}

class ListaUsersScreen extends StatefulWidget {
  @override
  _ListaUsersScreenState createState() => _ListaUsersScreenState();
}

class _ListaUsersScreenState extends State<ListaUsersScreen> {
    late Future<List<Usuarios>> futureUsuarios;

    @override
    void initState() {
    super.initState();
    futureUsuarios = fetchUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Administradores'),
      ),
      body: Center(
        child: FutureBuilder<List<Usuarios>>(
          future: futureUsuarios,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar usuarios: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Nenhum usuario encontrado'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final user = snapshot.data![index];
                  return ListTile(
                    title: Text(user.userName),
                    subtitle: Text(user.sigla),
                    onTap: () {
                        perfilAAcessar(user.id);
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