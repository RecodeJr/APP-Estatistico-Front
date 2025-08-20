import 'dart:convert';
import 'package:app_estatistico_novo/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:string_validator/string_validator.dart' as validator;
import 'hg_page.dart';
import 'package:http/http.dart' as http;

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

final _formKey = GlobalKey<FormState>();
var user = Usermodel();
var senhavalor = '';
var confsenhavalor = '';

class _CadastroPageState extends State<CadastroPage> {
  bool _obscureSenha = true;
  bool _obscureConfirmacaoSenha = true;
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmaSenhaController =
      TextEditingController();

  @override
  void dispose() {
    _senhaController.dispose();
    _confirmaSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: Size(360, 690),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/telas_referencias/Cadastre-se.png'),
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(15, 80, 15, 5),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  //Nickname
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          15, 5, 15, 10), // Adjust the padding as needed
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(5)),
                        child: CustomTextFild(
                          label: 'Apelido',
                          icon: Icons.person_pin,
                          onSaved: (text) => user = user.copyWith(nick: text),
                          validator: (text) => text == null || text.isEmpty
                              ? 'Campo Obrigatório'
                              : null,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(15, 5, 15, 10),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(5)),
                        child: CustomTextFild(
                          label: 'Nome',
                          icon: Icons.person,
                          onSaved: (text) => user = user.copyWith(name: text),
                          validator: (text) => text == null || text.isEmpty
                              ? 'Campo Obrigatório'
                              : null,
                        ),
                      ),
                    ),
                  ),
                  //Name

                  //SurName
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(15, 5, 15, 10),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(5)),
                        child: CustomTextFild(
                          label: 'Sobrenome',
                          icon: Icons.person,
                          onSaved: (text) =>
                              user = user.copyWith(surname: text),
                          validator: (text) => text == null || text.isEmpty
                              ? 'Campo Obrigatório'
                              : null,
                        ),
                      ),
                    ),
                  ),

                  //E-mail
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(15, 5, 15, 10),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(5)),
                        child: CustomTextFild(
                          label: 'E-mail',
                          icon: Icons.mail,
                          onSaved: (text) => user = user.copyWith(email: text),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Campo Obrigatório';
                            } else if (!validator.isEmail(text)) {
                              return 'Informação não correspondente';
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  // Senha
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(15, 5, 15, 10),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(5)),
                        child: CustomTextFild(
                          label: 'Senha',
                          icon: Icons.lock,
                          obscureText: _obscureSenha,
                          onSaved: (text) => user = user.copyWith(senha: text),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Campo Obrigatório';
                            } else if (text.length < 8) {
                              return 'A senha deve ter pelo menos 8 caracteres';
                            } else if (!RegExp(
                                    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$')
                                .hasMatch(text)) {
                              return 'A senha deve conter letras e números';
                            }
                            return null; // Retorna null se a validação for bem-sucedida
                          },
                          onChanged: (text) => senhavalor = text,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureSenha
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obscureSenha = !_obscureSenha;
                              });
                            },
                          ),
                          controller: _senhaController,
                        ),
                      ),
                    ),
                  ),

                  // Confirmação de Senha
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(15, 5, 15, 10),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(5)),
                        child: CustomTextFild(
                          label: 'Confirme sua senha',
                          icon: Icons.lock,
                          obscureText: _obscureConfirmacaoSenha,
                          onSaved: (text) => user = user.copyWith(senha: text),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Campo Obrigatório';
                            }
                            if (text != _senhaController.text) {
                              return 'Senhas não coincidem';
                            }
                          },
                          onChanged: (text) => confsenhavalor = text,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmacaoSenha
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmacaoSenha =
                                    !_obscureConfirmacaoSenha;
                              });
                            },
                          ),
                          controller: _confirmaSenhaController,
                        ),
                      ),
                    ),
                  ),

                  //selecionar instituição
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(15, 5, 15, 2),
                      child: SelectableButton(
                        color: Colors.white.withOpacity(0.7),
                        onItemSelected: (institutionId) {
                          setState(() {
                            user = user.copyWith(instituicao: institutionId);
                          });
                        },
                      ),
                    ),
                  ),
//NÃO ENTENDI O OVERFLOW DO FORMULARIO MAS OK
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ), // classe criada hg
                  //espaço e botão salvar
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: MediaQuery.of(context).size.width *
                        0.43, //botão infinito
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[200]!.withOpacity(0.93)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          // Cria um mapa com os dados do usuário
                          final Map<String, dynamic> userData = {
                            'nick': user.nick,
                            'name': user.name,
                            'surname': user.surname,
                            'email': user.email,
                            'senha': user.senha,
                            'instituicao': user.instituicao,
                          };

                          // Converção de mapa em json, coisa chataaaaaaaaaaa
                          final String jsonData = json.encode(userData);
                          // Faz a solicitação
                          http.post(
                              Uri.parse('${dotenv.env['API_URL']}/register'),
                              body: jsonData,
                              headers: {
                                'Content-Type': 'application/json'
                              }).then((response) {
                            if (response.statusCode == 200) {
                              // Requisição bem-sucedida, você pode tratar a resposta aqui
                              print('Dados enviados com sucesso!');
                              Navigator.pop(context);
                              // Navigator.pushReplacement(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => LoginPage(),
                              //   ),
                              // );
                            } else if (response.statusCode == 409) {
                              // guerraaaaaaaaaaaa de dados, verifique se o email ou o nickname já existem
                              Map<String, dynamic> responseData =
                                  json.decode(response.body); // teste com mapa

                              if (responseData
                                  .containsKey('nickname_existente')) {
                                // Nickname já existe
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Erro'),
                                    content: Text(
                                        'O nickname inserido já está em uso. Por favor, escolha outro nickname.'),
                                    actions: [
                                      TextButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              } else if (responseData
                                  .containsKey('email_existente')) {
                                // Email já existe
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Erro'),
                                    content: Text(
                                        'O email inserido já está em uso. Por favor, escolha outro email.'),
                                    actions: [
                                      TextButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } else {
                              // Requisição mal-sucedida, você pode tratar o erro aqui
                              print(
                                  'Falha ao enviar os dados. Código de status: ${response.statusCode}');
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Erro'),
                                  content: Text(
                                      'Ocorreu um erro durante o registro. Por favor, tente novamente mais tarde.'),
                                  actions: [
                                    TextButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }
                          }).catchError((error) {
                            // Ocorreu um erro durante a solicitação, você pode tratá-lo aqui
                            print('Erro ao enviar a solicitação: $error');
                          });
                        }
                        //Após salvar ir para a page de login
                      },
                      icon: Icon(Icons.save),
                      label: Text('Salvar', textAlign: TextAlign.center,
                                                                                                   style: TextStyle(
                                                                                                     fontFamily: 'Fredoka', // replace with your font family
                                                                                                     fontSize: MediaQuery.of(context).size.height * 0.026, // replace with your desired size
                                                                                                     fontWeight: FontWeight.w300,
                                                                                                   ),),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  //espaço e botão reset
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.07,
                    //width: double.infinity, //botão infinito
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.withOpacity(0.86)),
                      onPressed: () {
                        _formKey.currentState!.reset();
                      },
                      icon: Icon(Icons.save),
                      label: Text('Resetar', textAlign: TextAlign.center,
                                                                                                    style: TextStyle(
                                                                                                      fontFamily: 'Fredoka', // replace with your font family
                                                                                                      fontSize: MediaQuery.of(context).size.height * 0.026, // replace with your desired size
                                                                                                      fontWeight: FontWeight.w300,
                                                                                                    ),),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//Classe criada para replicar o TextFild
class CustomTextFild extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? Function(String? text)? validator;
  final void Function(String? text)? onSaved;
  final void Function(String text)? onChanged;
  final bool obscureText;
  final TextEditingController? controller; // Adicionado controller
  final Widget? suffixIcon; // Adicionado suffixIcon

  // Atualizada a definição do construtor
  const CustomTextFild({
    Key? key,
    required this.label,
    this.icon,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.obscureText = false,
    this.controller, // Adicionado controller
    this.suffixIcon, // Adicionado suffixIcon
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
      obscureText: obscureText, // Usando obscureText no TextFormField
      controller: controller, // Usando controller no TextFormField
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixIcon: icon == null ? null : Icon(icon),
        suffixIcon: suffixIcon, // Usando suffixIcon na decoração do campo
      ),
    );
  }
}

@immutable
class Usermodel {
  final String nick;
  final String surname;
  final String name;
  final String email;
  final String senha;
  final String instituicao;

  Usermodel({
    this.nick = '',
    this.name = '',
    this.surname = '',
    this.email = '',
    this.senha = '',
    this.instituicao = '',
  });
//''' verificar se funciona '''
  Usermodel copyWith({
    String? nick,
    String? name,
    String? surname,
    String? email,
    String? senha,
    String? instituicao,
  }) {
    return Usermodel(
      nick: nick ?? this.nick,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      senha: senha ?? this.senha,
      instituicao: instituicao ?? this.instituicao,
    );
  }
}
