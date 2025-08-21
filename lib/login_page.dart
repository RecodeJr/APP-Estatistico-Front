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
  bool _manterConectado = false; // Salvar o email e a senha do usuário
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
                  // CAMPO EMAIL
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
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.green, width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        labelText: 'E-mail',
                        hintText: 'nome@email.com',
                      ),
                      validator: (email) {
                        if (email == null || email.isEmpty) {
                          return 'Digite seu e-mail';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                  // CAMPO SENHA
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
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: MediaQuery.of(context).size.width * 0.005,
                          ),
                          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green,
                            width: MediaQuery.of(context).size.width * 0.005,
                          ),
                          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
                        ),
                        label: const Text('Senha'),
                        hintText: 'Digite sua senha',
                        suffixIcon: IconButton(
                          icon: Icon(_verSenha ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () {
                            setState(() {
                              _verSenha = !_verSenha;
                            });
                          },
                        ),
                      ),
                      validator: (senha) {
                        if (senha == null || senha.isEmpty) {
                          return 'Digite sua senha';
                        }
                        return null;
                      },
                    ),
                  ),
                  // CHECKBOX
                  Container(
                    alignment: Alignment.centerRight,
                    child: CheckboxListTile(
                      title: const Text("Manter conectado", style: TextStyle(fontSize: 14)),
                      value: _manterConectado,
                      onChanged: (newValue) {
                        setState(() {
                          _manterConectado = newValue ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  // BOTÃO ENTRAR
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.04,
                      vertical: MediaQuery.of(context).size.height * 0.01,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          logar();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.04),
                        ),
                      ),
                      child: Text(
                        'Entrar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: MediaQuery.of(context).size.height * 0.026,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                  // BOTÃO CADASTRO
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.04,
                      vertical: MediaQuery.of(context).size.height * 0.01,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (BuildContext context) => const CadastroPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.04),
                        ),
                      ),
                      child: Text(
                        'Cadastre-se',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: MediaQuery.of(context).size.height * 0.026,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // FUNÇÃO DE LOGIN CORRIGIDA
  logar() async {
    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();

    try {
      var url = Uri.parse('https://deploy-recode.vercel.app/login');
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'email': _emailCotroller.text,
          'password': _senhaCotroller.text,
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        var body = json.decode(response.body);

        // Ajusta conforme a resposta real do back-end
        String token = body['token'] ?? '';
        bool data = body['data'] ?? false;

        await _sharedPreferences.setString('token', token);

        if (_manterConectado) {
          _showSaveCredentialsDialog(data);
        } else {
          if (data) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ADM_PAGE()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PainelUsuario()),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-mail ou senha inválidos'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("ERRO AO LOGAR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro de conexão com o servidor'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showSaveCredentialsDialog(bool data) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Salvar email e senha?'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Deseja salvar o email e a senha ?'),
              ],
            ),
          ),
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
                    MaterialPageRoute(builder: (context) => ADM_PAGE()),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => PainelUsuario()),
                  );
                }
              },
            ),
            TextButton(
              child: const Text('Não'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => PainelUsuario()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
