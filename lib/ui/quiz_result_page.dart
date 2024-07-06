import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class QuizResultPage extends StatefulWidget {
  final int score;
  final int totalQuizCount;
  const QuizResultPage(
      {super.key, required this.score, required this.totalQuizCount});

  @override
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage> {
  late bool _isFullScore;
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 5));

  @override
  void initState() {
    super.initState();
    _isFullScore = widget.score == widget.totalQuizCount;
  }

  Widget _buildConfetti() {
    _confettiController.play();
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        numberOfParticles: 30,
        gravity: 0.2,
        emissionFrequency: 0.05,
        maxBlastForce: 10,
        minBlastForce: 5,
        colors: const [Colors.blue, Colors.green, Colors.yellow],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: const Text('クイズ結果', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // このtextにアニメーションを追加
            Text(
              'あなたのスコアは${widget.score}/${widget.totalQuizCount}です',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            const SizedBox(height: 20),
            // ...[]で複数のWidgetを追加
            if (_isFullScore) ...[
              _buildConfetti(),
              const Text('全問正解おめでとうございます！',
                  style: TextStyle(fontSize: 24, color: Colors.blue)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('一覧に戻る', style: TextStyle(color: Colors.blue)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
