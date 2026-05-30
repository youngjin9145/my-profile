class Project {
  const Project({
    required this.name,
    required this.description,
    required this.tech,
    required this.image,
    this.link,
    this.note,
  });

  final String name;
  final String description;
  final List<String> tech;
  final String image;
  final String? link;
  final String? note;
}
