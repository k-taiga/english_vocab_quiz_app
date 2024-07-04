import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'entities/word.dart';
import 'exceptions/word_validation_exception.dart';

const collectionKey = 'words';

class WordUpdatePage extends StatefulWidget {
  const WordUpdatePage({super.key, required this.word});
  final Word word;

  @override
  State<WordUpdatePage> createState() => _WordUpdatePageState();
}

class _WordUpdatePageState extends State<WordUpdatePage> {
  late FirebaseFirestore firestore;
  late CollectionReference<Map<String, dynamic>> collection;
  late TextEditingController _englishController;
  late TextEditingController _japaneseController;

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    collection = firestore.collection(collectionKey);
    _englishController = TextEditingController(text: widget.word.english);
    _japaneseController = TextEditingController(text: widget.word.japanese);
  }

  Future<void> update(Word word) async {
    await collection.doc(word.id).update({
      'english': word.english,
      'japanese': word.japanese,
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
  void dispose() {
    _englishController.dispose();
    _japaneseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('単語更新', style: TextStyle(color: Colors.white)),
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
                        controller: _englishController,
                        decoration: const InputDecoration(
                          labelText: '英語',
                          hintText: 'apple',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.language),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _japaneseController,
                        decoration: const InputDecoration(
                          labelText: '日本語',
                          hintText: 'りんご',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.translate),
                        ),
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
                    '更新する',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  onPressed: () {
                    try {
                      final updatedWord = Word.create(
                        id: widget.word.id,
                        english: _englishController.text,
                        japanese: _japaneseController.text,
                        createdDate: widget.word.createdDate,
                      );

                      update(updatedWord).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('単語を更新しました')),
                        );
                        Navigator.pop(context);
                      });
                    } on WordValidationException catch (e) {
                      showErrorDialog(context, e.message);
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
