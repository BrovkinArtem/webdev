import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiatia/pages/Home2.dart';
import 'package:tiatia/pages/Portfolio.dart';
import 'package:tiatia/pages/Strategy.dart';
import 'package:tiatia/pages/Home.dart';
import 'package:tiatia/pages/Account.dart';
import 'package:tiatia/pages/Securities.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class NotificationsProvider extends ChangeNotifier {
  bool _notificationsRead = false;

  bool get notificationsRead => _notificationsRead;

  void markNotificationsAsRead() {
    _notificationsRead = true;
    notifyListeners();
  }
}

class _AnalyticsState extends State<Analytics> {
bool isBedtimeOutlined = true;

  void _toggleBedtimeIcon() {
    setState(() {
      isBedtimeOutlined = !isBedtimeOutlined;
    });
  }

final TextEditingController _searchController = TextEditingController();
  List<String> _securities = [];
  FocusNode _searchFocusNode = FocusNode();
  bool _isListVisible = false;
  String _selectedSecurity = "";
  String _selectedPrice = '';
  String _selectedTicker = '';
  bool notificationsRead = false;


  Future<void> fetchSecurities(String query) async {
  final response = await http.get(Uri.parse(
      'https://api.twelvedata.com/symbol_search?symbol=$query&exchange=US&apikey=eccd7ef0256643e8a8407a19bdeca078'));
  final data = json.decode(response.body);
  setState(() {
    _securities = List<String>.from(data['data']
        .where((item) => item['currency'] == 'USD' && item['regularMarketPrice'] != 0)
        .map((item) => item['symbol'])
        .toSet()
        .toList());
  });
}

  Future<double> fetchSecurityPrice(String symbol) async {
  final response = await http.get(Uri.parse(
      'https://api.twelvedata.com/price?symbol=$symbol&apikey=eccd7ef0256643e8a8407a19bdeca078'));
  final data = json.decode(response.body);
  final price = data['price'].toString();
  if (price.isNotEmpty) {
    return double.parse(price);
  }
  return 0.0; // Return a default value if the price is empty
}

  Future<double> calculatePortfolioPrice() async {
  double portfolioPrice = 0.0;

  final securitiesSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('securities')
      .get();

  for (final securityDoc in securitiesSnapshot.docs) {
    final securityData = securityDoc.data();
    final ticker = securityData['ticker'] as String;
    final bought = securityData['bought'] as double;

    final price = await fetchSecurityPrice(ticker);
    portfolioPrice += price * bought;
  }

  return double.parse(portfolioPrice.toStringAsFixed(2));
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
    color: notificationsRead ? null : Colors.white, // Изменение цвета иконки, если уведомления не прочитаны
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
      notificationsRead = true; // Устанавливаем флаг, что уведомления были прочитаны
    });
  },
),
          IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Account())
    );
              },
            ),
        ],
        title: Text('Analytics'),
      ),
      drawer: Drawer(
    child: Column(

      children: [
        DrawerHeader(
          padding: const EdgeInsets.symmetric(horizontal: 116.0, vertical: 20.0),
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
    MaterialPageRoute(builder: (context) => Portfolio())
    );
          },
        ),
        ListTile(
          title: Text('Аналитика'),
          onTap: () {
            // Обработка нажатия на пункт меню
          },
        ),
        ListTile(
          title: Text('Стратегия'),
          onTap: () {
            Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Strategy())
    );
          },),
          Expanded(
        child: Container(),
      ),
      Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    IconButton(
      onPressed: () async {
      },
      icon: Icon(Icons.folder),
    ),
    IconButton(
      onPressed: () async {
      },
      icon: Icon(Icons.info),
    ),
    IconButton(
      onPressed: () async {
        Navigator.push(
    context,
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
        DefaultTabController(
  length: 2, // Количество вкладок
  child: Expanded(
    child: Container(
              margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.2,
              vertical: MediaQuery.of(context).size.height * 0.05,
            ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(45),
        color: Color(0xFFE6F4F1),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Аналитика портфеля'),
              Tab(text: 'Аналитика ценных бумаг'),
            ],
          ),
          Expanded(
  child: TabBarView(
    children: [
      // Содержимое первой вкладки "Аналитика портфеля"
      FutureBuilder<double>(
        future: calculatePortfolioPrice(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final portfolioPrice = snapshot.data!;
            return Center(
              child: Text(
                'Цена портфеля: $portfolioPrice \$',
                style: TextStyle(fontSize: 48),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Пожалуйста, повторите попытку позже',
                style: TextStyle(fontSize: 48),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      // Содержимое второй вкладки "Аналитика ценных бумаг"
      FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
    } else if (snapshot.hasError) {
      return Center(
        child: Text(
          'Пожалуйста, повторите попытку позже',
          style: TextStyle(fontSize: 48),
        ),
      );
    } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Center(
        child: Text(
          'Нет доступных ценных бумаг',
          style: TextStyle(fontSize: 48),
        ),
      );
    } else {
      final securitiesSnapshot = snapshot.data!;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButton<String>(
            value: _selectedTicker,
            hint: Text('Выберите ценную бумагу'), // Initial hint text
            onChanged: (String? newValue) {
              setState(() {
                _selectedTicker = newValue!;
              });
            },
            items: [
              DropdownMenuItem<String>(
                value: '',
                child: Text('Выберите ценную бумагу'),
              ),
              ...securitiesSnapshot.docs.map((DocumentSnapshot document) {
                final securityData = document.data() as Map<String, dynamic>;
                final ticker = securityData['ticker'] as String;
                return DropdownMenuItem<String>(
                  value: ticker,
                  child: Text(ticker),
                );
              }).toList(),
            ],
          ),
          if (_selectedTicker.isNotEmpty)
            FutureBuilder<double>(
              future: fetchSecurityPrice(_selectedTicker),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final selectedPrice = snapshot.data!;
                  final selectedSecurityDocument = securitiesSnapshot.docs.firstWhere(
                    (document) => document['ticker'] == _selectedTicker,
                  );
                  final bought = selectedSecurityDocument['bought'] as double;
                  final totalPrice = (selectedPrice * bought).toStringAsFixed(2);

                  return Center(
                    child: Text(
                      '$totalPrice \$',
                      style: TextStyle(fontSize: 48),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Пожалуйста, повторите ошибку позже',
                      style: TextStyle(fontSize: 48),
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
        ],
      );
    }
  },
),
    ],
  ),
),
        ],
      ),
    ),
  ),
)
      ],
    ),
    if (_securities.isNotEmpty)
      Positioned(
        top: MediaQuery.of(context).size.height * 0.077, // Отступ сверху
        left: MediaQuery.of(context).size.width * 0.2, // Отступ слева
        right: MediaQuery.of(context).size.width * 0.2, // Отступ справа
        bottom: MediaQuery.of(context).size.height * 0.65, // Отступ снизу
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
            itemCount: _securities.length > 4 ? 4 : _securities.length,
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
                    )
                  );
                }
              )
            )
          )
  ],
),);
  }
}