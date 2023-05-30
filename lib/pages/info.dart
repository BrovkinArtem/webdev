import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiatia/pages/Portfolio.dart';
import 'package:tiatia/pages/Home.dart';
import 'package:tiatia/pages/Home2.dart';
import 'package:tiatia/pages/Strategy.dart';
import 'package:tiatia/pages/Archive.dart';
import 'package:tiatia/pages/Analytics.dart';
import 'package:tiatia/pages/Account.dart';
import 'package:tiatia/pages/Securities.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Info extends StatefulWidget {
  const Info({Key? key}) : super(key: key);

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
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

  Widget buildScenario(String scenario) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        scenario,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
      ),
    );
  }

  Widget buildText(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
    );
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
          title: Text('Информация'),
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
        body: Center(
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              buildScenario(
                  'Сценарий 1: Начало работы на сайте с ПК(П.[1] ФТ)'),
              buildText('Пользователь открывает сайт на ПК.'),
              buildText('Пользователь просматривает сайт с ПК.'),
              Text(""),
              buildScenario(
                  'Сценарий 2: Начало работы на сайте с мобильного устройства'),
              buildText('Пользователь открывает сайт на мобильном устройстве.'),
              buildText(
                  'Пользователь просматривает сайт с мобильного устройства.'),
              Text(""),
              buildScenario('Сценарий 3: Регистрация на сайте(П.[2] ФТ)'),
              buildText(
                  'Пользователь переходит на сайт и видит страницу регистрации.'),
              buildText(
                  'Пользователь вводит необходимые для регистрации данные.'),
              buildText(
                  'После успешного прохождения этапа регистрации пользователь видит сообщение об успешном создании аккаунта.'),
              Text(""),
              buildScenario(
                  'Сценарий 4: Создание портфеля пользователя(П.[3] ФТ)'),
              buildText(
                  'В случае успешной регистрации и создания аккаунта пользователь переходит во вкладку "Портфель" в стартовом меню'),
              buildText(
                  'На экране появляется информация о портфеле на данный момент'),
              Text(""),
              buildScenario(
                  'Сценарий 4.1: Поиск ценной бумаги по тикеру(П.[3.1] ФТ)'),
              buildText('Пользователь нажимает кнопку "Поиск ценной бумаги"'),
              buildText(
                  'Пользователь вводит существующие название тикера ценной бумаги и получает текущую информацию о ней'),
              Text(""),
              buildScenario(
                  'Сценарий 4.2: Добавление ценной бумаги(П.[3.2] ФТ)'),
              buildText(
                  'Пользователь нажимает кнопку "Добавить ценную бумагу"'),
              buildText('Пользователь вводит название тикера ценной бумаги'),
              buildText('Пользователь указывает количество и срок покупки'),
              Text(""),
              buildScenario('Сценарий 4.3: Удаление ценной бумаги(П.[3.3] ФТ)'),
              buildText('Пользователь нажимает кнопку "Удалить ценную бумагу"'),
              buildText('Пользователь вводит название тикера ценной бумаги'),
              buildText('Пользователь указывает срок покупки'),
              Text(""),
              buildScenario(
                  'Сценарий 4.4: Изменение количества покупаемых ценных бумаг(П.[3.4] ФТ)'),
              buildText(
                  'Пользователь нажимает кнопку "Изменить количество покупок"'),
              buildText('Пользователь вводит название тикера ценной бумаги'),
              buildText(
                  'После ввода пользователем тикера существующей в списке ценной бумаги и обновлённого количества ее покупки, бот изменяет информацию в списке'),
              Text(""),
              buildScenario(
                  'Сценарий 4.5: Изменение количества купленных ценных бумаг(П.[3.5] ФТ)'),
              buildText(
                  'Пользователь нажимает кнопку "Изменить количество купленных бумаг"'),
              buildText('Пользователь вводит название тикера ценной бумаги'),
              buildText(
                  'После ввода пользователем тикера существующей в списке ценной бумаги и обновленного количества ее покупки, бот изменяет информацию в списке'),
              Text(""),
              buildScenario(
                  'Сценарий 5: Получение данных со сторонних сервисов(П.[4] ФТ)'),
              buildText('Пользователь создает портфель ценных бумаг'),
              buildText(
                  'Сервис получает данные об изменении стоимости на ценные бумаги со стороннего API, затем обрабатывает их и отправляет пользователю в сообщении'),
              Text(""),
              buildScenario(
                  'Сценарий 6: Использование стратегии усреднения(П.[5] ФТ)'),
              buildText('Пользователь нажимает на кнопку "Стратегия"'),
              buildText(
                  'На экране появляется список ценных бумаг в порядке уменьшения приоритетности, также для каждой ценной бумаги указано предлагаемое количество к покупке'),
              Text(""),
              buildScenario(
                  'Сценарий 7: Редактирование данных для формирования портфеля(П.[6] ФТ)'),
              buildText('Пользователь переходит на вкладку "Портфель"'),
              buildText('Пользователь нажимает кнопку "Настройки портфеля"'),
              Text(""),
              buildScenario(
                  'Сценарий 7.1: Редактирование бюджета инвестирования(П.[6.1] ФТ)'),
              buildText('Пользователь нажимает кнопку "Сумма инвестирования"'),
              buildText('Пользователь вводит новое значение'),
              buildText(
                  'Пользователю приходит сообщение об успешном установлении нового значения'),
              Text(""),
              buildScenario(
                  'Сценарий 7.2: Редактирование периодичности инвестирования(П.[6.2] ФТ)'),
              buildText(
                  'Пользователь нажимает кнопку "Периодичность инвестирования"'),
              buildText('Пользователь вводит новое значение'),
              buildText(
                  'Пользователю приходит сообщение об успешном установлении нового значения'),
              Text(""),
              buildScenario(
                  'Сценарий 7.3: Редактирование срока инвестирования(П.[6.3] ФТ)'),
              buildText('Пользователь нажимает кнопку "Срок инвестирования"'),
              buildText('Пользователь вводит новое значение'),
              buildText(
                  'Пользователю приходит сообщение об успешном установлении нового значения'),
              Text(""),
              buildScenario(
                  'Сценарий 8: Получение доходности портфеля(П.[7.1] ФТ)'),
              buildText('Пользователь нажимает кнопку "Получить аналитику"'),
              buildText(
                  'Пользователь выбирает "Аналитика доходности портфеля"'),
              buildText(
                  'Пользователь получает сообщение о доходности всего портфеля'),
              Text(""),
              buildScenario(
                  'Сценарий 9: Получение доходности указанной ценной бумаги(П.[7.2] ФТ)'),
              buildText('Пользователь нажимает кнопку "Получить аналитику"'),
              buildText('Пользователь выбирает "Аналитика ценной бумаги"'),
              buildText(
                  'Пользователь указывает ценную бумагу, которая находится в портфеле'),
              buildText(
                  'Пользователь получает сообщение о доходности ценной бумаги'),
              Text(""),
              buildScenario('Сценарий 10: Просмотр уведомлений(П.[8] ФТ)'),
              buildText(
                  'Пользователь будет просматривать уведомления каждого типа во вкладке "Уведомления"'),
              Text(""),
              buildScenario(
                  'Сценарий 11: Покупка ценных бумаг через сторонний сервис с помощью API (П.[9] ФТ)'),
              buildText('Пользователь нажимает на кнопку "Стратегия"'),
              buildText(
                  'На экране появляется список ценных бумаг в порядке уменьшения приоритетности, также для каждой ценной бумаги указано предлагаемое количество к покупке'),
              buildText(
                  'Пользователь нажимает на одну из ценных бумаг в списке'),
              buildText(
                  'Пользователь попадает на страницу "Тинькофф" с сформированным предложением о покупке ценных бумаг в соответствии со стратегией'),
              Text(""),
              buildScenario(
                  'Сценарий 12: Отключение и включение возможности покупки ценных бумаг через сторонний сервис с помощью API(П.[10] ФТ)'),
              buildText('Пользователь переходит на вкладку "Портфель"'),
              buildText('Пользователь нажимает кнопку "Настройки портфеля"'),
              buildText(
                  'Пользователь нажимает на кнопку "Настройка покупки ценных бумаг"'),
              buildText(
                  'Пользователь нажимает кнопку "включить" / "выключить"'),
            ],
          ),
        ));
  }
}
