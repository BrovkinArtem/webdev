import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiatia/pages/Portfolio.dart';
import 'package:tiatia/pages/Home.dart';
import 'package:tiatia/pages/Strategy.dart';
import 'package:tiatia/pages/Analytics.dart';
import 'package:tiatia/pages/Account.dart';
import 'package:tiatia/pages/Securities.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home2 extends StatefulWidget {
  const Home2({Key? key}) : super(key: key);

  @override
  State<Home2> createState() => _Home2State();
}

class _Home2State extends State<Home2> {
  bool isBedtimeOutlined = true;

  void _toggleBedtimeIcon() {
    setState(() {
      isBedtimeOutlined = !isBedtimeOutlined;
      if (isBedtimeOutlined) {
        // для светлой темы
      } else {
        // для темной темы
      }
    });
  }

  final TextEditingController _searchController = TextEditingController();
  List<String> _securities = [];
  FocusNode _searchFocusNode = FocusNode();
  bool _isListVisible = false;
  String _selectedSecurity = "";
  bool notificationsRead = false;

  Future<void> fetchSecurities(String query) async {
    final response = await http.get(Uri.parse(
        'https://api.twelvedata.com/symbol_search?symbol=$query&exchange=US&apikey=eccd7ef0256643e8a8407a19bdeca078'));
    final data = json.decode(response.body);
    setState(() {
      _securities = List<String>.from(data['data']
          .where((item) =>
              item['currency'] == 'USD' && item['regularMarketPrice'] != 0)
          .map((item) => item['symbol'])
          .toSet()
          .toList());
    });
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        if (_searchFocusNode.hasFocus) {
          _isListVisible = true;
        } else {
          _isListVisible = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _goToSecurityDetailsPage(String security) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Securities(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            PopupMenuButton(
              icon: Icon(
                Icons.notifications,
                color: notificationsRead
                    ? null
                    : Colors
                        .red, // Изменение цвета иконки, если уведомления не прочитаны
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('Привет! здесь уведомления :)'),
                  value: 1,
                ),
                // Добавьте другие элементы меню с уведомлениями
              ],
              onSelected: (value) {
                // Обработка выбранного уведомления
                if (value == 1) {
                  // Действия для уведомления 1
                } else if (value == 2) {
                  // Действия для уведомления 2
                }

                setState(() {
                  notificationsRead =
                      true; // Устанавливаем флаг, что уведомления были прочитаны
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Account()));
              },
            ),
          ],
          title: Text('Главная'),
        ),
        drawer: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                padding: const EdgeInsets.symmetric(
                    horizontal: 116.0, vertical: 20.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Меню',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                title: Text('Портфель'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Portfolio()),
                  );
                },
              ),
              ListTile(
                title: Text('Аналитика'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Analytics()));
                },
              ),
              ListTile(
                title: Text('Стратегия'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Strategy()));
                },
              ),
              Expanded(
                child: Container(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () async {},
                    icon: Icon(Icons.folder),
                  ),
                  IconButton(
                    onPressed: () async {},
                    icon: Icon(Icons.info),
                  ),
                  IconButton(
                    onPressed: () async {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Home2()));
                    },
                    icon: Icon(Icons.home),
                  ),
                  IconButton(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    icon: Icon(isBedtimeOutlined
                        ? Icons.bedtime_outlined
                        : Icons.bedtime_rounded),
                    onPressed: _toggleBedtimeIcon,
                  ),
                  IconButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    },
                    icon: Icon(Icons.exit_to_app),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Container(
            color: Colors.white, // Голубой цвет фона для всего экрана
            child: Stack(children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.2,
                      vertical: MediaQuery.of(context).size.height * 0.02,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (query) {
                        if (query.isEmpty) {
                          setState(() {
                            _securities = [];
                          });
                        } else {
                          fetchSecurities(query);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Поиск ценных бумаг',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.2,
                        vertical: MediaQuery.of(context).size.height * 0.05,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(45),
                        color: Color(0xFFE6F4F1), // Светло-голубой цвет фона
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                '''                                 🐢            Добро пожаловать в Turtle Invest Advisor!


⬅ слева находится навигационное меню с основным функционалом приложения

⬆ сверху поиск ценных бумаг для дальнейшего добавления их в портфель

↗ справа вверху ваши уведомления и аккаунт с персональными настройками 

                                                                                                                                   советуем заглянуть туда!
                  ''',
                                style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.black), // Чёрный цвет текста
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_securities.isNotEmpty)
                Positioned(
                    top: MediaQuery.of(context).size.height *
                        0.077, // Отступ сверху
                    left:
                        MediaQuery.of(context).size.width * 0.2, // Отступ слева
                    right: MediaQuery.of(context).size.width *
                        0.2, // Отступ справа
                    bottom: MediaQuery.of(context).size.height *
                        0.65, // Отступ снизу
                    child: Container(
                        width: MediaQuery.of(context).size.width * 3 / 4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount:
                                _securities.length > 4 ? 4 : _securities.length,
                            itemBuilder: (BuildContext context, int index) {
                              final security = _securities[index];
                              return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedSecurity = security;
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Securities(),
                                      ),
                                    );
                                  },
                                  child: ListTile(
                                    title: Text(security),
                                  ));
                            })))
            ])));
  }
}
