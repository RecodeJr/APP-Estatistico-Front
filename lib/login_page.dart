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
      designSize: Size(360, 690),
    );
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 110, 87, 243),
        body: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/telas_referencias/Login(1).png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            // heightFactor: 2,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(55),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.42, // 1% of screen height
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.42), // 70% opacity white color
                        borderRadius:
                            BorderRadius.circular(10), // border radius
                      ),
                      child: TextFormField(
                        controller: _emailCotroller,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.mail_outline),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors
                                  .grey, // Border color when the field is not in focus
                              width:
                                  2.0, // Border width when the field is not in focus
                            ),
                            borderRadius: BorderRadius.circular(
                                10.0), // Increased border radius
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors
                                  .green, // Border color when the field is in focus
                              width:
                                  2.0, // Border width when the field is in focus
                            ),
                            borderRadius: BorderRadius.circular(
                                10.0), // Increased border radius
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
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.42), // 70% opacity white color
                        borderRadius:
                            BorderRadius.circular(10), // border radius
                      ),
                      child: TextFormField(
                          controller: _senhaCotroller,
                          obscureText: !_verSenha,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.vpn_key),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: MediaQuery.of(context).size.width *
                                    0.005, // 0.5% of screen width
                              ),
                              borderRadius: BorderRadius.circular(
                                  MediaQuery.of(context).size.width *
                                      0.03), // 3% of screen width
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.green,
                                width: MediaQuery.of(context).size.width *
                                    0.005, // 0.5% of screen width
                              ),
                              borderRadius: BorderRadius.circular(
                                  MediaQuery.of(context).size.width *
                                      0.03), // 3% of screen width
                            ),
                            label: Text('Senha'),
                            hintText: 'Digite sua senha',
                            suffixIcon: IconButton(
                              //ver senha
                              icon: Icon(_verSenha
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
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
                          }),
                    ),
                    Container(
                      alignment: Alignment
                          .centerRight, // Alinha o conteúdo do container à direita
                      child: CheckboxListTile(
                        title: Text(
                          "Manter conectado",
                          style: TextStyle(
                              fontSize: 14), // Reduz o tamanho da fonte para 14
                        ),
                        value: _manterConectado,
                        onChanged: (newValue) {
                          setState(() {
                            _manterConectado = newValue ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    //BOTÃO PARA ENTRAR
                    //BOTÃO PARA ENTRAR
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        MediaQuery.of(context).size.width *
                            0.04, // 4% of screen width
                        MediaQuery.of(context).size.height *
                            0.01, // 1% of screen height
                        MediaQuery.of(context).size.width *
                            0.04, // 4% of screen width
                        MediaQuery.of(context).size.height *
                            0.01, // 1% of screen height
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            logar();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.orange, // This is the button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(MediaQuery.of(
                                        context)
                                    .size
                                    .width *
                                0.04), // 4% of screen width, // Less rounded corners
                          ),
                        ),
                        child: Text(
                          'Entrar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily:
                                'Fredoka', // replace with your font family
                            fontSize: MediaQuery.of(context).size.height *
                                0.026, // replace with your desired size
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
//BOTÃO Cadastro
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        MediaQuery.of(context).size.width *
                            0.04, // 4% of screen width
                        MediaQuery.of(context).size.height *
                            0.01, // 1% of screen height
                        MediaQuery.of(context).size.width *
                            0.04, // 4% of screen width
                        MediaQuery.of(context).size.height *
                            0.01, // 1% of screen height
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      CadastroPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green, // This is the button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width *
                                    0.04), // Less rounded corners
                          ),
                        ),
                        child: Text(
                          'Cadastre-se',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily:
                                'Fredoka', // replace with your font family
                            fontSize: MediaQuery.of(context).size.height *
                                0.026, // replace with your desired size
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                    // //BOTÃO ESQUECEU A SENHA
                    // ElevatedButton(
                    //   onPressed: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (BuildContext context) => RedefSenPge(),
                    //       ),
                    //     );
                    //   },
                    //   child: Text('Esqueceu a senha ?'),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  logar() async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
    var url = Uri.parse('https://deploy-recode.vercel.app/login');
    var response = await http.post(
      url,
      body: {
        'email': _emailCotroller.text,
        'password': _senhaCotroller.text,
      },
    );

    // Acesso a outra página em caso de sucesso
    if (response.statusCode == 200) {
      String token = json.decode(response.body)['token'];
      bool data = json.decode(response.body)['data'] ?? false;
      await _sharedPreferences.setString('token', '$token');

      // Exibir o AlertDialog para perguntar ao usuário se deseja salvar o email e a senha
      if (_manterConectado) {
        _showSaveCredentialsDialog(data);
      } else {
        if (data == true) {
          //pagina Admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ADM_PAGE(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PainelUsuario(),
            ),
          );
        }
      }
    } else {
      // Caso o usuário digite a senha ou email errado ou não cadastro a seguinte mensagem aparecerá
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail ou senha inválidos'),
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
          // alertDialog é uma caixa que aparece
          title: Text('Salvar email e senha?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Deseja salvar o email e a senha ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Sim'),
              onPressed: () {
                // Aqui coloquei para salvar o email e a senha
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setString('user_email', _emailCotroller.text);
                  prefs.setString('user_password', _senhaCotroller.text);
                });
                if (data) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ADM_PAGE(),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PainelUsuario(),
                    ),
                  );
                }
              },
            ),
            TextButton(
              child: Text('Não'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PainelUsuario(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
