import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginBasicoPage extends StatefulWidget {
  @override
  _LoginBasicoPageState createState() => _LoginBasicoPageState();
}

class _LoginBasicoPageState extends State<LoginBasicoPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    var url = Uri.parse('https://deploy-recode.vercel.app/login');
    var response = await http.post(url, body: {
      'email': _emailController.text,
      'password': _senhaController.text,
    });

    if (response.statusCode == 200) {
      // Sucesso no login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('E-mail ou senha inválidos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login Básico')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'E-mail'),
                validator: (value) => value!.isEmpty ? 'Digite seu e-mail' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _senhaController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Digite sua senha' : null,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _login,
                child: Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
