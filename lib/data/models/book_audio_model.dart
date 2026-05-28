class BookAudio {
  final String id;
  final String bookId;
  final String languageCode;
  final String audioUrl;
  final int durationSeconds;
  final List<WordTimestamp>? wordTimestamps;
  final DateTime createdAt;

  const BookAudio({
    required this.id,
    required this.bookId,
    required this.languageCode,
    required this.audioUrl,
    this.durationSeconds = 0,
    this.wordTimestamps,
    required this.createdAt,
  });

  factory BookAudio.fromJson(Map<String, dynamic> json) => BookAudio(
        id: json['id'] as String,
        bookId: json['book_id'] as String,
        languageCode: json['language_code'] as String,
        audioUrl: json['audio_url'] as String,
        durationSeconds: json['duration_seconds'] as int? ?? 0,
        wordTimestamps: json['word_timestamps'] != null
            ? (json['word_timestamps'] as List)
                .map((e) => WordTimestamp.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  String get formattedDuration {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Duration get duration => Duration(seconds: durationSeconds);
}

/// For future karaoke/highlight feature
class WordTimestamp {
  final String word;
  final double startMs;
  final double endMs;

  const WordTimestamp({
    required this.word,
    required this.startMs,
    required this.endMs,
  });

  factory WordTimestamp.fromJson(Map<String, dynamic> json) => WordTimestamp(
        word: json['word'] as String,
        startMs: (json['start_ms'] as num).toDouble(),
        endMs: (json['end_ms'] as num).toDouble(),
      );
}
