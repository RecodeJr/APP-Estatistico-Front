import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:app_estatistico_novo/ask_page.dart';
import 'package:app_estatistico_novo/home_page.dart';
import 'package:app_estatistico_novo/profile_page.dart';
import 'package:app_estatistico_novo/portos_page.dart';
import 'package:app_estatistico_novo/bemvindo_page.dart';
import 'package:app_estatistico_novo/login_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';

//void main() => runApp(const PainelUsuario());
void main() => runApp(PainelUsuario());

List<Offset> menuOptions = [
  Offset(120, 120), // Ponto esquerdo
  Offset(-30, -30), // Ponto central
  Offset(-180, -180), // Ponto direito
];

class PainelUsuario extends StatefulWidget {
  @override
  _PainelUsuarioState createState() => _PainelUsuarioState();
}

class _PainelUsuarioState extends State<PainelUsuario> {
  double angle = -pi / 2;
  int selectedOption = 0;

  void updateSelectedOption() {
    int newSelectedOption;
    //Posiçoes novas
    if (angle <= -(11 * pi / 12) || angle >= 11 * pi / 12) {
      newSelectedOption = 3; // Opção 3 (PERFIL)
    } else if (angle >= -pi / 12 && angle <= pi / 12) {
      newSelectedOption = 1; // Opção 1 (SAIR)
    } else if (angle <= -5 * pi / 12 && angle >= -7 * pi / 12) {
      newSelectedOption = 2; // Opção 2 (JOGAR)
    } else {
      newSelectedOption = 0; // Posição Neutra (NADA)
    }
    setState(() {
      selectedOption = newSelectedOption;
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: Size(360, 690),
    );
    return MaterialApp(
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Opacity(
            opacity: 0.75,
            child: AppBar(
              title: Text(
                'APP ESTATÍSTICO',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Fredoka', // replace with your font family
                  fontWeight: FontWeight.w400,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.blue[300]!,
            ),
          ),
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/telas_referencias/paineldeusuario_page.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
                gradient: LinearGradient(
                  colors: [Colors.blue[800]!, Colors.blue[300]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        RenderBox box = context.findRenderObject() as RenderBox;
                        Offset localPosition =
                        box.globalToLocal(details.globalPosition);
                        double newAngle = atan2(
                          localPosition.dy - box.size.height / 2,
                          localPosition.dx - box.size.width / 2,
                        );
                        setState(() {
                          angle = newAngle;
                        });
                        updateSelectedOption();
                      },
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        RenderBox box = context.findRenderObject() as RenderBox;
                        Offset localPosition =
                        box.globalToLocal(details.globalPosition);
                        double newAngle = atan2(
                          localPosition.dy - box.size.height / 2,
                          localPosition.dx - box.size.width / 2,
                        );
                        setState(() {
                          angle = newAngle;
                        });
                        updateSelectedOption();
                      },
                      child: CustomPaint(
                        size: Size(constraints.maxWidth * 0.4,
                            constraints.maxHeight * 0.4),
                        painter: CustomPaintArrow(angle: angle),
                        child: Transform.rotate(
                          angle: angle,
                          child: Container(
                            width: constraints.maxWidth * 0.4,
                            height: constraints.maxHeight * 0.4,
                            child: Image.asset(
                              'assets/images/leme.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  selectedOption != 0
                      ? Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        if (selectedOption == 1) {
                          () async {
                            await limpartoken();
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
                          }
                          ();
                        } else if (selectedOption == 2) {
                          _irParaPerguntas(context);
                        } else if (selectedOption == 3) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ProfilePage()),
                          );
                        }
                      },
                      child: Container(
                        width: constraints.maxWidth * 0.1,
                        height: constraints.maxWidth * 0.1,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(width: 2),
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          size: constraints.maxWidth * 0.08,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                      : SizedBox(),
                  Positioned(
                    // left: constraints.maxWidth * 0.5 -
                    //     40, // Posição horizontal centralizada
                    // bottom: constraints.maxHeight * 0.15, // Posição inferior
                    top: constraints.maxHeight * 0.45,
                    right: constraints.maxWidth * 0.05,
                    child: GestureDetector(
                      onTap: () {
                        () async {
                          await limpartoken();
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
                        }
                        ();
                        setState(() {
                          // angle = pi / 2;
                          angle = 0.0;
                        });
                        updateSelectedOption();
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
                  ),
                  Positioned(
                    // right: constraints.maxWidth * 0.1,
                    // top: constraints.maxHeight * 0.2,
                    top: constraints.maxHeight * 0.25,
                    right: constraints.maxWidth * 0.40,
                    child: GestureDetector(
                      onTap: () {
                        _irParaPerguntas(context);

                        setState(() {
                          //  angle = -pi / 4;
                          angle = -pi / 2;
                        });
                        updateSelectedOption();
                      },
                      child: Container(
                        width: constraints.maxWidth * 0.2,
                        height: constraints.maxWidth * 0.2,
                        decoration: BoxDecoration(
                          color: selectedOption == 2
                              ? Colors.blue[900]!.withOpacity(0.86)
                              : Colors.blue[500]!.withOpacity(0.86),
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(constraints.maxWidth * 0.03),
                        child: Column(
                          children: [
                            Icon(Icons.directions_boat,
                                size: constraints.maxWidth * 0.08,
                                color: Colors.white),
                            Text(
                              'Jogar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: constraints.maxWidth * 0.04,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    // left: constraints.maxWidth * 0.1,
                    // top: constraints.maxHeight * 0.2,
                    top: constraints.maxHeight * 0.45,
                    left: constraints.maxWidth * 0.05,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProfilePage()),
                        );
                        setState(() {
                          //  angle = -3 * pi / 4;
                          angle = -pi;
                        });
                        updateSelectedOption();
                      },
                      child: Container(
                        width: constraints.maxWidth * 0.2,
                        height: constraints.maxWidth * 0.2,
                        decoration: BoxDecoration(
                          color: selectedOption == 3
                              ? Colors.blue[900]!.withOpacity(0.86)
                              : Colors.blue[500]!.withOpacity(0.86),
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(constraints.maxWidth * 0.03),
                        child: Column(
                          children: [
                            Icon(
                              Icons.account_circle,
                              size: constraints.maxWidth * 0.08,
                              color: Colors.white,
                            ),
                            Text(
                              'Perfil',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: constraints.maxWidth * 0.04,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> limpartoken() async {
    SharedPreferences _sharedPreferences =
    await SharedPreferences.getInstance();
    await _sharedPreferences.remove('token');
  }

  void _irParaPerguntas(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('Token não encontrado');
      }
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/user/pendingport'),
        headers: {'Authorization': 'Bearer $token'},
      );

      //mudanças recentes
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PortosPage()),
      );
    } catch (error) {
      print('Erro ao obter ID do porto: $error');
    }
  }
}

class ButtonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width / 4, 0);
    path.lineTo(size.width * 3 / 4, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width * 3 / 4, size.height);
    path.lineTo(size.width / 4, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

//CLASSE PARA SETA DO LEME
class CustomPaintArrow extends CustomPainter {
  final double angle;

  CustomPaintArrow({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final double arrowLength = 15.0;
    final double arrowAngle = pi / 6;

    final Paint paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 -
        arrowLength +
        20; // Aumente esse valor para afastar mais a seta do centro

    final Offset startPoint = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );

    final Offset endPoint = Offset(
      center.dx + (radius + arrowLength) * cos(angle),
      center.dy + (radius + arrowLength) * sin(angle),
    );

    final Path path = Path();
    path.moveTo(endPoint.dx, endPoint.dy);
    path.lineTo(
      endPoint.dx - arrowLength * cos(angle - arrowAngle),
      endPoint.dy - arrowLength * sin(angle - arrowAngle),
    );
    path.moveTo(endPoint.dx, endPoint.dy);
    path.lineTo(
      endPoint.dx - arrowLength * cos(angle + arrowAngle),
      endPoint.dy - arrowLength * sin(angle + arrowAngle),
    );

    // canvas.drawLine(startPoint, endPoint, paint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
