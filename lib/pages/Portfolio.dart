import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiatia/pages/Home.dart';
import 'package:tiatia/pages/Strategy.dart';
import 'package:tiatia/pages/Analytics.dart';
import 'package:tiatia/pages/Account.dart';
import 'package:tiatia/pages/Securities.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Portfolio extends StatefulWidget {
  const Portfolio({super.key});

  @override
  State<Portfolio> createState() => _PortfolioState();
}


class _PortfolioState extends State<Portfolio> {
bool isBedtimeOutlined = true;

  void _toggleBedtimeIcon() {
    setState(() {
      isBedtimeOutlined = !isBedtimeOutlined;
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
                  'Portfolio',
                  style: TextStyle(fontSize: 24),
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