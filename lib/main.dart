import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int theAngle;
  late int biais;
  int attempts = 0;
  TextEditingController controller = TextEditingController();
  List<int> guesses = [];
  bool correct = false;
  bool loss = false;

  @override
  void initState() {
    theAngle = generateRandomAngle();
    biais = generateRandomAngle();
    print("Angle : $theAngle");
    print("Biais : $biais");
    super.initState();
  }

  int generateRandomAngle() {
    return Random().nextInt(301) + 30;
  }

  void init() {
    if (correct || loss) {
      correct = false;
      loss = false;
      attempts = 0;
      guesses = [];
      theAngle = generateRandomAngle();
      biais = generateRandomAngle();
      print("Angle : $theAngle");
      print("Biais : $biais");
      setState(() {});
    }
  }

  Future<void> guess() async {
    final int? value = int.tryParse(controller.text);

    if (value == null || controller.text.contains('-')) {
      showInvalidInput();
      controller.clear();
      return;
    }
    if (!correct &&
        attempts < 4 &&
        value != null &&
        !controller.text.contains('-')) {
      guesses.add(int.parse(controller.text));
      if (int.parse(controller.text) == theAngle) {
        correct = true;
        await StatisticsService.recordWin(guesses.length);
      }
      attempts++;
      if (attempts == 4) {
        loss = true;
        for (var i = 0; i < guesses.length; i++) {
          if (guesses[i] == theAngle) {
            loss = false;
          }
        }
        if (loss) {
          await StatisticsService.recordLoss();
        }
      }
      controller.clear();
      setState(() {});
    }
  }

  void showInvalidInput() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Please enter a positive integer.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: const Color.fromARGB(
          255,
          123,
          48,
          48,
        ).withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 100,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 46, 46, 46),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  (correct)
                      ? Text(
                          "🎉 ${theAngle}° 🎉",
                          style: const TextStyle(
                            color: Color.fromARGB(255, 194, 194, 194),
                            fontSize: 17,
                          ),
                        )
                      : (loss)
                      ? Text(
                          "${theAngle}°",
                          style: const TextStyle(
                            color: Color.fromARGB(255, 194, 194, 194),
                            fontSize: 17,
                          ),
                        )
                      : Text(
                          "???",
                          style: const TextStyle(
                            color: Color.fromARGB(255, 194, 194, 194),
                            fontSize: 17,
                          ),
                        ),
                  SizedBox(height: 20),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        onTap: () {
                          showHowToPlayDialog(context);
                        },
                        child: Image.asset('assets/question.png', height: 20),
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        onTap: () {
                          showStatisticsDialog(context);
                        },
                        child: Image.asset('assets/graph.png', height: 20),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 300,
                    child: Angle(
                      theAngle: theAngle.toDouble(),
                      biais: biais.toDouble(),
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: (correct || attempts == 4)
                            ? Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 21, 21, 21),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                ),
                              )
                            : MyTextField(controller: controller),
                      ),

                      const SizedBox(width: 10),

                      MyButton(
                        text: "Guess!",
                        height: 45,
                        width: 70,
                        fct: guess,
                        end: (correct || loss) ? true : false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Attempts: $attempts/4",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  rowBoxes(
                    guessed: guesses.length >= 1,
                    guess: guesses.length >= 1 ? guesses[0] : 0,
                    realAngle: theAngle,
                  ),

                  const SizedBox(height: 3),

                  rowBoxes(
                    guessed: guesses.length >= 2,
                    guess: guesses.length >= 2 ? guesses[1] : 0,
                    realAngle: theAngle,
                  ),

                  const SizedBox(height: 3),

                  rowBoxes(
                    guessed: guesses.length >= 3,
                    guess: guesses.length >= 3 ? guesses[2] : 0,
                    realAngle: theAngle,
                  ),

                  const SizedBox(height: 3),

                  rowBoxes(
                    guessed: guesses.length >= 4,
                    guess: guesses.length >= 4 ? guesses[3] : 0,
                    realAngle: theAngle,
                  ),

                  const SizedBox(height: 30),

                  MyButton(
                    text: "Next",
                    height: 40,
                    width: 200,
                    fct: init,
                    end: (correct || loss) ? true : false,
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> showHowToPlayDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.70),
      builder: (_) => const HowToPlayDialog(),
    );
  }
}

class HowToPlayDialog extends StatelessWidget {
  const HowToPlayDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.72,
        padding: const EdgeInsets.fromLTRB(36, 22, 36, 10),
        decoration: BoxDecoration(
          color: const Color(0xFF202020).withOpacity(0.96),
          border: Border.all(color: Colors.white.withOpacity(0.20), width: 2),
        ),
        child: Column(
          children: [
            // ─────────────────────────────
            // TITLE
            // ─────────────────────────────
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'How to play!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: Colors.white.withOpacity(0.55),
                    size: 32,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ─────────────────────────────
            // SCROLLABLE CONTENT
            // ─────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Guess the Angle in 4\nguesses or less!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Each time you make a guess it will tell you '
                      'how close you are and which direction to go.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 38),

                    const Text(
                      'Example:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ─────────────────────
                    // ANGLE EXAMPLE
                    // ─────────────────────
                    Center(
                      child: SizedBox(
                        height: 180,
                        width: 250,
                        child: Angle(theAngle: 65, biais: 0),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ─────────────────────
                    // EXAMPLE GUESSES
                    // ─────────────────────
                    _ExampleRow(
                      guess: 50,
                      direction: '⬆️',
                      hint: 'Getting\nHot',
                    ),

                    const SizedBox(height: 3),

                    _ExampleRow(guess: 73, direction: '⬇️', hint: 'Hot!'),

                    const SizedBox(height: 3),

                    _ExampleRow(
                      guess: 62,
                      direction: '⬆️',
                      hint: 'Boiling! 🔥',
                    ),

                    const SizedBox(height: 35),

                    const Text(
                      'The hint tells you how warm your guess was '
                      'and the arrow tells you to guess higher or lower.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'The answer in this case was:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ─────────────────────
                    // ANSWER
                    // ─────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        box(width: 80, text: '65°', guessed: true),

                        const SizedBox(width: 3),

                        box(width: 50, text: '🥳', guessed: true),

                        const SizedBox(width: 3),

                        box(width: 100, text: '🎉🎉🎉', guessed: true),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleRow extends StatelessWidget {
  const _ExampleRow({
    required this.guess,
    required this.direction,
    required this.hint,
  });

  final int guess;
  final String direction;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        box(width: 80, text: '$guess°', guessed: true),

        const SizedBox(width: 3),

        box(width: 50, text: direction, guessed: true),

        const SizedBox(width: 3),

        box(width: 100, text: hint, guessed: true),
      ],
    );
  }
}

class Angle extends StatelessWidget {
  const Angle({super.key, required this.theAngle, required this.biais});

  final double theAngle;
  final double biais;

  // dimensions
  final double lineLength = 105;
  final double lineThickness = 3;

  final double arcRadius = 20;
  final double arcThickness = 3;

  final double pivotSize = 8;

  @override
  Widget build(BuildContext context) {
    final rotAngle1 = biais * pi / 180;
    final rotAngle2 = (180 + theAngle) * pi / 180 + rotAngle1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);

        final center = size / 2;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                Positioned(
                  left: center - arcRadius,
                  top: center - arcRadius,
                  child: CustomPaint(
                    size: Size(arcRadius * 2, arcRadius * 2),
                    painter: AnglePainter(
                      startAngle: pi + rotAngle1,
                      sweepAngle: theAngle * pi / 180,
                      radius: arcRadius,
                      thickness: arcThickness,
                    ),
                  ),
                ),

                Positioned(
                  left: center - lineLength,
                  top: center - lineThickness / 2,
                  child: Transform.rotate(
                    angle: rotAngle1,
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: lineLength,
                      height: lineThickness,
                      color: const Color.from(
                        alpha: 1,
                        red: 0.957,
                        green: 0.263,
                        blue: 0.212,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: center,
                  top: center - lineThickness / 2,
                  child: Transform.rotate(
                    angle: rotAngle2,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: lineLength,
                      height: lineThickness,
                      color: Colors.red,
                    ),
                  ),
                ),

                Positioned(
                  left: center - pivotSize / 2,
                  top: center - pivotSize / 2,
                  child: Container(
                    width: pivotSize,
                    height: pivotSize,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 224, 224, 224),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AnglePainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;
  final double radius;
  final double thickness;

  AnglePainter({
    required this.startAngle,
    required this.sweepAngle,
    required this.radius,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 145, 199, 244)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant AnglePainter oldDelegate) {
    return oldDelegate.startAngle != startAngle ||
        oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.radius != radius ||
        oldDelegate.thickness != thickness;
  }
}

class MyTextField extends StatefulWidget {
  const MyTextField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,

      style: const TextStyle(color: Colors.white),

      cursorColor: Colors.white,

      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(255, 21, 21, 21),

        hintStyle: const TextStyle(color: Colors.grey),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.text,
    required this.height,
    required this.width,
    required this.fct,
    required this.end,
  });

  final String text;
  final double height;
  final double width;
  final Function fct;
  final bool end;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          fct();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: (text == "Next" && end)
                ? Colors.red
                : Color.fromARGB(255, 101, 101, 101),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class box extends StatefulWidget {
  const box({
    super.key,
    required this.width,
    required this.text,
    required this.guessed,
  });

  final double width;
  final String text;
  final bool guessed;

  @override
  State<box> createState() => _boxState();
}

class _boxState extends State<box> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Color.fromARGB(255, 48, 48, 48),
      ),
      child: Center(
        child: (widget.guessed)
            ? Text(
                widget.text,
                style: TextStyle(color: Colors.white, fontSize: 16),
              )
            : SizedBox.shrink(),
      ),
    );
  }
}

class rowBoxes extends StatelessWidget {
  const rowBoxes({
    super.key,
    required this.guessed,
    required this.guess,
    required this.realAngle,
  });

  final bool guessed;
  final int guess;
  final int realAngle;

  @override
  Widget build(BuildContext context) {
    String hint = "";
    String hint2 = "";

    if (guessed) {
      // Direction
      if (guess == realAngle) {
        hint = "🥳";
        hint2 = "🎉🎉🎉";
      } else if (guess > realAngle) {
        hint = "⬇️";
      } else {
        hint = "⬆️";
      }

      // Différence
      int difference = (guess - realAngle).abs();

      if (difference != 0) {
        if (difference <= 3) {
          hint2 = "Boiling! 🔥";
        } else if (difference <= 10) {
          hint2 = "Hot!";
        } else if (difference <= 15) {
          hint2 = "Getting Hot";
        } else {
          hint2 = "Cold";
        }
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        box(width: 100, text: "$guess°", guessed: guessed),
        const SizedBox(width: 3),
        box(width: 50, text: hint, guessed: guessed),
        const SizedBox(width: 3),
        box(width: 120, text: hint2, guessed: guessed),
      ],
    );
  }
}

Future<void> showStatisticsDialog(BuildContext context) async {
  final played = await StatisticsService.getPlayed();
  final wins = await StatisticsService.getWins();
  final winPercentage = await StatisticsService.getWinPercentage();

  final currentStreak = await StatisticsService.getCurrentStreak();

  final maxStreak = await StatisticsService.getMaxStreak();

  final distribution = await StatisticsService.getDistribution();

  await showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.70),
    builder: (_) => StatisticsDialog(
      winPercentage: winPercentage,
      played: played,
      currentStreak: currentStreak,
      maxStreak: maxStreak,
      distribution: distribution,
    ),
  );
}

class StatisticsDialog extends StatelessWidget {
  const StatisticsDialog({
    super.key,
    required this.winPercentage,
    required this.played,
    required this.currentStreak,
    required this.maxStreak,
    required this.distribution,
  });

  final int winPercentage;
  final int played;
  final int currentStreak;
  final int maxStreak;
  final Map<int, int> distribution;

  @override
  Widget build(BuildContext context) {
    final maxValue = distribution.isEmpty
        ? 1
        : distribution.values.reduce((a, b) => a > b ? a : b);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(36, 22, 36, 32),
        decoration: BoxDecoration(
          color: const Color(0xFF202020).withOpacity(0.96),
          border: Border.all(color: Colors.white.withOpacity(0.20), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─────────────────────────────
            // TITLE
            // ─────────────────────────────
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Statistics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: Colors.white.withOpacity(0.55),
                    size: 32,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ─────────────────────────────
            // STATISTICS
            // ─────────────────────────────
            Row(
              children: [
                _Statistic(value: '$winPercentage', label: 'Win\n%'),
                _Statistic(value: '$played', label: 'Played\n'),
                _Statistic(value: '$currentStreak', label: 'Current\nStreak'),
                _Statistic(value: '$maxStreak', label: 'Max\nStreak'),
              ],
            ),

            const SizedBox(height: 30),

            // ─────────────────────────────
            // DISTRIBUTION TITLE
            // ─────────────────────────────
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Guess Distribution:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ─────────────────────────────
            // DISTRIBUTION
            // ─────────────────────────────
            ...distribution.entries.map(
              (entry) => _DistributionRow(
                guess: entry.key,
                value: entry.value,
                maxValue: maxValue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Statistic extends StatelessWidget {
  const _Statistic({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w300,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({
    required this.guess,
    required this.value,
    required this.maxValue,
  });

  final int guess;
  final int value;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    final ratio = value / maxValue;

    return SizedBox(
      height: 52,
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(
              '$guess',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: constraints.maxWidth * ratio,
                    height: 38,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF191919),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$value',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StatisticsService {
  static const String _playedKey = 'stats_played';
  static const String _winsKey = 'stats_wins';
  static const String _currentStreakKey = 'stats_current_streak';
  static const String _maxStreakKey = 'stats_max_streak';
  static const String _distributionKey = 'stats_distribution';

  // ─────────────────────────────────────────────
  // GETTERS
  // ─────────────────────────────────────────────

  static Future<int> getPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_playedKey) ?? 0;
  }

  static Future<int> getWins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_winsKey) ?? 0;
  }

  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentStreakKey) ?? 0;
  }

  static Future<int> getMaxStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_maxStreakKey) ?? 0;
  }

  static Future<Map<int, int>> getDistribution() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(_distributionKey);

    if (jsonString == null) {
      return {};
    }

    final Map<String, dynamic> decoded = jsonDecode(jsonString);

    return decoded.map((key, value) => MapEntry(int.parse(key), value as int));
  }

  // ─────────────────────────────────────────────
  // WIN PERCENTAGE
  // ─────────────────────────────────────────────

  static Future<int> getWinPercentage() async {
    final played = await getPlayed();
    final wins = await getWins();

    if (played == 0) {
      return 0;
    }

    return ((wins / played) * 100).round();
  }

  // ─────────────────────────────────────────────
  // RECORD A WIN
  // ─────────────────────────────────────────────

  static Future<void> recordWin(int guesses) async {
    final prefs = await SharedPreferences.getInstance();

    final played = prefs.getInt(_playedKey) ?? 0;
    final wins = prefs.getInt(_winsKey) ?? 0;
    final currentStreak = prefs.getInt(_currentStreakKey) ?? 0;
    final maxStreak = prefs.getInt(_maxStreakKey) ?? 0;

    // Played
    await prefs.setInt(_playedKey, played + 1);

    // Wins
    await prefs.setInt(_winsKey, wins + 1);

    // Current streak
    final newCurrentStreak = currentStreak + 1;

    await prefs.setInt(_currentStreakKey, newCurrentStreak);

    // Max streak
    if (newCurrentStreak > maxStreak) {
      await prefs.setInt(_maxStreakKey, newCurrentStreak);
    }

    // Distribution
    final distribution = await getDistribution();

    distribution[guesses] = (distribution[guesses] ?? 0) + 1;

    await _saveDistribution(distribution);
  }

  // ─────────────────────────────────────────────
  // RECORD A LOSS
  // ─────────────────────────────────────────────

  static Future<void> recordLoss() async {
    final prefs = await SharedPreferences.getInstance();

    final played = prefs.getInt(_playedKey) ?? 0;

    await prefs.setInt(_playedKey, played + 1);

    // Une défaite remet la série actuelle à zéro
    await prefs.setInt(_currentStreakKey, 0);
  }

  // ─────────────────────────────────────────────
  // SAVE DISTRIBUTION
  // ─────────────────────────────────────────────

  static Future<void> _saveDistribution(Map<int, int> distribution) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = jsonEncode(
      distribution.map((key, value) => MapEntry(key.toString(), value)),
    );

    await prefs.setString(_distributionKey, jsonString);
  }

  // ─────────────────────────────────────────────
  // RESET
  // ─────────────────────────────────────────────

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_playedKey);
    await prefs.remove(_winsKey);
    await prefs.remove(_currentStreakKey);
    await prefs.remove(_maxStreakKey);
    await prefs.remove(_distributionKey);
  }
}
