import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiatia/pages/Home2.dart';
import 'package:tiatia/pages/Portfolio.dart';
import 'package:tiatia/pages/Analytics.dart';
import 'package:tiatia/pages/Home.dart';
import 'package:tiatia/pages/Info.dart';
import 'package:tiatia/pages/Account.dart';
import 'package:tiatia/pages/Securities.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:tiatia/pages/archive.dart';
import 'package:tiatia/recomendation.dart';
import 'package:tiatia/stock.dart';

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
                  onPressed: () async {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Info()));
                  },
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
                    List<Stock> stocks = [];
                    // List<String> tickers = [];
                    // List<int> amounts = [];
                    // List<double> boughtPrices = [];
                    // List<String> terms = [];
                    var nowDate = DateTime.now().toString();
                    for (var tickerDoc in tickerDocs) {
                      stocks.add(Stock(tickerDoc['ticker'], tickerDoc['amount'],
                          tickerDoc['bought'], tickerDoc['term'], nowDate));
                      // tickers.add(tickerDoc['ticker']);
                      // amounts.add(tickerDoc['amount']);
                      // boughtPrices.add(tickerDoc['bought']);
                      // terms.add(tickerDoc['term']);
                    }
                    // final portfolioDoc = snapshot.data!.docs.first;
                    //ПЕРЕДЕЛАТЬ АЛГОРИТМ!!!!!!!!!!!!!!!!!!!!!!!!!
                    // Считаем текущий день инвестирования
                    var schedule2 = AVGstrategy(stocks, 3000, 2);
                    // final currentDate = DateTime.now();

                    // // Считаем бюджет на портфель
                    // var budget = 3000; // пример

                    // // Считаем срок портфеля
                    // final portfolioDuration = Duration(days: 40); // пример

                    // // Считаем периодичность
                    // final investmentPeriod = Duration(days: 2); // пример

                    // // Формируем рекомендации по закупкам для бумаг со сроком
                    // List<String> recommendationsWithTerm = [];

                    // for (var i = 0; i < tickers.length; i++) {
                    //   if (terms[i].isNotEmpty) {
                    //     final termDate = DateFormat('dd.MM.yyyy').parse(terms[i]);
                    //     final periodsLeft = termDate.difference(currentDate).inDays ~/ investmentPeriod.inDays;

                    //     if (periodsLeft > 0) {
                    //       final stocksPerPeriod = amounts[i] ~/ periodsLeft;
                    //       final stockPrice = boughtPrices[i] * 1.1; // пример
                    //       final totalStocksPrice = stocksPerPeriod * stockPrice;

                    //       if (totalStocksPrice <= budget) {
                    //         budget -= totalStocksPrice as int;
                    //         final nextPurchaseDate = currentDate.add(Duration(days: periodsLeft * investmentPeriod.inDays));
                    //         recommendationsWithTerm.add('${tickers[i]} - $stocksPerPeriod - ${nextPurchaseDate.toIso8601String()}');
                    //       }
                    //     }
                    //   }
                    // }

                    // Формируем рекомендации по закупкам для бумаг без срока
                    // List<String> recommendationsWithoutTerm = [];
                    // for (var i = 0; i < tickers.length; i++) {
                    //   if (terms[i].isEmpty) {
                    //     final stockPrice = boughtPrices[i] * 1.1; // пример
                    //     final stocksAmount = (budget / stockPrice).floor();

                    //     if (stocksAmount > 0) {
                    //       budget -= (stocksAmount * stockPrice) as int;
                    //       recommendationsWithoutTerm.add('${tickers[i]} - $stocksAmount');
                    //     }
                    //   }
                    // }
                    List<Recomendation> recos = [];
                    schedule2.forEach((key, value) {
                      var reca = Recomendation(
                          key, value['count'], value['date'].toString());
                      recos.add(reca);
                    });
                    // Возвращаем список рекомендаций
                    // final allRecommendations = [...recommendationsWithTerm, ...recommendationsWithoutTerm];

                    return ListView.builder(
                      itemCount: recos.length,
                      itemBuilder: (context, index) {
                        final recommendation = recos[index];
                        final ticker = recommendation.ticker;
                        final amountOrStocksPerPeriod =
                            recommendation.count.toString();
                        /*final nextDate = recommendation.length > 2 ? 
      DateTime.parse(recommendation[2]) 
      : null;*/
                        final nextDate =
                            DateTime.parse(recommendation.investDay);

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
                                'Нужно купить',
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
                                  'Дата покупки',
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

Map AVGstrategy(List<Stock> portfolio, num period_budget, num period) {
  var schedule = new Map();
  if (period_budget == 0) {
    return schedule;
  }
  // Лист для Цб с deadline
  var stockWithTerm = Map();
  // Словарь для ЦБ без deadline
  var stockWithoutTerm = Map();
  // Словарь, который будет содержать конечные рекомендации

  // Самый высокий процент закупки у ЦБ без deadline
  num goal = 0;
  for (var stock in portfolio) {
    // Ихначально заполняем расписание закупок значениями по умолчанию
    schedule[stock.ticker] = {'count': '0', 'date': DateFormat};
    // Для бумаг без deadline
    if (stock.term == 'none') {
      // Опредляем процент закупки у ЦБ
      num boughtPercent = 100 * stock.bought ~/ stock.amount;
      // Ищем самый высокий процент закупки
      if (goal < boughtPercent) {
        goal = boughtPercent;
      }
      stockWithoutTerm[stock.ticker] = {
        'stock': stock,
        'boughtPercent': boughtPercent
      };
    }
    // Для бумаг с deadline
    else {
      stockWithTerm[stock.ticker] = stock;
    }
    // turples = list(stockWithoutTerm.items())
    // print(turples[0])
  }

  // Определяем рекомендации для ЦБ со сроком
  for (var stock in stockWithTerm.values) {
    // if not (schedule[stock.ticker]['date'] is None):
    //     continue
    // Берётся информация о последнем дне инвестирования этой ценной бумаги
    var lastInvestDay = DateTime.parse(stock.lastInvestDay);
    List<int> termParams = [];
    for (var element in stock.term.split('.')) {
      int intel = int.parse(element);
      termParams.add(intel);
    }
    // Берётся информация о deadline это ценной бумаги
    var term = DateTime.utc(termParams[2], termParams[1], termParams[0]);
    // Юерётся сегодняшнее число
    var now = DateTime.now();
    // Расчитывается оставшееся время
    var diffT = term.difference(now);
    var interval = diffT.inDays;

    if (interval <= 0) {
      schedule[stock.ticker]['count'] = -1;
      schedule[stock.ticker]['date'] = lastInvestDay;
      continue;
    }

    // Рассчитывается оставшееся количество инвест-дней
    var iterations = interval ~/ period;
    // Расчитывается, сколько ценных бумаг нужно купить за один инвест-день
    var count = (stock.amount - stock.bought) ~/ iterations;
    if (count == 0 && stock.amount > stock.bought) {
      count += 1;
    }
    // Расчитывается необхожимое количество денег для закупки этой ЦБ в один инвест-день
    var summa = stock.price * count;
    // Если бюджета не хватает, то уменьшаем закупаемое кол-во
    if (period_budget < summa) {
      count = period_budget ~/ stock.price;
      summa = stock.price * count;
    }
    // Вычитаем из бюджета на период траты на эту ЦБ (эту цб мы должны закупать каждый инвест-день в этом кол-ве,
    // поэтому нужно включить эти расходы для послдующих вычислений)
    period_budget -= summa;
    // Внесение
    schedule[stock.ticker]['count'] = count;
    schedule[stock.ticker]['date'] = lastInvestDay.toString();
  }
  //
  var stabilization = false;
  var n = 0;
  var budget = period_budget;
  while (stabilization == false) {
    var sortedStock = List.from(stockWithoutTerm.values);
    sortedStock.sort((a, b) => a.boughtPercent.compareTo(b.boughtPercent));
    //var sortedStock = sorted(list(stockWithoutTerm.items()), key=lambda x: x[1]['boughtPercent']);
    // all = True
    stabilization = true;
    for (var stockInfo in sortedStock) {
      //
      var stock = stockInfo[1]['stock'];
      // Берётся информация о последнем дне инвестирования этой ценной бумаги
      //var lidParams = stock.lastInvestDay.split('-');
      //var lastInvestDay = DateFormat(int(lidParams[0]), int(lidParams[1]), int(lidParams[2]));
      //var lastInvestDay = DateFormat.yMd(DateTime.parse(stock.lastInvestDay));
      // Определяется, какое количество ЦБ в 1% от необходимого числа
      var countOnPercent = stock.amount / 100;
      // Определяем сколько процентов нужно докупить
      var needlPercent = goal - stockInfo[1]['boughtPercent'];
      // Определяем, сколько для этого нужно купить ЦБ
      var count = (needlPercent * countOnPercent ~/ 1).round();
      // Определяем необходимую сумму для закупки4
      var summa = stock.price * count;
      // Если бюджета не хватает, то уменьшаем покупаемое количество
      if (budget < summa) {
        count = budget ~/ stock.price;
        summa = stock.price * count;
      }
      // Вычитаем сумму на покупку из бюджета
      budget -= summa;
      // Обновляем процент закупки для ЦБ
      stockInfo[1]['boughtPercent'] =
          (100 * ((stock.bought + count) / stock.amount)).round();

      if (stockInfo[1]['boughtPercent'] < goal) {
        stabilization = false;
      }

      // Вносим информацию о рекомендации
      if (count != 0 && schedule[stock.ticker]['date'] == 'none') {
        schedule[stock.ticker]['count'] = count;
        var lastInvestDay = DateTime.parse(stock.lastInvestDay)
            .add((Duration(days: period.toInt() * n)));
        schedule[stock.ticker]['date'] = lastInvestDay;
      }

      // if (stockInfo['boughtPercent'] < goal or schedule[stock.ticker]['date'] is None):
      //     all = False
    }

    if (stabilization) {
      var totalSumma = 0.0;
      var count = 0;
      for (var stock in stockWithoutTerm.values) {
        var price = stock[1]['stock'].price;
        totalSumma += price;
      }
      if (totalSumma == 0) {
        break;
      }
      if (totalSumma <= budget) {
        count = (budget ~/ totalSumma).round();
        for (var stockInfo in stockWithoutTerm.values) {
          var stock = stockInfo[1]['stock'];
          if (schedule[stock.ticker]['date'] == 'none') {
            // Берётся информация о последнем дне инвестирования этой ценной бумаги
            //var lidParams = stock.lastInvestDay.split('-');
            //var lastInvestDay = DateFormat(int(lidParams[0]), int(lidParams[1]), int(lidParams[2]));
            var lastInvestDay = DateTime.parse(stock.lastInvestDay);
            schedule[stock.ticker]['count'] = count;
            int number = period.toInt() * n;
            var day = DateTime.parse(stock.lastInvestDay);
            lastInvestDay = day.add(Duration(days: number));
            schedule[stock.ticker]['date'] = lastInvestDay;
          } else {
            schedule[stock.ticker]['count'] += count;
          }
        }
      } else {
        for (var stockInfo in stockWithoutTerm.values) {
          var stock = stockInfo[1]['stock'];
          while (budget < stock.price) {
            budget += period_budget;
            n += 1;
          }
          //var lidParams = stock.lastInvestDay.split('-');
          //var lastInvestDay = DateFormat(int(lidParams[0]), int(lidParams[1]), int(lidParams[2]));
          var lastInvestDay = DateTime.parse(stock.lastInvestDay)
              .add((Duration(days: period.toInt() * n)));
          budget -= stock.price;
          schedule[stock.ticker]['count'] += 1;
          schedule[stock.ticker]['date'] = lastInvestDay;
        }
        budget += period_budget;
        n += 1;
      }
    }
    budget += period_budget;
    n += 1;
  }
  // нужно начать равномерно закупать ЦБ
  // нужно посчитать, сколько стоит 1 каждой недоклупленной
  // если денег хватает, то добавлять остальных
  // если всё равно хватает, то посчитать, насколько раз хватит

  return schedule;
}
