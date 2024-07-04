import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_vocab_quiz_app/exceptions/word_validation_exception.dart';

class Word {
  final String id;
  final String english;
  final String japanese;
  final DateTime createdDate;
  final DateTime? correctDate;

  // ._()はコンストラクタをプライベートにする
  Word._(
      {required this.id,
      required this.english,
      required this.japanese,
      required this.createdDate,
      this.correctDate});

  static bool _isValidEnglish(String word) {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(word);
  }

  static bool _isValidJapanese(String word) {
    return RegExp(r'^[ぁ-んァ-ンー一-龥]+$').hasMatch(word);
  }

  static Word create({
    required String id,
    required String english,
    required String japanese,
    required DateTime createdDate,
  }) {
    if (!_isValidEnglish(english)) {
      throw WordValidationException('英単語はアルファベットで入力してください');
    }
    if (!_isValidJapanese(japanese)) {
      throw WordValidationException('日本語はひらがな、カタカナ、漢字で入力してください');
    }
    return Word._(
        id: id, english: english, japanese: japanese, createdDate: createdDate);
  }

  factory Word.fromSnapShot(String id, Map<String, dynamic> document) {
    return Word._(
        id: id,
        english: document['english'].toString() ?? '',
        japanese: document['japanese'].toString() ?? '',
        createdDate:
            (document['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        correctDate: (document['correctDate'] as Timestamp?)?.toDate());
  }
}
