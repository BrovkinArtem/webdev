import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiatia/pages/Home2.dart';
import 'package:tiatia/pages/Portfolio.dart';
import 'package:tiatia/pages/Analytics.dart';
import 'package:tiatia/pages/Archive.dart';
import 'package:tiatia/pages/Home.dart';
import 'package:tiatia/pages/Account.dart';
import 'package:tiatia/pages/Securities.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class Strategy extends StatefulWidget {
  const Strategy({super.key});

  @override
  State<Strategy> createState() => _StrategyState();
}

class NotificationsProvider extends ChangeNotifier {
  bool _notificationsRead = false;

  bool get notificationsRead => _notificationsRead;

  void markNotificationsAsRead() {
    _notificationsRead = true;
    notifyListeners();
  }
}

class _StrategyState extends State<Strategy> {
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
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Account()));
            },
          ),
        ],
        title: Text('Стратегия'),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              padding:
                  const EdgeInsets.symmetric(horizontal: 116.0, vertical: 20.0),
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
                // Обработка нажатия на пункт меню
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
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('securities')
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text('Ошибка получения данных: ${snapshot.error}');
                    }
                    if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                      return Container(
                        alignment: Alignment.center,
                        child: Text(
                          'У вас нет ценных бумаг, воспользуйтесь поиском',
                          style: TextStyle(fontSize: 24),
                        ),
                      );
                    }
                    final tickerDocs = snapshot.data!.docs;
                    List<String> tickers = [];
                    List<int> amounts = [];
                    List<double> boughtPrices = [];
                    List<String> terms = [];
                    List<int> activeIndices =
                        []; // Список индексов активных ценных бумаг
                    for (int i = 0; i < tickerDocs.length; i++) {
                      var tickerDoc = tickerDocs[i];
                      if (tickerDoc['is_active'] == true) {
                        tickers.add(tickerDoc['ticker']);
                        amounts.add(tickerDoc['amount']);
                        boughtPrices.add(tickerDoc['bought']);
                        terms.add(tickerDoc['term']);
                        activeIndices.add(i);
                      }
                    }
                    final portfolioDoc = snapshot.data!.docs.first;
                    //ПЕРЕДЕЛАТЬ АЛГОРИТМ!!!!!!!!!!!!!!!!!!!!!!!!!
                    // Считаем текущий день инвестирования
                    final currentDate = DateTime.now();

                    // Считаем бюджет на портфель
                    var budget = 3000; // пример

                    // Считаем срок портфеля
                    final portfolioDuration = Duration(days: 40); // пример

                    // Считаем периодичность
                    final investmentPeriod = Duration(days: 2); // пример

                    // Формируем рекомендации по закупкам для бумаг со сроком
                    List<String> recommendationsWithTerm = [];

                    for (var i = 0; i < tickers.length; i++) {
                      if (terms[i].isNotEmpty) {
                        final termDate =
                            DateFormat('dd.MM.yyyy').parse(terms[i]);
                        final periodsLeft =
                            termDate.difference(currentDate).inDays ~/
                                investmentPeriod.inDays;

                        if (periodsLeft > 0) {
                          final stocksPerPeriod = amounts[i] ~/ periodsLeft;
                          final stockPrice = boughtPrices[i] * 1.1; // пример
                          final totalStocksPrice = stocksPerPeriod * stockPrice;

                          if (totalStocksPrice <= budget) {
                            budget -= totalStocksPrice as int;
                            final nextPurchaseDate = currentDate.add(Duration(
                                days: periodsLeft * investmentPeriod.inDays));
                            recommendationsWithTerm.add(
                                '${tickers[i]} - $stocksPerPeriod - ${nextPurchaseDate.toIso8601String()}');
                          }
                        }
                      }
                    }

                    // Формируем рекомендации по закупкам для бумаг без срока
                    List<String> recommendationsWithoutTerm = [];
                    for (var i = 0; i < tickers.length; i++) {
                      if (terms[i].isEmpty) {
                        final stockPrice = boughtPrices[i] * 1.1; // пример
                        final stocksAmount = (budget / stockPrice).floor();

                        if (stocksAmount > 0) {
                          budget -= (stocksAmount * stockPrice) as int;
                          recommendationsWithoutTerm
                              .add('${tickers[i]} - $stocksAmount');
                        }
                      }
                    }

                    // Возвращаем список рекомендаций
                    final allRecommendations = [
                      ...recommendationsWithTerm,
                      ...recommendationsWithoutTerm
                    ];

                    return ListView.builder(
                      itemCount: allRecommendations.length,
                      itemBuilder: (context, index) {
                        final recommendation =
                            allRecommendations[index].split(' - ');
                        final ticker = recommendation[0];
                        final amountOrStocksPerPeriod = recommendation[1];
                        final nextDate = recommendation.length > 2
                            ? DateTime.parse(recommendation[2])
                            : null;

                        return Container(
                          color: Color(0xFFE6F4F1),
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Тикер',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                ticker,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Рекомендация:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                amountOrStocksPerPeriod,
                                textAlign: TextAlign.center,
                              ),
                              if (nextDate != null) ...[
                                SizedBox(height: 8.0),
                                Text(
                                  'Дата следующей покупки:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  DateFormat.yMMMd().format(nextDate),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              SizedBox(height: 8.0),
                              Divider(),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
          if (_securities.isNotEmpty)
            Positioned(
                top:
                    MediaQuery.of(context).size.height * 0.077, // Отступ сверху
                left: MediaQuery.of(context).size.width * 0.2, // Отступ слева
                right: MediaQuery.of(context).size.width * 0.2, // Отступ справа
                bottom:
                    MediaQuery.of(context).size.height * 0.65, // Отступ снизу
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
        ],
      ),
    );
  }
}
