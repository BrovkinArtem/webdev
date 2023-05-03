import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiatia/pages/Portfolio.dart';
import 'package:tiatia/pages/Strategy.dart';
import 'package:tiatia/pages/Home.dart';
import 'package:tiatia/pages/Analytics.dart';
import 'package:tiatia/pages/Account.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Securities extends StatefulWidget {
  const Securities({super.key});
  final String selectedSecurity = "";


  @override
  State<Securities> createState() => _SecuritiesState();
}


class _SecuritiesState extends State<Securities> {
bool isBedtimeOutlined = true;

  void _toggleBedtimeIcon() {
    setState(() {
      isBedtimeOutlined = !isBedtimeOutlined;
    });
  }

String _selectedSecurity = 'Securities';
final TextEditingController _searchController = TextEditingController();
TextEditingController _quantityController = TextEditingController();
List<String> _securities = [];
FocusNode _searchFocusNode = FocusNode();
bool _isListVisible = false;
final String security = "";
String _selectedPrice = '';

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

Future<void> fetchSecurityPrice(String symbol) async {
  final response = await http.get(Uri.parse(
      'https://api.twelvedata.com/price?symbol=$symbol&apikey=eccd7ef0256643e8a8407a19bdeca078'));
  final data = json.decode(response.body);
  final price = data['price'].toString();
  if (price.isNotEmpty) {
    setState(() {
      _selectedPrice = price;
    });
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

void _showAddSecurityDialog(BuildContext context) async{
  final _dateController = TextEditingController();
  final _quantityController = TextEditingController();

  // Получаем текущего пользователя
  final User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    // Пользователь не зарегистрирован, выводим сообщение об ошибке
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ошибка'),
          content: Text('Пользователь не зарегистрирован.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  } else {
    // Получаем ссылку на коллекцию securities для текущего пользователя
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final securitiesCollectionRef = userDocRef.collection('securities');


  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(_selectedSecurity),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Цена: $_selectedPrice'),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Количество',
              ),
            ),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Срок закупки (DD.MM.YYYY)',
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Назад'),
          ),
          ElevatedButton(
            onPressed: () async {
    final enteredDate = _dateController.text;
    final dateFormat = DateFormat('dd.MM.yyyy');
    final now = DateTime.now();
    try {
        final enteredDateTime = dateFormat.parseStrict(enteredDate);
        if (enteredDateTime.isBefore(now)) {
            showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      title: Text('Ошибка'),
      content: Text('Дата должна быть не меньше сегодняшней.'),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('OK'),
        ),
      ],
    );
  },
);
        } else {
        final enteredQuantity = int.tryParse(_quantityController.text);
        if (enteredQuantity == null || enteredQuantity == 0) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text('Ошибка'),
                        content: Text('Количество должно быть больше нуля.'),
                        actions: [
                            ElevatedButton(
                                onPressed: () {
                                    Navigator.pop(context);
                                },
                                child: Text('OK'),
                            ),
                        ],
                    );
                },
            );
        } else {
                    // Получаем ссылку на коллекцию securities для текущего пользователя
                    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
final securitiesCollectionRef = userDocRef.collection('securities');

final securitiesSnapshot = await securitiesCollectionRef.get();

if (securitiesSnapshot.docs.isEmpty) {
  // Коллекция securities для текущего пользователя пустая,
  // создаем новый документ с securities_id: 1
  final newSecurityDocRef = securitiesCollectionRef.doc('1');
  await newSecurityDocRef.set({
    'securities_id': '1',
    'ticker': _selectedSecurity,
    'amount': enteredQuantity,
    'term': enteredDate,
    'bought': 0,
    'portfolio_id': user.uid,
  });
} else {
  // Коллекция securities для текущего пользователя не пустая,
  // получаем количество документов в коллекции и создаем новый документ
  final securitiesCount = securitiesSnapshot.size;
  final newSecurityDocRef = securitiesCollectionRef.doc('${securitiesCount + 1}');
  await newSecurityDocRef.set({
    'securities_id': '${securitiesCount + 1}',
    'ticker': _selectedSecurity,
    'amount': enteredQuantity,
    'term': enteredDate,
    'bought': 0,
    'portfolio_id': user.uid,
  });
}
            Navigator.pop(context);
            _quantityController.clear();
            _dateController.clear();
        }
    }
} on FormatException {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Ошибка'),
                    content: Text('Неверный формат даты.'),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          },
          child: Text('Добавить'),
        ),
      ],
    );
  },
);}}

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
              onPressed: () {
                Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Account())
    );
              },
            ),
        ],
        title: Text('Securities'),
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
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 250.0, vertical: 50.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(45),
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
          _selectedSecurity != null ? '$_selectedSecurity' : '',
          style: TextStyle(fontSize: 24),
        ),
          if (_selectedPrice != null && _selectedPrice.isNotEmpty)
  Text(
    '${double.tryParse(_selectedPrice) ?? 0.0}',
    style: TextStyle(fontSize: 24),
  ),
  FlatButton(
  onPressed: _selectedSecurity == 'Securities' ? null : () {
    _showAddSecurityDialog(context);
  },
  child: Text(
    'Добавить',
    style: TextStyle(fontSize: 18),
  ),
  color: Colors.blue,
  textColor: Colors.white,
  disabledColor: Colors.grey,
),
              ],
            ),
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
              fetchSecurityPrice(_selectedSecurity);
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
                itemBuilder: (context, index) {
                final security = _securities[index];
                return GestureDetector(
  onTap: () async {
    setState(() {
      _selectedSecurity = security;
      _isListVisible = false;
    });
    await fetchSecurityPrice(security);
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
  ),),
  ],
),);
  }
}