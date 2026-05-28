class StoryAudio {
  final String id;
  final String storyId;
  final String audioUrl;
  final int durationSeconds;
  final DateTime createdAt;

  const StoryAudio({
    required this.id,
    required this.storyId,
    required this.audioUrl,
    this.durationSeconds = 0,
    required this.createdAt,
  });

  factory StoryAudio.fromJson(Map<String, dynamic> json) => StoryAudio(
        id: json['id'] as String,
        storyId: json['story_id'] as String,
        audioUrl: json['audio_url'] as String,
        durationSeconds: json['duration_seconds'] as int? ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  String get formattedDuration {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Duration get duration => Duration(seconds: durationSeconds);
}
