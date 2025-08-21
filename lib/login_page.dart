import 'dart:convert';
import 'package:app_estatistico_novo/adm.dart';
import 'package:app_estatistico_novo/cadastro_page.dart';
import 'package:app_estatistico_novo/paineldeusuario_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCotroller = TextEditingController();
  final _senhaCotroller = TextEditingController();
  bool _verSenha = false;
  String? frase = '';
  bool _manterConectado = false;
  String userEmail = '';
  String userPassword = '';

  @override
  void initState() {
    super.initState();
    loadSharedPreferences();
  }

  void loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('user_email') ?? '';
      userPassword = prefs.getString('user_password') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(360, 690),
    );
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 110, 87, 243),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/telas_referencias/Login(1).png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(55),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.42),
                  // EMAIL
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.42),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: _emailCotroller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.mail_outline),
                        labelText: 'E-mail',
                        hintText: 'nome@email.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (email) =>
                          email == null || email.isEmpty ? 'Digite seu e-mail' : null,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                  // SENHA
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.42),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: _senhaCotroller,
                      obscureText: !_verSenha,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.vpn_key),
                        label: const Text('Senha'),
                        hintText: 'Digite sua senha',
                        suffixIcon: IconButton(
                          icon: Icon(_verSenha
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () {
                            setState(() {
                              _verSenha = !_verSenha;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (senha) =>
                          senha == null || senha.isEmpty ? 'Digite sua senha' : null,
                    ),
                  ),
                  // CHECKBOX
                  CheckboxListTile(
                    title: const Text("Manter conectado", style: TextStyle(fontSize: 14)),
                    value: _manterConectado,
                    onChanged: (newValue) {
                      setState(() {
                        _manterConectado = newValue ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  // BOTÃO LOGIN
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        logar();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Entrar'),
                  ),
                  const SizedBox(height: 10),
                  // BOTÃO CADASTRO
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CadastroPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cadastre-se'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // FUNÇÃO DE LOGIN
  logar() async {
    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
    final apiUrl = dotenv.env['API_URL'] ?? '';

    try {
      var url = Uri.parse('$apiUrl/login');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'email': _emailCotroller.text,
          'password': _senhaCotroller.text,
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        String token = body['token'] ?? '';
        bool data = body['data'] ?? false;

        await _sharedPreferences.setString('token', token);

        if (_manterConectado) {
          _showSaveCredentialsDialog(data);
        } else {
          if (data) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => ADM_PAGE()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => PainelUsuario()),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail ou senha inválidos')),
        );
      }
    } catch (e) {
      print("ERRO AO LOGAR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro de conexão com o servidor')),
      );
    }
  }

  Future<void> _showSaveCredentialsDialog(bool data) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text('Salvar email e senha?'),
          content: const Text('Deseja salvar o email e a senha ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Sim'),
              onPressed: () {
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setString('user_email', _emailCotroller.text);
                  prefs.setString('user_password', _senhaCotroller.text);
                });
                if (data) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => ADM_PAGE()),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => PainelUsuario()),
                  );
                }
              },
            ),
            TextButton(
              child: const Text('Não'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => PainelUsuario()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
