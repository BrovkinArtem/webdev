import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiatia/pages/Home2.dart';
import 'package:tiatia/pages/Portfolio.dart';
import 'package:tiatia/pages/Strategy.dart';
import 'package:tiatia/pages/Home.dart';
import 'package:tiatia/pages/Analytics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tiatia/pages/Archive.dart';
import 'package:tiatia/pages/Securities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class Portfolio2 {
  final int portfolioId;
  final int budget;
  final int periodisity;
  final int term;
  final bool tinkoff;
  final bool notifications;
  final String userId;

  Portfolio2({
    required this.portfolioId,
    required this.budget,
    required this.periodisity,
    required this.term,
    required this.tinkoff,
    required this.notifications,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'portfolio_id': portfolioId,
      'budget': budget,
      'periodisity': periodisity,
      'term': term,
      'tinkoff': tinkoff,
      'notifications': notifications,
      'user_id': userId,
    };
  }

  Future<void> savePortfolio(Portfolio2 portfolio2) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Portfolios')
        .doc('1'); // Установите название "1" в .doc()
    await docRef.set(portfolio2.toMap());
  }

  Future<void> updatePortfolio(Portfolio2 portfolio2) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final result = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Portfolios')
        .where('user_id', isEqualTo: portfolio2.userId)
        .limit(1)
        .get();
    if (result.docs.isNotEmpty) {
      final docRef = result.docs.first.reference;
      await docRef.update(portfolio2.toMap());
    } else {
      await savePortfolio(portfolio2);
    }
  }
}

Future<bool> hasPortfolio(String userId) async {
  final result = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('Portfolios')
      .limit(1)
      .get();
  return result.docs.isNotEmpty;
}

class NotificationsProvider extends ChangeNotifier {
  bool _notificationsRead = false;

  bool get notificationsRead => _notificationsRead;

  void markNotificationsAsRead() {
    _notificationsRead = true;
    notifyListeners();
  }
}

class _AccountState extends State<Account> {
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
  String _value = 'Yes';
  FocusNode _searchFocusNode = FocusNode();
  bool _isListVisible = false;
  final budgetController = TextEditingController();
  final periodController = TextEditingController();
  final srokController = TextEditingController();
  bool _isTinkoffEnabled = true;
  bool _isNotifEnabled = true;
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

  double _getTextSize(double fontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenRatio = screenWidth / screenHeight;
    if (screenRatio > 1) {
      // Десктоп
      return fontSize;
    } else {
      // Мобильное устройство
      return fontSize * 0.8;
    }
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
                        .white, // Изменение цвета иконки, если уведомления не прочитаны
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('Привет! здесь уведомления :)'),
                  value: 1,
                ),
                // другие элементы меню с уведомлениями
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
              onPressed: () {},
            ),
          ],
          title: Text('Личный кабинет'),
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Portfolio()));
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
                    onPressed: () async {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Archive()));
                    },
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
        body: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
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
                      SizedBox(height: 20),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                          color: Color(0xFFE6F4F1),
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('Portfolios')
                                  .doc('1')
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snapshot.hasError) {
                                  return Text(
                                    'Ошибка получения данных: ${snapshot.error}',
                                    style: TextStyle(fontSize: 20),
                                  );
                                }

                                if (snapshot.hasData &&
                                    snapshot.data!.data() != null) {
                                  final portfolioData = snapshot.data!.data()
                                      as Map<String, dynamic>;
                                  final budget = portfolioData['budget'] as int;
                                  final periodisity =
                                      portfolioData['periodisity'] as int;
                                  final term = portfolioData['term'] as int;
                                  final tinkoffEnabled =
                                      portfolioData['tinkoff'] as bool;
                                  final notificationsEnabled =
                                      portfolioData['notifications'] as bool;

                                  return Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            'Бюджет: $budget',
                                            style: TextStyle(
                                                fontSize: _getTextSize(24)),
                                          ),
                                          Text(
                                            'Периодичность: $periodisity',
                                            style: TextStyle(
                                                fontSize: _getTextSize(24)),
                                          ),
                                          Text(
                                            'Срок: $term',
                                            style: TextStyle(
                                                fontSize: _getTextSize(24)),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            'Tinkoff: ${tinkoffEnabled ? "Включено" : "Выключено"}',
                                            style: TextStyle(
                                                fontSize: _getTextSize(24)),
                                          ),
                                          Text(
                                            'Уведомления: ${notificationsEnabled ? "Включены" : "Выключены"}',
                                            style: TextStyle(
                                                fontSize: _getTextSize(24)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                } else {
                                  return Column(
                                    children: [
                                      Text(
                                        'Бюджет:',
                                        style: TextStyle(
                                            fontSize: _getTextSize(24)),
                                      ),
                                      Text(
                                        'Периодичность:',
                                        style: TextStyle(
                                            fontSize: _getTextSize(24)),
                                      ),
                                      Text(
                                        'Срок:',
                                        style: TextStyle(
                                            fontSize: _getTextSize(24)),
                                      ),
                                      Text(
                                        'Tinkoff:',
                                        style: TextStyle(
                                            fontSize: _getTextSize(24)),
                                      ),
                                      Text(
                                        'Уведомления:',
                                        style: TextStyle(
                                            fontSize: _getTextSize(24)),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                            SizedBox(height: 10),
                            Column(
                              children: [
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  controller: budgetController,
                                  decoration: InputDecoration(
                                    labelText: 'Бюджет',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.edit),
                                  ),
                                  onChanged: (value) {
                                    // Обработка изменений
                                  },
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  controller: periodController,
                                  decoration: InputDecoration(
                                    labelText: 'Периодичность',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.edit),
                                  ),
                                  onChanged: (value) {
                                    // Обработка изменений
                                  },
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  controller: srokController,
                                  decoration: InputDecoration(
                                    labelText: 'Срок',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.edit),
                                  ),
                                  onChanged: (value) {
                                    // Обработка изменений
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            SwitchListTile(
                              title: Text('Покупки через Tinkoff'),
                              value: _isTinkoffEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _isTinkoffEnabled = value;
                                });
                              },
                            ),
                            SizedBox(height: 10),
                            SwitchListTile(
                              title: Text('Уведомления'),
                              value: _isNotifEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _isNotifEnabled = value;
                                });
                              },
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () async {
                                final budget =
                                    int.tryParse(budgetController.text) ?? 0;
                                final periodisity =
                                    int.tryParse(periodController.text) ?? 0;
                                final term =
                                    int.tryParse(srokController.text) ?? 0;
                                User? currentUser =
                                    FirebaseAuth.instance.currentUser;
                                final userDoc = await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(currentUser!.uid)
                                    .get();
                                final portfolioId =
                                    userDoc.data()?['portfolio_id'] ?? 0;
                                final portfolio = Portfolio2(
                                  portfolioId: portfolioId,
                                  budget: budget,
                                  periodisity: periodisity,
                                  term: term,
                                  tinkoff: _isTinkoffEnabled,
                                  notifications: _isNotifEnabled,
                                  userId: currentUser.uid,
                                );
                                await portfolio.updatePortfolio(portfolio);

                                setState(() {
                                  // Обновление значений контроллеров
                                  budgetController.text = budget.toString();
                                  periodController.text =
                                      periodisity.toString();
                                  srokController.text = term.toString();
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Портфель сохранен')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                textStyle: TextStyle(fontSize: 20),
                                padding: EdgeInsets.all(16),
                              ),
                              child: Text('Сохранить портфель'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      if (_securities.isNotEmpty)
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.077,
                          left: 0,
                          right: 0,
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
                              itemCount: _securities.length > 4
                                  ? 4
                                  : _securities.length,
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
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                    ]))));
  }
}
