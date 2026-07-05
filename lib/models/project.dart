import 'l10n.dart';

class Project {
  const Project({
    required this.name,
    required this.description,
    required this.tech,
    required this.image,
    this.link,
    this.note,
  });

  final String name;          // 고유명사 — 번역 안 함
  final L10n description;
  final List<String> tech;    // 기술명 — 번역 안 함
  final String image;
  final String? link;
  final L10n? note;
}
