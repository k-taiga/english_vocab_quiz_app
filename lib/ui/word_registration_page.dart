import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../entities/word.dart';
import '../exceptions/word_validation_exception.dart';

class WordRegistrationPage extends StatefulWidget {
  const WordRegistrationPage({super.key});

  @override
  State<WordRegistrationPage> createState() => _WordRegistrationPageState();
}

class _WordRegistrationPageState extends State<WordRegistrationPage> {
  late FirebaseFirestore firestore;
  late CollectionReference<Map<String, dynamic>> collection;
  String _englishWord = '';
  String _japaneseWord = '';

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    collection = firestore.collection('words');
  }

  Future<void> save(Word word) async {
    await collection.doc(word.id).set({
      'english': word.english,
      'japanese': word.japanese,
      'createdDate': word.createdDate,
    });
  }

  Future<void> showErrorDialog(BuildContext context, String message) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('エラー'),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('単語登録', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: '英語',
                          hintText: 'apple',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.language),
                        ),
                        onChanged: (text) {
                          _englishWord = text;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: '日本語',
                          hintText: 'りんご',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.translate),
                        ),
                        onChanged: (text) {
                          _japaneseWord = text;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '登録する',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                onPressed: () {
                  try {
                    final word = Word.create(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      english: _englishWord,
                      japanese: _japaneseWord,
                      createdDate: DateTime.now(),
                    );

                    save(word).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('単語を登録しました')),
                      );
                      Navigator.pop(context);
                    });
                  } on WordValidationException catch (e) {
                    showErrorDialog(context, e.message);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
