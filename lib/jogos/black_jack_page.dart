import 'package:flutter/material.dart';

class BlackjackPage extends StatefulWidget {
  const BlackjackPage({super.key, required this.balance});

  final ValueNotifier<int> balance;

  @override
  State<BlackjackPage> createState() => _BlackjackPageState();
}

class _BlackjackPageState extends State<BlackjackPage> {
  final List<String> player = [];
  final List<String> dealer = [];
  bool roundActive = false;
  int bet = 20;
  String result = '';

  final List<String> _deck = [];

  @override
  void initState() {
    super.initState();
    _newDeck();
  }

  void _newDeck() {
    const ranks = [
      'A',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'J',
      'Q',
      'K',
    ];
    const suits = ['♠', '♥', '♦', '♣'];
    _deck.clear();
    for (final r in ranks) {
      for (final s in suits) {
        _deck.add('$r$s');
      }
    }
    _deck.shuffle();
  }

  int _cardValue(String c) {
    final r = c.replaceAll(RegExp('[^A0-9JQK]'), '');
    if (r == 'A') return 11;
    if (['J', 'Q', 'K'].contains(r)) return 10;
    return int.parse(r);
  }

  int _handValue(List<String> hand) {
    int total = hand.fold(0, (sum, c) => sum + _cardValue(c));
    int aces = hand.where((c) => c.startsWith('A')).length;
    while (total > 21 && aces > 0) {
      total -= 10; // A como 1
      aces--;
    }
    return total;
  }

  String _draw() {
    if (_deck.isEmpty) _newDeck();
    return _deck.removeLast();
  }

  void _startRound() {
    if (roundActive) return;
    if (widget.balance.value < bet) {
      setState(() => result = 'Fichas insuficientes.');
      return;
    }
    widget.balance.value -= bet;
    player.clear();
    dealer.clear();
    player.addAll([_draw(), _draw()]);
    dealer.addAll([_draw(), _draw()]);
    result = '';
    roundActive = true;
    setState(() {});

    final p = _handValue(player);
    final d = _handValue(dealer);
    if (p == 21 || d == 21) _endRound(auto: true);
  }

  void _hit() {
    if (!roundActive) return;
    player.add(_draw());
    if (_handValue(player) > 21) {
      _endRound();
    } else {
      setState(() {});
    }
  }

  void _stand() {
    if (!roundActive) return;

    while (_handValue(dealer) < 17) {
      dealer.add(_draw());
    }
    _endRound();
  }

  void _endRound({bool auto = false}) {
    final pv = _handValue(player);
    final dv = _handValue(dealer);

    if (pv > 21) {
      result = 'Você estourou ($pv). Perdeu.';
    } else if (dv > 21) {
      result = 'Dealer estourou ($dv). Você ganhou!';
      widget.balance.value += bet * 2;
    } else if (pv > dv) {
      result = 'Você: $pv x Dealer: $dv — Você ganhou!';
      widget.balance.value += bet * 2;
    } else if (pv < dv) {
      result = 'Você: $pv x Dealer: $dv — Você perdeu.';
    } else {
      result = 'Empate ($pv). Aposta devolvida.';
      widget.balance.value += bet;
    }

    roundActive = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pv = _handValue(player);
    final dv = _handValue(dealer);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Blackjack',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _HandView(
                    title: 'Dealer',
                    cards: dealer,
                    total: roundActive ? null : dv,
                  ),
                  const SizedBox(height: 12),
                  _HandView(title: 'Você', cards: player, total: pv),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Aposta:'),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: bet,
                        items: const [10, 20, 50, 100]
                            .map(
                              (v) =>
                                  DropdownMenuItem(value: v, child: Text('$v')),
                            )
                            .toList(),
                        onChanged: roundActive
                            ? null
                            : (v) => setState(() => bet = v ?? 20),
                      ),
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: roundActive ? null : _startRound,
                        child: const Text('Novo Jogo'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: roundActive ? _hit : null,
                        child: const Text('Pedir carta'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: roundActive ? _stand : null,
                        child: const Text('Parar'),
                      ),
                    ],
                  ),
                  if (result.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      result,
                      style: TextStyle(
                        color: result.contains('ganhou')
                            ? Colors.green
                            : Colors.black87,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HandView extends StatelessWidget {
  const _HandView({required this.title, required this.cards, this.total});
  final String title;
  final List<String> cards;
  final int? total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: cards
              .asMap()
              .entries
              .map(
                (e) => _CardChip(
                  label: e.value,
                  hidden: title == 'Dealer' && total == null && e.key == 0,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 6),
        if (total != null) Text('Total: $total'),
      ],
    );
  }
}

class _CardChip extends StatelessWidget {
  const _CardChip({required this.label, this.hidden = false});
  final String label;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: hidden ? Colors.black12 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(blurRadius: 6, color: Colors.black12, offset: Offset(0, 2)),
        ],
      ),
      child: Text(hidden ? '🂠' : label, style: const TextStyle(fontSize: 16)),
    );
  }
}
