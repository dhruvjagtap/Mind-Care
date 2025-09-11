class Counselor {
  final String id;
  final String name;
  final List<String> specialties;
  final List<String> languages;
  final String? photoUrl;
  final bool isActive;

  Counselor({
    required this.id,
    required this.name,
    required this.specialties,
    required this.languages,
    required this.photoUrl,
    required this.isActive,
  });

  factory Counselor.fromDoc(Map<String, dynamic> json, String id) {
    return Counselor(
      id: id,
      name: json['name'] ?? '',
      specialties: List<String>.from(json['specialties'] ?? const []),
      languages: List<String>.from(json['languages'] ?? const []),
      photoUrl: json['photoUrl'],
      isActive: (json['isActive'] as bool?) ?? true,
    );
  }
}
