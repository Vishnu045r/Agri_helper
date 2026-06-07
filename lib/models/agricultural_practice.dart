class AgriculturalPractice {
  final String category;
  final String title;
  final String description;
  final List<String> benefits;
  final String implementation;
  final String cost;
  final String suitableFor;
  final String? imageUrl;

  AgriculturalPractice({
    required this.category,
    required this.title,
    required this.description,
    required this.benefits,
    required this.implementation,
    required this.cost,
    required this.suitableFor,
    this.imageUrl,
  });

  factory AgriculturalPractice.fromJson(Map<String, dynamic> json) {
    return AgriculturalPractice(
      category: json['category'],
      title: json['title'],
      description: json['description'],
      benefits: List<String>.from(json['benefits']),
      implementation: json['implementation'],
      cost: json['cost'],
      suitableFor: json['suitable_for'],
      imageUrl: json['image_url'],
    );
  }
}
