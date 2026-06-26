class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String category;
  final bool isFavorite;
  final DateTime createdAt;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.category = 'General Knowledge',
    this.isFavorite = false,
    required this.createdAt,
  });

  /// Convert a Flashcard object to a JSON-compatible Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Recreate a Flashcard object from a JSON Map.
  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      category: (json['category'] as String?) ?? 'General Knowledge',
      isFavorite: (json['isFavorite'] as bool?) ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Create a copy of the Flashcard with optional modifications.
  Flashcard copyWith({
    String? id,
    String? question,
    String? answer,
    String? category,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
