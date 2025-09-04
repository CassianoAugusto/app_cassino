import 'package:app_cassino/jogos/black_jack_page.dart';
import 'package:app_cassino/jogos/roulette_page.dart';
import 'package:app_cassino/jogos/slots_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CasinoDemoApp());
}

class CasinoDemoApp extends StatelessWidget {
  const CasinoDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cassino',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: const CasinoHome(),
    );
  }
}

class CasinoHome extends StatefulWidget {
  const CasinoHome({super.key});

  @override
  State<CasinoHome> createState() => _CasinoHomeState();
}

class _CasinoHomeState extends State<CasinoHome> {
  int _index = 0;
  final ValueNotifier<int> balance = ValueNotifier<int>(1000);

  @override
  Widget build(BuildContext context) {
    final pages = [
      SlotsPage(balance: balance),
      BlackjackPage(balance: balance),
      RoulettePage(balance: balance),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cassino'),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: balance,
            builder: (_, coins, __) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(label: Text('Fichas: $coins')),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: pages[_index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.casino_outlined),
            label: 'Slots',
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            label: 'Blackjack',
          ),
          NavigationDestination(
            icon: Icon(Icons.circle_outlined),
            label: 'Roleta',
          ),
        ],
      ),
    );
  }
}
