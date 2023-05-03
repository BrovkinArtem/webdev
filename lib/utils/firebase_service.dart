import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final _database = FirebaseDatabase.instance.reference();

  void createSecuritiesTable() {
    _database.child('Securities').set({
      'securities_id': '',
      'ticker': '',
      'amount': '',
      'term': '',
      'bought': '',
      'portfolio_id': ''
    });
  }

  // Другие методы для работы с базой данных Firebase
}