import 'dart:math';
import 'package:app_estatistico_novo/instituicoes.dart';
import 'package:app_estatistico_novo/lista_admins.dart';
import 'package:app_estatistico_novo/lista_users.dart';
import 'package:app_estatistico_novo/profile_page.dart';
import 'package:app_estatistico_novo/relatorios_page.dart';

import 'login_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ADM_PAGE extends StatefulWidget {
  const ADM_PAGE({Key? key}) : super(key: key);

  @override
  _ADM_PAGEState createState() => _ADM_PAGEState();
}

class _ADM_PAGEState extends State<ADM_PAGE> {
  double angle = -pi / 2;
  int selectedOption = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              'PÁGINA DE ADMINISTRADOR',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ListaAdminsScreen())
                          );
                        },
                        child: Text('Lista de Administradores'),
                      ),
                       SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ListaUsersScreen())
                          );
                        },
                        child: Text('Lista de Usuarios'),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => InstituicoesScreen()),
                          );
                        },
                        child: Text('Lista de Instituições'),
                      ),/*
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/user_list');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green, // Cor de fundo
                          onPrimary: Colors.white, // Cor do texto
                          padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10), // Espaçamento interno
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8), // Borda arredondada
                          ),
                        ),
                        child: Text('Lista de Usuários'),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/port_list');
                        },
                        child: Text('Lista de Portos'),
                      ), */
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Relatorios_page()),
                          );
                        },
                        child: Text('Página de Relatórios'),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfilePage()),
                          );
                        },
                        child: Text('Perfil Administrador'),
                      ),
                      ////////////////////

                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          await limparToken();
                          try {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                              (route) => false,
                            );
                          } catch (error) {
                            print('Erro ao sair: $error');
                          }
                          setState(() {
                            angle = 0.0;
                          });
                        },
                        child: Container(
                          width: constraints.maxWidth * 0.2,
                          height: constraints.maxWidth * 0.2,
                          decoration: BoxDecoration(
                            color: selectedOption == 1
                                ? Colors.blue[900]!.withOpacity(0.85)
                                : Colors.blue[500]!.withOpacity(0.86),
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(constraints.maxWidth * 0.03),
                          child: Column(
                            children: [
                              Icon(
                                Icons.anchor,
                                size: constraints.maxWidth * 0.08,
                                color: Colors.white,
                              ),
                              Text(
                                'Sair',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: constraints.maxWidth * 0.04,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showReportsDialog(BuildContext context, dynamic data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Relatórios dos Portos'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...(data as List<dynamic>).map((report) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Relatório do porto: ${report['nome']}'),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> limparToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
