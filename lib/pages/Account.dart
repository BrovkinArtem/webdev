import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiatia/pages/Portfolio.dart';
import 'package:tiatia/pages/Strategy.dart';
import 'package:tiatia/pages/Home.dart';
import 'package:tiatia/pages/Analytics.dart';
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
  final docRef = FirebaseFirestore.instance.collection('Portfolios').doc();
  await docRef.set(portfolio2.toMap());
}

Future<void> updatePortfolio(Portfolio2 portfolio2) async {
  final result = await FirebaseFirestore.instance
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
      .collection('Portfolios')
      .where('user_id', isEqualTo: userId)
      .limit(1)
      .get();
  return result.docs.isNotEmpty;
}

class _AccountState extends State<Account> {
bool isBedtimeOutlined = true;

  void _toggleBedtimeIcon() {
    setState(() {
      isBedtimeOutlined = !isBedtimeOutlined;
    });
  }

final TextEditingController _searchController = TextEditingController();
  List<String> _securities = [];
  String _value = 'Yes';
  FocusNode _searchFocusNode = FocusNode();
  bool _isListVisible = false;
  final budgetController = TextEditingController(text: '30000');
  final periodController = TextEditingController(text: '2');
  final srokController = TextEditingController(text: '40');
  bool _isTinkoffEnabled = true;
  bool _isNotifEnabled = true;
  String _selectedSecurity = "";


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
          IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {},
            ),
          IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {},
            ),
        ],
        title: Text('Account'),
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
            Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Analytics())
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 250.0, vertical: 16.0),
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
        Container(
  height: 700, // потом поменять на что-то не фиксированное
  margin: const EdgeInsets.symmetric(horizontal: 400.0),
  decoration: BoxDecoration(
    border: Border.all(
      color: Colors.grey,
      width: 1,
    ),
    borderRadius: BorderRadius.circular(10),
  ),
  child: Column(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
    Text(
      'Personal cab',
      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
    ),
          Expanded(
  child: TextFormField(
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
      if (value.isNotEmpty) {
        final budget = int.parse(value);
        if (budget > 10000000) {
          budgetController.value = budgetController.value.copyWith(
            text: budgetController.text.substring(0, budgetController.text.length - 1),
            selection: TextSelection.collapsed(offset: budgetController.text.length - 1),
          );
        }
      }
    },
  ),
),
      Expanded(
  child: TextFormField(
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
      if (value.isNotEmpty) {
        final period = int.parse(value);
        if (period > 365) {
          periodController.value = periodController.value.copyWith(
            text: periodController.text.substring(0, periodController.text.length - 1),
            selection: TextSelection.collapsed(offset: periodController.text.length - 1),
          );
        }
      }
    },
  ),
),
      Expanded(
  child: TextFormField(
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
      if (value.isNotEmpty) {
        final srok = int.parse(value);
        if (srok > 1000) {
          srokController.value = srokController.value.copyWith(
            text: srokController.text.substring(0, srokController.text.length - 1),
            selection: TextSelection.collapsed(offset: srokController.text.length - 1),
          );
        }
      }
    },
  ),
),
      SwitchListTile(
  title: Text('Покупки через Tinkoff'),
  value: _isTinkoffEnabled,
  onChanged: (value) {
    setState(() {
      _isTinkoffEnabled = value;
    });
  },
),
SwitchListTile(
  title: Text('Уведомления'),
  value: _isNotifEnabled,
  onChanged: (value) {
    setState(() {
      _isNotifEnabled = value;
    });
  },
),ElevatedButton(
  onPressed: () async {
    final budget = int.tryParse(budgetController.text) ?? 0;
    final periodisity = int.tryParse(periodController.text) ?? 0;
    final term = int.tryParse(srokController.text) ?? 0;
    User? currentUser = FirebaseAuth.instance.currentUser;
    final userDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(currentUser!.uid)
    .get();

    final portfolioId = userDoc.data()?['portfolio_id'] ?? 0;
    final Portfolio = Portfolio2(
      portfolioId: portfolioId, // TODO: заменить на реальный идентификатор портфеля
      budget: budget,
      periodisity: periodisity,
      term: term,
      tinkoff: _isTinkoffEnabled,
      notifications: _isNotifEnabled,
      userId: currentUser!.uid,
    );
  await Portfolio.updatePortfolio(Portfolio);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Портфель сохранен')),
    );
    
  },style: ElevatedButton.styleFrom(
      textStyle: TextStyle(fontSize: 20),
      padding: EdgeInsets.all(16),
  ),
  child: Text('Сохранить портфель'),
)
      ],
    ),
  ),
      ],
    ),
    if (_securities.isNotEmpty)
      Positioned(
        top: 20,
        left: 0,
        right: 0,
        bottom: 0,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedSecurity = _securities[0];
            });
          },
          child: Container(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 3 / 4,
                  child: Container(
                    decoration: BoxDecoration(
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
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
  ],
),);
  }
}