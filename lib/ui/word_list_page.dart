import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../entities/word.dart';
import '../entities/quiz.dart';
import 'quiz_page.dart';
import 'word_update_page.dart';
import 'word_registration_page.dart';

const collectionKey = 'words';

class WordListPage extends StatefulWidget {
  const WordListPage({super.key});

  @override
  State<WordListPage> createState() => _WordListPageState();
}

class _WordListPageState extends State<WordListPage> {
  List<Word> words = [];
  late FirebaseFirestore firestore;
  late CollectionReference<Map<String, dynamic>> collection;

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    collection = firestore.collection(collectionKey);
    watch();
  }

  Future<void> watch() async {
    collection.snapshots().listen((event) {
      setState(() {
        if (mounted) {
          words = event.docs.reversed
              .map(
                  (document) => Word.fromSnapShot(document.id, document.data()))
              .toList(growable: false);
        }
      });
    });
  }

  Future<void> delete(String id) async {
    final collection = firestore.collection(collectionKey);
    await collection.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('単語一覧', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                final word = words[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Dismissible(
                      key: Key(word.id),
                      onDismissed: (direction) {
                        delete(word.id);
                      },
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      WordUpdatePage(word: word)));
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      word.english,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[800],
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.check_circle,
                                      color: word.correctDate != null
                                          ? Colors.green
                                          : Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      word.correctDate != null
                                          ? '正解: ${word.correctDate!.toLocal().toString().substring(0, 16)}'
                                          : '未正解',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: word.correctDate != null
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  word.japanese,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
                );
              },
              itemCount: words.length,
            ),
          ),
          FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue, foregroundColor: Colors.white),
              onPressed: () {
                // itemからquizListを生成
                final quizList = words
                    .map((word) => Quiz.create(
                        wordId: word.id,
                        question: word.english,
                        answer: word.japanese))
                    // toList(growable: false)はリストを不変にするため毎回新しいリストを生成する
                    .toList();

                quizList.shuffle();

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => QuizPage(quizList: quizList)));
              },
              icon: const Icon(Icons.emoji_events),
              label: const Text('クイズに挑戦')),
          const SizedBox(height: 16)
        ],
      ),
      floatingActionButton: FloatingActionButton(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    // MaterialPageRouteのbuilderにWordRegistrationPageを指定 => は return の省略形
                    builder: (context) => const WordRegistrationPage()));
          },
          child: Icon(Icons.add)),
    );
  }
}
