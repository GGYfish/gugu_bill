import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'database/database.dart';
import 'services/network_service.dart';
import 'providers/app_provider.dart';
import 'providers/bill_provider.dart';
import 'providers/category_provider.dart';
import 'providers/account_provider.dart';
import 'providers/liability_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/resource_provider.dart';
import 'providers/record_category_provider.dart';

import 'theme/theme_manager.dart';
import 'theme/app_colors_data.dart';

import 'pages/home_page.dart';
import 'pages/record_page.dart';
import 'pages/gugu_ai_page.dart';
import 'pages/debt_page.dart';
import 'pages/statistics_page.dart';

import 'android_channel/auto_record_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeManager.instance.init();

  final db = AppDatabase();
  final network = NetworkService();
  network.init();

  runApp(MyApp(db: db, network: network));
}

class MyApp extends StatelessWidget {
  final AppDatabase db;
  final NetworkService network;

  const MyApp({super.key, required this.db, required this.network});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: db),
        ChangeNotifierProvider(create: (_) => AppProvider(db, network)),
        ChangeNotifierProvider(create: (_) {
          final cp = CategoryProvider();
          cp.bind(db);
          return cp;
        }),
        ChangeNotifierProvider(create: (_) => AccountProvider(db)),
        ChangeNotifierProvider(create: (_) => BillProvider(db, network)),
        ChangeNotifierProvider(create: (_) => LiabilityProvider(db, network)),
        ChangeNotifierProvider(create: (_) => StatisticsProvider(db)),
        ChangeNotifierProvider(create: (_) => CategoryManagementProvider(db)),
        ChangeNotifierProvider(create: (_) => BankManagementProvider(db)),
        ChangeNotifierProvider(create: (_) => CreditInstitutionManagementProvider(db)),
        ChangeNotifierProvider(create: (_) => RecordCategoryProvider(db)),
        ChangeNotifierProvider<ThemeManager>.value(value: ThemeManager.instance),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, _) {
          return MaterialApp(
            title: '咕咕鱼记账',
            navigatorKey: autoRecordNavigatorKey,
            theme: themeManager.buildThemeData(),
            home: const MainNavigation(),
          );
        },
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  /// 顺序固定：首页、记一笔、咕咕鱼、负债、统计（始终展示，不随 AI 开关隐藏）
  static const int _recordTabIndex = 1;

  final List<Widget> _pages = const [
    HomePage(),
    SizedBox.shrink(), // 记一笔走独立页面，不占栈内页
    GuguAiPage(),
    DebtPage(),
    StatisticsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: ext.surface,
        indicatorColor: ext.primary.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: _onTabTapped,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: ext.textSecondary),
            selectedIcon: Icon(Icons.home, color: ext.primary),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined, color: ext.textSecondary),
            selectedIcon: Icon(Icons.edit_note, color: ext.primary),
            label: '记一笔',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined, color: ext.textSecondary),
            selectedIcon: Icon(Icons.auto_awesome, color: ext.primary),
            label: '咕咕鱼',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.account_balance_wallet_outlined,
              color: ext.textSecondary,
            ),
            selectedIcon: Icon(
              Icons.account_balance_wallet,
              color: ext.primary,
            ),
            label: '负债',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined, color: ext.textSecondary),
            selectedIcon: Icon(Icons.bar_chart, color: ext.primary),
            label: '统计',
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    if (index == _recordTabIndex) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const RecordPage()),
      );
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }
}
