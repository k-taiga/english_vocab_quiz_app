import 'package:flutter/material.dart';
import 'quiz_result_page.dart';
import '../entities/quiz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

const collectionKey = 'words';

class QuizPage extends StatefulWidget {
  final List<Quiz> quizList;
  const QuizPage({super.key, required this.quizList});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuizIndex = 0;
  bool _showAnswer = false;
  bool _showResult = false;
  bool _isCorrect = false;
  int _score = 0;
  final TextEditingController _answerController = TextEditingController();
  late FirebaseFirestore firestore;
  late CollectionReference<Map<String, dynamic>> collection;

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    collection = firestore.collection(collectionKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('単語クイズ', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: _buildQuiz(),
      ),
    );
  }

  Future<void> updateWordCorrectness(String wordId, bool isCorrect) async {
    final correctDate = isCorrect ? Timestamp.now() : null;
    await collection.doc(wordId).update({'correctDate': correctDate});
  }

  Widget _buildQuiz() {
    return Card(
      // elevationで影の設定 (Material3ではelevationは非推奨)
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: 300,
        height: 300,
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              // クイズの問題文を表示
              widget.quizList[_currentQuizIndex].question,
              style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // showResultがfalseの場合は回答入力欄を表示
            if (!_showResult)
              TextField(
                controller: _answerController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '答えを入力してください',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              )
            else
              //
              Column(
                children: [
                  Icon(
                    _isCorrect ? Icons.check_circle : Icons.cancel,
                    color: _isCorrect ? Colors.green : Colors.red,
                    size: 30,
                  ),
                  Text(
                    _isCorrect ? '正解!' : '不正解',
                    style: TextStyle(
                      fontSize: 24,
                      color: _isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '正解: ${widget.quizList[_currentQuizIndex].answer}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            if (!_showResult)
              ElevatedButton(
                onPressed: () {
                  _checkAnswer(widget.quizList[_currentQuizIndex]);
                },
                child: const Text('回答する',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    )),
              )
            else
              ElevatedButton(
                onPressed: _nextQuiz,
                child: const Text('次の問題へ',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    )),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkAnswer(Quiz quiz) async {
    final currentQuiz = widget.quizList[_currentQuizIndex];

    setState(() {
      // showResultをtrueにして結果を表示
      _showResult = true;
      // 回答が正解かどうかを判定 (完全一致)
      _isCorrect = _answerController.text == currentQuiz.answer;
    });

    if (_isCorrect) {
      _score++;
    }

    await updateWordCorrectness(currentQuiz.wordId, _isCorrect);
  }

  void _nextQuiz() {
    setState(() {
      // widget.quizListの最後までクイズを解いたら結果画面へ遷移
      // listの最後のindexかどうかを判定
      if (_currentQuizIndex < widget.quizList.length - 1) {
        _currentQuizIndex++;
      } else {
        // クイズ終了
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => QuizResultPage(
                    score: _score, totalQuizCount: widget.quizList.length)));
      }
      _showResult = false;
      _answerController.clear();
    });
  }

  // メモリ効率化のためdisposeでwidget破棄時にコントローラを破棄
  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}
