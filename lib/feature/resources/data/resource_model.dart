class ResourceModel {
  final String id;
  final String title;
  final String description;
  final String type; // video, audio, pdf
  final String category;
  final String url;

  ResourceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.url,
  });

  factory ResourceModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ResourceModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'video',
      category: data['category'] ?? '',
      url: data['url'] ?? '',
    );
  }
}
