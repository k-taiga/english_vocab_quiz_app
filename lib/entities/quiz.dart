class Quiz {
  final String wordId;
  final String question;
  final String answer;

  Quiz._({
    required this.wordId,
    required this.question,
    required this.answer,
  });

  factory Quiz.create({
    required String wordId,
    required String question,
    required String answer,
  }) {
    return Quiz._(
      wordId: wordId,
      question: question,
      answer: answer,
    );
  }
}
