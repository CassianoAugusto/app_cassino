import 'dart:math';

import 'package:flutter/material.dart';

class SlotsPage extends StatefulWidget {
  const SlotsPage({super.key, required this.balance});
  final ValueNotifier<int> balance;

  @override
  State<SlotsPage> createState() => _SlotsPageState();
}

class _SlotsPageState extends State<SlotsPage> {
  final _rng = Random();
  final _symbols = ['🍒', '🍋', '🔔', '⭐', '7️⃣'];
  List<int> _reels = [0, 0, 0];
  bool _spinning = false;
  int _bet = 10;
  String? _message;

  Map<String, int> get _payouts => {
    '🍒': 5,
    '🍋': 7,
    '🔔': 10,
    '⭐': 15,
    '7️⃣': 30,
  };

  void _spin() async {
    if (_spinning) return;
    if (widget.balance.value < _bet) {
      setState(() => _message = 'Fichas insuficientes.');
      return;
    }

    widget.balance.value -= _bet;
    setState(() {
      _spinning = true;
      _message = null;
    });

    for (int t = 0; t < 12; t++) {
      await Future.delayed(const Duration(milliseconds: 90));
      setState(() {
        _reels = List.generate(3, (_) => _rng.nextInt(_symbols.length));
      });
    }

    final s0 = _symbols[_reels[0]];
    final s1 = _symbols[_reels[1]];
    final s2 = _symbols[_reels[2]];

    int won = 0;
    if (s0 == s1 && s1 == s2) {
      won = _bet * _payouts[s0]!;
      widget.balance.value += won;
    }

    setState(() {
      _spinning = false;
      _message = won > 0 ? 'Você ganhou $won!' : 'Tente novamente!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    offset: Offset(0, 2),
                    color: Colors.black12,
                  ),
                ],
              ),
              child: Text(
                _symbols[_reels[i]],
                style: const TextStyle(fontSize: 36),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Aposta:'),
            const SizedBox(width: 10),
            DropdownButton<int>(
              value: _bet,
              items: const [10, 20, 50, 100]
                  .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                  .toList(),
              onChanged: _spinning
                  ? null
                  : (v) => setState(() => _bet = v ?? 10),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: _spinning ? null : _spin,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Girar'),
            ),
          ],
        ),
        if (_message != null) ...[
          const SizedBox(height: 8),
          Text(
            _message!,
            style: TextStyle(
              color: _message!.contains('ganhou')
                  ? Colors.green
                  : Colors.black54,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          children: _payouts.entries
              .map((e) => Chip(label: Text('${e.key} paga x${e.value}')))
              .toList(),
        ),
      ],
    );
  }
}
