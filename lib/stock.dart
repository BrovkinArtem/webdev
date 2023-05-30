import 'dart:convert';
//import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Stock {
  String ticker = 'AAPL';
  int amount = 100;
  int bought = 10;
  String term = '2022-12-30';
  String lastInvestDay = '2022-11-21';
  num price = 100 as num;

  Future<void> getPrice(String ticker) async {
    final response = await http.get(Uri.parse(
        'https://api.twelvedata.com/price?symbol=$ticker&apikey=eccd7ef0256643e8a8407a19bdeca078'));
    final data = json.decode(response.body);
    final price = num.parse(data['price']);
    this.price = price;
  }

  Stock(String ticker, int amount, int bought, String term,
      String lastInvestDay) {
    this.ticker = ticker;
    this.amount = amount;
    this.bought = bought;
    this.term = term;
    this.lastInvestDay = lastInvestDay;
    getPrice(ticker);
  }
}
