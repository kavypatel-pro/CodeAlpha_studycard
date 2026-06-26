class StudyStats {
  final int totalSessions;
  final int streak;
  final String? lastStudyDate; // Format: 'yyyy-MM-dd'
  final List<String> datesStudied; // List of study dates in 'yyyy-MM-dd' format
  final int cardsReviewed;
  final int cardsMastered;

  StudyStats({
    this.totalSessions = 0,
    this.streak = 0,
    this.lastStudyDate,
    List<String>? datesStudied,
    this.cardsReviewed = 0,
    this.cardsMastered = 0,
  }) : datesStudied = datesStudied ?? const [];

  Map<String, dynamic> toJson() {
    return {
      'totalSessions': totalSessions,
      'streak': streak,
      'lastStudyDate': lastStudyDate,
      'datesStudied': datesStudied,
      'cardsReviewed': cardsReviewed,
      'cardsMastered': cardsMastered,
    };
  }

  factory StudyStats.fromJson(Map<String, dynamic> json) {
    return StudyStats(
      totalSessions: (json['totalSessions'] as int?) ?? 0,
      streak: (json['streak'] as int?) ?? 0,
      lastStudyDate: json['lastStudyDate'] as String?,
      datesStudied: (json['datesStudied'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      cardsReviewed: (json['cardsReviewed'] as int?) ?? 0,
      cardsMastered: (json['cardsMastered'] as int?) ?? 0,
    );
  }

  StudyStats copyWith({
    int? totalSessions,
    int? streak,
    String? lastStudyDate,
    List<String>? datesStudied,
    int? cardsReviewed,
    int? cardsMastered,
  }) {
    return StudyStats(
      totalSessions: totalSessions ?? this.totalSessions,
      streak: streak ?? this.streak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      datesStudied: datesStudied ?? this.datesStudied,
      cardsReviewed: cardsReviewed ?? this.cardsReviewed,
      cardsMastered: cardsMastered ?? this.cardsMastered,
    );
  }
}
