class StoryPage {
  final String id;
  final String storyId;
  final int pageNumber;
  final String textContent;
  final String? imageUrl;
  final DateTime createdAt;

  const StoryPage({
    required this.id,
    required this.storyId,
    required this.pageNumber,
    required this.textContent,
    this.imageUrl,
    required this.createdAt,
  });

  factory StoryPage.fromJson(Map<String, dynamic> json) => StoryPage(
        id: json['id'] as String,
        storyId: json['story_id'] as String,
        pageNumber: json['page_number'] as int,
        textContent: json['text_content'] as String,
        imageUrl: json['image_url'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
