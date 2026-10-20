import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';

class AccountProvider extends ChangeNotifier {
  final AppDatabase _db;

  List<LocalAccountsData> _accounts = [];
  bool _isLoading = false;

  List<LocalAccountsData> get accounts => _accounts;
  bool get isLoading => _isLoading;

  AccountProvider(this._db) {
    _init();
  }

  void _init() {
    _db.watchAllAccounts().listen((accounts) {
      _accounts = accounts;
      notifyListeners();
    });
  }

  Future<void> addAccount({
    required String name,
    required String type,
    double balance = 0.0,
    String color = '#7C4DFF',
    String icon = 'wallet',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final uuid = const Uuid();
      await _db.insertAccount(LocalAccountsCompanion(
        accountId: Value(uuid.v4()),
        name: Value(name),
        type: Value(type),
        balance: Value(balance),
        color: Value(color),
        icon: Value(icon),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  LocalAccountsData? getAccountById(String accountId) {
    try {
      return _accounts.firstWhere((a) => a.accountId == accountId);
    } catch (_) {
      return null;
    }
  }
}
