import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiatia/pages/Home.dart';
import 'package:tiatia/pages/Strategy.dart';
import 'package:tiatia/pages/Analytics.dart';
import 'package:tiatia/pages/Account.dart';
import 'package:tiatia/pages/Securities.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Portfolio extends StatefulWidget {
  const Portfolio({super.key});

  @override
  State<Portfolio> createState() => _PortfolioState();
}

class NotificationsProvider extends ChangeNotifier {
  bool _notificationsRead = false;

  bool get notificationsRead => _notificationsRead;

  void markNotificationsAsRead() {
    _notificationsRead = true;
    notifyListeners();
  }
}

class _PortfolioState extends State<Portfolio> {
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
  List<DocumentSnapshot> _securities2 = [];
  DocumentSnapshot? _selectedSecurity2;
  FocusNode _searchFocusNode = FocusNode();
  bool _isListVisible = false;
  String _selectedSecurity = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
    color: notificationsRead ? null : Colors.red, // Изменение цвета иконки, если уведомления не прочитаны
  ),
  itemBuilder: (context) => [
    PopupMenuItem(
      child: Text('Уведомление 1'),
      value: 1,
    ),
    PopupMenuItem(
      child: Text('Уведомление 2'),
      value: 2,
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
        title: Text('Portfolio'),
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
            // Обработка нажатия на пункт меню
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
      for (var tickerDoc in tickerDocs) {
        tickers.add(tickerDoc['ticker']);
        amounts.add(tickerDoc['amount']);
        boughtPrices.add(tickerDoc['bought']);
        terms.add(tickerDoc['term']);
      }
      return Column(
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
                    'Portfolio',
                    style: TextStyle(fontSize: 24),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Ticker',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Amount',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Bought',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Term',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '                                            ',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  for (int i = 0; i < tickers.length; i++)
  Dismissible(
    key: Key(tickers[i]), // уникальный ключ для каждого Dismissible
    onDismissed: (direction) async {
      // Логика удаления ценной бумаги
await FirebaseFirestore.instance
    .collection('users')
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .collection('securities')
    .doc(tickerDocs[i].id) // получаем DocumentReference по индексу i
    .delete(); // удаляем документ

// Обновляем названия и ID всех документов
final securities = await FirebaseFirestore.instance
    .collection('users')
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .collection('securities')
    .get();

int id = 1; // Новое значение ID для первого документа
for (final security in securities.docs) {
  // Получаем данные документа
  final data = security.data();
  // Удаляем старый документ
  await security.reference.delete();
  
  // Создаем новый документ с нужным названием и обновленным полем securities_id
  final newDocName = '$id';
  final newDocRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('securities')
      .doc(newDocName);
  await newDocRef.set({...data, 'securities_id': id});

  id++;
}
setState(() {
      // перезагружаем данные, чтобы обновить отображение
      tickers.removeAt(i);
      amounts.removeAt(i);
      boughtPrices.removeAt(i);
      terms.removeAt(i);
    });
    },
    background: Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20.0),
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    ),
    secondaryBackground: Container(
      color: Colors.red,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20.0),
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    ),
    child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    InkWell(
      onTap: () async {
        String ticker = tickers[i];
        String url = 'https://www.tinkoff.ru/invest/stocks/$ticker/';
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          // Обработка случая, когда не удалось открыть URL-адрес
        }
      },
      child: Text(
        tickers[i],
        style: TextStyle(fontSize: 24, color: Colors.blue),
      ),
    ),
        Text(
  amounts[i].toString(),
  style: TextStyle(fontSize: 24),
),
IconButton(
  onPressed: () async {
    final TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Изменить количество'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Введите новое количество',
            ),
            // Валидация для ввода только чисел
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Изменить'),
              onPressed: () async {
                // Получаем новое значение количества
                final newAmount = int.tryParse(controller.text);
                if (newAmount != null) {
                  // Обновляем значение количества в базе данных
                  await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('securities')
                    .doc(tickerDocs[i].id)
                    .update({'amount': newAmount});
                  // Обновляем отображение
                  setState(() {
                    amounts[i] = newAmount;
                  });
                } else {
                  // Выводим сообщение об ошибке в случае некорректного ввода
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Ошибка'),
                        content: Text('Введите число'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Ок'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  },
  icon: Icon(Icons.edit),
),
        Text(
  boughtPrices[i].toString(),
  style: TextStyle(fontSize: 24),
),
IconButton(
  onPressed: () async {
    final TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Изменить количество'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              hintText: 'Введите новое количество',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Изменить'),
              onPressed: () async {
                final newBoughtPrices = double.tryParse(controller.text);
                if (newBoughtPrices != null) {
                  if (newBoughtPrices <= amounts[i]) {
                    await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('securities')
                      .doc(tickerDocs[i].id)
                      .update({'bought': newBoughtPrices});
                    setState(() {
                      boughtPrices[i] = newBoughtPrices;
                    });
                    Navigator.of(context).pop();
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Ошибка'),
                        content: Text('Введенное число больше amount'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Ок'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  }
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Ошибка'),
                      content: Text('Введите число.'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Ок'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
    if (boughtPrices[i] == amounts[i]) {
      bool delete = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Вы уверены?'),
            actions: <Widget>[
              TextButton(
                child: Text('Нет'),
                onPressed: () async {
                  Navigator.of(context).pop(false);
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('securities')
                      .doc(tickerDocs[i].id)
                      .update({'bought': 0});
                    setState(() {
                      boughtPrices[i] = 0;
                    });
                },
              ),
              TextButton(
                child: Text('Да'),
                onPressed: () async {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );
      if (delete) {
        final security = tickerDocs[i];
    // Получаем данные документа
    final data = security.data();
    // Удаляем старый документ
    await security.reference.delete();
  
    // Перебираем все документы и перенастраиваем их id и название документа
    int id = 1;
    final securities = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('securities')
        .get();
    for (final security in securities.docs) {
      // Получаем данные документа
      final data = security.data();
      // Удаляем старый документ
      await security.reference.delete();
  
      // Создаем новый документ с нужным названием и обновленным полем securities_id
      final newDocName = '$id';
      final newDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('securities')
          .doc(newDocName);
      await newDocRef.set({...data, 'securities_id': id});

      id++;
    }

    setState(() {
      // перезагружаем данные, чтобы обновить отображение
      tickers.removeAt(i);
      amounts.removeAt(i);
      boughtPrices.removeAt(i);
      terms.removeAt(i);
    });
}}
},
icon: Icon(Icons.edit),
),
        Text(
  terms[i],
  style: TextStyle(fontSize: 24),
),
IconButton(
  onPressed: () async {
    final TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Изменить дату'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Введите новую дату (dd.MM.yyyy)',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Изменить'),
              onPressed: () async {
                final newTerm = controller.text;
                final dateFormat = DateFormat('dd.MM.yyyy');
                final currentDate = DateTime.now();

                try {
                  final enteredDate = dateFormat.parseStrict(newTerm);
                  if (enteredDate.isAfter(currentDate)) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('securities')
                        .doc(tickerDocs[i].id)
                        .update({'term': newTerm});
                    setState(() {
                      terms[i] = newTerm;
                    });
                    Navigator.of(context).pop();
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Ошибка'),
                          content: Text('Дата должна быть больше сегодняшней'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('ОК'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                } on FormatException {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Ошибка'),
                        content: Text('Неправильный формат даты'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('ОК'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  },
  icon: Icon(Icons.edit),
),
        ElevatedButton(
  onPressed: () async {
    final security = tickerDocs[i];
    // Получаем данные документа
    final data = security.data();
    // Удаляем старый документ
    await security.reference.delete();
  
    // Перебираем все документы и перенастраиваем их id и название документа
    int id = 1;
    final securities = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('securities')
        .get();
    for (final security in securities.docs) {
      // Получаем данные документа
      final data = security.data();
      // Удаляем старый документ
      await security.reference.delete();
  
      // Создаем новый документ с нужным названием и обновленным полем securities_id
      final newDocName = '$id';
      final newDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('securities')
          .doc(newDocName);
      await newDocRef.set({...data, 'securities_id': id});

      id++;
    }

    setState(() {
      // перезагружаем данные, чтобы обновить отображение
      tickers.removeAt(i);
      amounts.removeAt(i);
      boughtPrices.removeAt(i);
      terms.removeAt(i);
    });
  },
  child: Text('Удалить'),
),
      ],
    ),
  ),
  
                ],
              ),
            ),
          ),
        ],
      );
    },
  ),
)
      ],
    ),
    if (_securities.isNotEmpty)
      Positioned(
              top: 70,
              left: 250,
              right: 250,
              bottom: 650,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedSecurity = _securities[0];
            });
          },
          child: Container(
            color: Colors.white,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 0.0),
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