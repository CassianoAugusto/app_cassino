import 'dart:math';

import 'package:flutter/material.dart';

class RoulettePage extends StatefulWidget {
  const RoulettePage({super.key, required this.balance});
  final ValueNotifier<int> balance;

  @override
  State<RoulettePage> createState() => _RoulettePageState();
}

class _RoulettePageState extends State<RoulettePage>
    with SingleTickerProviderStateMixin {
  final _rng = Random();
  String? selected; // 'red' ou 'black'
  int bet = 20;
  bool spinning = false;
  int? resultNumber;
  String? resultColor; // 'red' | 'black' | 'green'
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  final Set<int> redNumbers = {
    1,
    3,
    5,
    7,
    9,
    12,
    14,
    16,
    18,
    19,
    21,
    23,
    25,
    27,
    30,
    32,
    34,
    36,
  };

  void _spin() async {
    if (spinning) return;
    if (selected == null) return;
    if (widget.balance.value < bet) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Fichas insuficientes.')));
      return;
    }

    widget.balance.value -= bet;
    setState(() {
      spinning = true;
      resultNumber = null;
      resultColor = null;
    });

    _ctrl.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 1400));

    final n = _rng.nextInt(37); // 0–36
    final c = n == 0 ? 'green' : (redNumbers.contains(n) ? 'red' : 'black');

    if (n != 0 && c == selected) {
      widget.balance.value += bet * 2;
    }

    setState(() {
      spinning = false;
      resultNumber = n;
      resultColor = c;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    'Roleta',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        selected: selected == 'red',
                        onSelected: (v) =>
                            setState(() => selected = v ? 'red' : null),
                        label: const Text('Vermelho'),
                        avatar: const CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 6,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        selected: selected == 'black',
                        onSelected: (v) =>
                            setState(() => selected = v ? 'black' : null),
                        label: const Text('Preto'),
                        avatar: const CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
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
                        onChanged: spinning
                            ? null
                            : (v) => setState(() => bet = v ?? 20),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: (selected != null && !spinning)
                            ? _spin
                            : null,
                        icon: const Icon(Icons.casino),
                        label: const Text('Girar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: AnimatedBuilder(
                      animation: _ctrl,
                      builder: (context, _) {
                        final angle =
                            Curves.easeOut.transform(_ctrl.value) * 6 * pi;
                        return Transform.rotate(
                          angle: angle,
                          child: CustomPaint(
                            painter: _RoulettePainter(),
                            child: Center(
                              child: Text(
                                resultNumber?.toString() ?? ' ',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (resultNumber != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Resultado: $resultNumber (${resultColor == 'green' ? 'verde' : resultColor})',
                      textAlign: TextAlign.center,
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

class _RoulettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;
    final paint = Paint()..style = PaintingStyle.fill;

    const sectors = 37; // 0–36
    final sweep = 2 * pi / sectors;

    for (int i = 0; i < sectors; i++) {
      if (i == 0) {
        paint.color = Colors.green;
      } else {
        paint.color = i.isOdd ? Colors.red : Colors.black;
      }
      final start = -pi / 2 + i * sweep;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          start,
          sweep,
          false,
        )
        ..close();
      canvas.drawPath(path, paint);
    }

    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.25, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
