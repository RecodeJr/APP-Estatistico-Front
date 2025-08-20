import 'dart:convert';

import 'package:app_estatistico_novo/adm.dart';
import 'package:app_estatistico_novo/paineldeusuario_page.dart';
import 'package:flutter/material.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class BemVindoPage extends StatefulWidget {
  const BemVindoPage({Key? key}) : super(key: key);

  @override
  State<BemVindoPage> createState() => _BemVindoPageState();
}

class _BemVindoPageState extends State<BemVindoPage> {
  @override
  void initState() {
    super.initState();
    verificarUsuario().then((temUsuario) async {
      if (temUsuario) {
        SharedPreferences _sharedPreferences =
            await SharedPreferences.getInstance();
        String? token = _sharedPreferences.getString('token');
        var parts = token?.split('.');
        if (parts?.length != 3) {
          throw Exception('invalid token');
        }

        var payload = B64urlEncRfc7515.decodeUtf8(parts![1]);
        var decodedToken = json.decode(payload);
        if ((decodedToken?['admin'] ?? false) || (decodedToken?['subAdmin'] ?? false)) {
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ADM_PAGE(),
            ),
          );
        } else {
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PainelUsuario(),
            ),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // Returns an empty container
  }

  Future<bool> verificarUsuario() async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
    String? token = _sharedPreferences.getString('token');
    if (token == null) {
      return false;
    } else {
      return true;
    }
  }
}
