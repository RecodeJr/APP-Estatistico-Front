import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_estatistico_novo/login_page.dart';
import 'package:app_estatistico_novo/main.dart';

class EditProfilePage extends StatefulWidget {
  final String nome;
  final String nickname;
  final String sobrenome;
  EditProfilePage({
    required this.nome,
    required this.nickname,
    required this.sobrenome,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _nicknameController = TextEditingController();
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _senhaAtualController = TextEditingController();
  TextEditingController _novaSenhaController = TextEditingController();
  TextEditingController _confirmarNovaSenhaController = TextEditingController();
  TextEditingController _sobrenomeController = TextEditingController();
  TextEditingController _senhaController = TextEditingController();
  TextEditingController _confirmarSenhaController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isChangingPassword = false;
  bool _verSenha = false;
  bool _verSenhaNova = false;
  bool _verConfirmarSenhaNova = false;
  bool _verSenha1 = false;
  bool _verConfirmarSenha = false;

  @override
  void initState() {
    super.initState();
    _nicknameController.text = widget.nickname;
    _nomeController.text = widget.nome;
    _sobrenomeController.text = widget.sobrenome;
  }

  Future<void> _atualizarPerfil() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String apiUrl = '${dotenv.env['API_URL']}/user/profile/changeprofile';
    final _sharedPreferences = await SharedPreferences.getInstance();
    final token = _sharedPreferences.getString('token');

    // Determine qual tipo de solicitação será feita
    Map<String, String> requestBody = {
      'nick': _nicknameController.text,
      'name': _nomeController.text,
      'surname': _sobrenomeController.text,
      'password': _senhaController.text,
    };

    if (_isChangingPassword) {
      apiUrl = '${dotenv.env['API_URL']}/user/profile/changepassword';
      if (_novaSenhaController.text != _confirmarNovaSenhaController.text) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'As senhas não coincidem.';
        });
        return;
      } else if (_senhaAtualController.text == _novaSenhaController.text) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'A senha nova não pode ser igual a senha atual.';
        });
        return;
      } else {
        requestBody = {
          'senhaAtual': _senhaAtualController.text,
          'senhaNova': _novaSenhaController.text
        };
      }
    } else {
      if (_senhaController.text != _confirmarSenhaController.text) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'As senhas não coincidem.';
        });
        return;
      }
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
        body: requestBody,
      );

      if (response.statusCode == 201) {
        Navigator.pop(context, true);
      } else if (response.statusCode == 401) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = '${response.body}';
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro de conexão.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Inicializando ScreenUtil em seu widget.
    ScreenUtil.init(context, designSize: Size(360, 690));

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('Atualizar cadastro'),
        ),
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/telas_referencias/NICKNAME.png'), // replace with your image path
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.25,
                left: MediaQuery.of(context).size.height * 0.04,
                right: MediaQuery.of(context).size.height * 0.04,
                bottom: MediaQuery.of(context).size.height * 0.04,
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200]!.withOpacity(
                          0.79), // Set the background color with opacity
                      borderRadius:
                          BorderRadius.circular(16.0), // Set the border radius
                    ), // Set the background color with opacity
                    child: Card(
                      color: Colors.transparent,
                      elevation: 0, // Make the Card widget transparent
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            if (_isChangingPassword)
                              Column(
                                children: [
                                  TextField(
                                    controller: _senhaAtualController,
                                    obscureText: !_verSenha,
                                    decoration: InputDecoration(
                                      label: Text('Senha atual'),
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
                                  ),
                                  TextField(
                                    controller: _novaSenhaController,
                                    obscureText: !_verSenhaNova,
                                    decoration: InputDecoration(
                                      label: Text('Nova senha'),
                                      hintText: 'Digite sua nova senha',
                                      suffixIcon: IconButton(
                                        //ver senha
                                        icon: Icon(_verSenhaNova
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined),
                                        onPressed: () {
                                          setState(() {
                                            _verSenhaNova = !_verSenhaNova;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  TextField(
                                    controller: _confirmarNovaSenhaController,
                                    obscureText: !_verConfirmarSenhaNova,
                                    decoration: InputDecoration(
                                      label: Text('Confirmar nova senha'),
                                      hintText: 'Digite sua nova senha',
                                      suffixIcon: IconButton(
                                        //ver senha
                                        icon: Icon(_verConfirmarSenhaNova
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined),
                                        onPressed: () {
                                          setState(() {
                                            _verConfirmarSenhaNova =
                                                !_verConfirmarSenhaNova;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(children: [
                                TextField(
                                  controller: _nicknameController,
                                  decoration: InputDecoration(
                                    labelText: 'Nickname',
                                  ),
                                ),
                                TextField(
                                  controller: _nomeController,
                                  decoration: InputDecoration(
                                    labelText: 'Nome',
                                  ),
                                ),
                                TextField(
                                  controller: _sobrenomeController,
                                  decoration: InputDecoration(
                                    labelText: 'Sobrenome',
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                TextField(
                                  controller: _senhaController,
                                  obscureText: !_verSenha1,
                                  decoration: InputDecoration(
                                    labelText: 'Senha',
                                    suffixIcon: IconButton(
                                      //ver senha
                                      icon: Icon(_verSenha1
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined),
                                      onPressed: () {
                                        setState(() {
                                          _verSenha1 = !_verSenha1;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                TextField(
                                  controller: _confirmarSenhaController,
                                  obscureText: !_verConfirmarSenha,
                                  decoration: InputDecoration(
                                    labelText: 'Confirmar Senha',
                                    suffixIcon: IconButton(
                                      //ver senha
                                      icon: Icon(_verConfirmarSenha
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined),
                                      onPressed: () {
                                        setState(() {
                                          _verConfirmarSenha =
                                              !_verConfirmarSenha;
                                        });
                                      },
                                    ),
                                  ),
                                )
                              ]),
                            SizedBox(height: 16.0),
                            if (_errorMessage.isNotEmpty)
                              Text(
                                _errorMessage,
                                style: TextStyle(color: Colors.red),
                              ),
                            SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _atualizarPerfil,
                              child: _isLoading
                                  ? CircularProgressIndicator()
                                  : _isChangingPassword
                                      ? Text('Atualizar senha')
                                      : Text('Atualizar Perfil'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200]!.withOpacity(
                          0.79), // Set the background color with opacity
                      borderRadius:
                          BorderRadius.circular(16.0), // Set the border radius
                    ), // Set the background color with the background color with opacity
                    child: Card(
                      color: Colors.transparent,
                      elevation: 0, // Make the Card widget transparent
                      child: ListTile(
                        title: Text('Alterar Senha'),
                        trailing: Switch(
                          value: _isChangingPassword,
                          onChanged: (newValue) {
                            setState(() {
                              _isChangingPassword = newValue;
                              _errorMessage = '';
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
