import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_estatistico_novo/paineldeusuario_page.dart';
import 'package:app_estatistico_novo/portos_page.dart';
import 'package:app_estatistico_novo/login_page.dart';

//testando
class Alternativa {
  final int id;
  final int perguntaId;
  final String descricao;
  final List<int> imagem;

  Alternativa(this.id, this.perguntaId, this.descricao, this.imagem);
}

class Pergunta {
  final int id;
  final String descricao;
  final List<int> imagem;
  final bool multiplasAlternativas;
  final List<Alternativa> alternativas;

  Pergunta(this.id, this.descricao, this.imagem, this.multiplasAlternativas,
      this.alternativas);
}

class PaginaPerguntas extends StatefulWidget {
  PaginaPerguntas();

  @override
  _PaginaPerguntasState createState() => _PaginaPerguntasState();
}

class _PaginaPerguntasState extends State<PaginaPerguntas> {
  List<Pergunta> _perguntas = [];
  int _perguntaAtual = 0;
  TextEditingController _controller = TextEditingController();
  List<int>? _alternativaSelecionada;

  @override
  void initState() {
    super.initState();
    _alternativaSelecionada = [];
    _carregarPerguntas();
  }

  void _carregarPerguntas() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/user/port/questions'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          // Verifica se o campo "data" existe na resposta
          List<Pergunta> perguntas = [];

          for (var perguntaData in data['data']) {
            List<Alternativa> alternativas = [];
            for (var alternativa in perguntaData['alternativas']) {
              alternativas.add(Alternativa(
                alternativa['id'] ?? '',
                perguntaData['id'] ?? '', // adiciona o ID da pergunta
                alternativa['descricao'] ?? '',
                alternativa['imagem'] != null
                    ? List<int>.from(alternativa['imagem']['data'])
                    : <int>[],
              ));
            }
            perguntas.add(Pergunta(
              perguntaData['id'] ?? '',
              perguntaData['descricao'] ?? '',
              perguntaData['imagem'] != null
                  ? List<int>.from(perguntaData['imagem']['data'])
                  : <int>[],
              perguntaData['multiplasAlternativas'] ?? '',
              alternativas,
            ));
          }

          setState(() {
            _perguntas = perguntas;
          });
        } else {
          print('Erro ao carregar perguntas: resposta inválida');
        }
      } else if (response.statusCode == 401) {
        SharedPreferences _sharedPreferences =
            await SharedPreferences.getInstance();
        await _sharedPreferences.remove('token');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      }
    } catch (error) {
      print('Erro ao carregar perguntas: $error');
    }
  }

  Future<void> _responder() async {
    if (_alternativaSelecionada == null) {
      // Exibe uma mensagem de erro ou não faz nada, dependendo do comportamento que deseja implementar
      return;
    }
    _alternativaSelecionada?.sort();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      // O token não foi encontrado, redireciona o usuário para a tela de loginou exibe uma mensagem de erro
      return;
    }

    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/user/port/answerquestion'),
      headers: {'Authorization': 'Bearer $token'},
      body: {
        'perguntaId': '${_perguntas[_perguntaAtual].id}',
        'alternativaMarcadaId':
            _alternativaSelecionada?.map((a) => '$a').join(',')
      },
    );
    print(_perguntas[_perguntaAtual].id);
    print(response.body);

    //Direciona o usuário para o painel após concluir um porto.
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      bool shouldPop = false; // Variável de estado para controlar o retorno
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              // Impede que o pop-up seja fechado ao pressionar o botão "Voltar"
              return false;
            },
            child: AlertDialog(
              title: Text('Resultado do Porto'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Número de acertos: ${data['numAcertos']}'),
                  Text(
                      'Porcentagem de acertos: ${data['porcentagem'].toStringAsFixed(2)}%'),
                  Text('Resultado: ${data['mensagem']}'),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Fechar o diálogo
                    shouldPop = true; // Atualizar a variável de estado
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        },
      ).then((_) {
        if (shouldPop) {
          Navigator.pop(context, 1); // Retornar o valor para a tela anterior
        }
      });
    } else if (response.statusCode == 401) {
      SharedPreferences _sharedPreferences =
          await SharedPreferences.getInstance();
      await _sharedPreferences.remove('token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }

    setState(() {
      if (_perguntaAtual < _perguntas.length - 1) {
        _perguntaAtual++;
      }

      _alternativaSelecionada = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: Size(360, 690),
    );
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: Text('Hora do Quiz!'),
        ),
        body: Container(
          color: Colors.orange[300],
          child: Center(
            child: SingleChildScrollView(
              child: _perguntaAtual < _perguntas.length
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height *
                                0.02), //espaço na tela
                        // Verifique se a imagem não é nula antes de tentar exibi-la
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width *
                                    0.05), // 5% of screen width
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.42),
                                spreadRadius:
                                    MediaQuery.of(context).size.width *
                                        0.01, // 1% of screen width
                                blurRadius: MediaQuery.of(context).size.width *
                                    0.02, // 2% of screen width
                                offset: Offset(
                                    0,
                                    MediaQuery.of(context).size.height *
                                        0.01), // 1% of screen height
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: InteractiveViewer(
                                      child: Image.memory(Uint8List.fromList(
                                        _perguntas[_perguntaAtual].imagem!,
                                      )),
                                    ),
                                  );
                                },
                              );
                            },
                            child: _perguntas[_perguntaAtual].imagem != null &&
                                    _perguntas[_perguntaAtual].imagem.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width *
                                            0.05),
                                    child: Image.memory(Uint8List.fromList(
                                      _perguntas[_perguntaAtual].imagem!,
                                    )),
                                  )
                                : Container(),
                          ),
                        ), // Renderiza um Container vazio quando a imagem é nula
                        SizedBox(
                            height: MediaQuery.of(context).size.height *
                                0.02), // Espaço entre a imagem e o texto
                        Column(
                          children: [
                            Text(
                              _perguntas[_perguntaAtual].descricao,
                              style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.02),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.015),
                            Column(
                              children: _perguntas[_perguntaAtual]
                                  .alternativas
                                  .map((alternativa) {
                                if (_perguntas[_perguntaAtual]
                                    .multiplasAlternativas) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.05, // 5% of screen width
                                      right: MediaQuery.of(context).size.width *
                                          0.05, // 5% of screen width
                                      top: MediaQuery.of(context).size.height *
                                          0.005, // 1% of screen height
                                      bottom:
                                          MediaQuery.of(context).size.height *
                                              0.005, // 1% of screen height
                                    ), // adjust the value as needed
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Card(
                                            elevation: 8,
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(MediaQuery.of(
                                                              context)
                                                          .size
                                                          .width *
                                                      0.07), // Para um botão redondo
                                            ),
                                            child: CheckboxListTile(
                                              controlAffinity:
                                                  ListTileControlAffinity
                                                      .leading,
                                              title:
                                                  Text(alternativa.descricao),
                                              value: _alternativaSelecionada!
                                                  .contains(alternativa.id),
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value != null && value) {
                                                    _alternativaSelecionada
                                                        ?.add(alternativa.id);
                                                  } else {
                                                    _alternativaSelecionada
                                                        ?.remove(
                                                            alternativa.id);
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        if (alternativa.imagem.isNotEmpty)
                                          Flexible(
                                            child: GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Dialog(
                                                      child: ClipRect(
                                                        child:
                                                            InteractiveViewer(
                                                          child: Image.memory(
                                                              Uint8List.fromList(
                                                                  alternativa
                                                                      .imagem!)),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Image.memory(
                                                  Uint8List.fromList(
                                                      alternativa.imagem!)),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.05, // 5% of screen width
                                      right: MediaQuery.of(context).size.width *
                                          0.05, // 5% of screen width
                                      top: MediaQuery.of(context).size.height *
                                          0.005, // 1% of screen height
                                      bottom:
                                          MediaQuery.of(context).size.height *
                                              0.005, // 1% of screen height
                                    ), // adjust the value as needed
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Card(
                                            elevation: 8,
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(MediaQuery.of(
                                                              context)
                                                          .size
                                                          .width *
                                                      0.07), // Para um botão redondo
                                            ),
                                            child: RadioListTile(
                                              controlAffinity:
                                                  ListTileControlAffinity
                                                      .leading,
                                              title:
                                                  Text(alternativa.descricao),
                                              value: alternativa.id,
                                              groupValue:
                                                  _alternativaSelecionada!
                                                          .contains(
                                                              alternativa.id)
                                                      ? alternativa.id
                                                      : null,
                                              onChanged: (int? value) {
                                                setState(() {
                                                  if (value != null) {
                                                    _alternativaSelecionada
                                                        ?.clear();
                                                    _alternativaSelecionada
                                                        ?.add(value);
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        if (alternativa.imagem != null &&
                                            alternativa.imagem.isNotEmpty)
                                          Flexible(
                                            child: GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Dialog(
                                                      child: ClipRect(
                                                        child:
                                                            InteractiveViewer(
                                                          child: Image.memory(
                                                              Uint8List.fromList(
                                                                  alternativa
                                                                      .imagem!)),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Image.memory(
                                                  Uint8List.fromList(
                                                      alternativa.imagem!)),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }
                              }).toList(),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height *
                                  0.04), // adjust the value as needed
                          child: ElevatedButton(
                            onPressed: _alternativaSelecionada != null
                                ? _responder
                                : null,
                            child: Text('Responder'),
                          ),
                        )
                      ],
                    )
                  : const Center(child: Text('Fim das perguntas!')),
            ),
          ),
        ));
  }
}
