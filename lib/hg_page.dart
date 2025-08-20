import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:app_estatistico_novo/login_page.dart';

class SelectableButton extends StatefulWidget {
  final void Function(String institutionId)? onItemSelected;

  SelectableButton({this.onItemSelected, required Color color});

  @override
  _SelectableButtonState createState() => _SelectableButtonState();
}

class _SelectableButtonState extends State<SelectableButton> {
  String? _selectedItem;
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _siglaTextEditingController = TextEditingController();
  List<Map<String, String>> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUniversityList();
  }

  Future<void> fetchUniversityList() async {
    final cadastro = '${dotenv.env['API_URL']}/register';

    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.get(Uri.parse(cadastro));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['data'] != null) {
          final List<dynamic> universities = data['data'];
          print(universities.runtimeType);
          final List<Map<String, String>> institutionInfoList =
              universities.map((university) {
            return {
              'name': university['nome'].toString(),
              'id': university['id'].toString(),
            };
          }).toList();

          setState(() {
            _items = institutionInfoList;

            _isLoading = false;
          });
        } else {
          print('Dados inválidos na resposta da API ${response.statusCode}');
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        print('Erro na solicitação HTTP: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Erro na solicitação HTTP: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> addNewUniversity(
      String institutionId, String universityName, String sigla) async {
    final createinstituition =
        '${dotenv.env['API_URL']}/register/createinstituition';

    // final cadastro = 'http://200.128.84.12:8080/register';

    // final responseCadastro = await http.get(Uri.parse(cadastro));

    // if (responseCadastro.statusCode == 200) {
    //   final data = jsonDecode(responseCadastro.body);

    //   if (data != null && data['data'] != null) {
    //     final List<dynamic> universities = data['data'];

    //     final List<Map<String, String>> institutionInfoList =
    //         universities.map((university) {
    //       return {
    //         'name': university['nome'].toString(),
    //         'id': university['id'].toString(),
    //       };
    //     }).toList();
    //   }
    // }

    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.post(
        Uri.parse(createinstituition),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'instiName': universityName,
          'instiSigla': sigla,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final id = data['data'].toString();
        print(id.runtimeType);
        fetchUniversityList();

        setState(() {
          _isLoading = false;
          _selectedItem = universityName;
          _items.insert(_items.length - 1, {'name': universityName, 'id': id});
        });

        if (widget.onItemSelected != null) {
          widget.onItemSelected!(id);
        }

        setState(() {});
      } else {
        print('Erro na solicitação HTTP: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Erro na solicitação HTTP: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _siglaTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _isLoading
              ? CircularProgressIndicator()
              : DropdownButtonFormField<String>(
                  value: _selectedItem,
                  hint: Text('Selecione uma instituição'),
                  items: _items.map((item) {
                    return DropdownMenuItem<String>(
                      value: item['name']!,
                      child: Text(item['name']!),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedItem = value;
                    });

                    if (widget.onItemSelected != null) {
                      String selectedId = _items.firstWhere(
                          (item) => item['name'] == value)['id'] as String;
                      widget.onItemSelected!(selectedId);
                    }
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo Obrigatório';
                    }
                    return null;
                  },
                ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
