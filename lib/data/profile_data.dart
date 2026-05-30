import '../models/project.dart';

class ProfileData {
  ProfileData._();

  static const String handle = 'Cid Kagenou';
  static const String terminalTitle = 'cid@shadow: ~';

  static const List<String> roles = [
    'Flutter App Developer',
    'Security Enthusiast',
    'Game Hacker (for fun)',
  ];

  static const String about =
      'App developer by trade, security tinkerer by obsession.\n\n'
      'I craft cross-platform apps with Flutter & Dart, and spend my off-hours '
      'reverse-engineering games and poking at systems to learn how they really work.\n\n'
      'I like building things — and understanding them well enough to take them apart.';

  static const List<String> skills = [
    'Dart',
    'Flutter',
    'Cross-platform Apps',
    'Reverse Engineering',
    'Game Hacking',
    'Cybersecurity',
  ];

  static const List<String> awards = [
    'Industrial Engineer Information Security',
    'Silver — National Skills Competition (Cyber Security)',
    'Golden — Regional Skills Competition (Mobile App)',
  ];

  static const List<Project> projects = [
    Project(
      name: 'Survev.io Game Hack',
      description:
          'Aimbot & ESP for survev.io, an open-source browser game — a reverse-engineering exercise.',
      tech: ['JavaScript'],
      image: 'assets/projects/survev.png',
      note:
          'Built & tested in an isolated environment only — never used against real players.',
    ),
    Project(
      name: 'Tarot Reader',
      description:
          'Card-pick tarot app with multiple spreads — birth-date, love, and more.',
      tech: ['Flutter', 'Dart'],
      image: 'assets/projects/tarot.png',
    ),
    Project(
      name: 'Car Control',
      description: 'Vehicle remote-control prototype built with sample data.',
      tech: ['Flutter', 'Dart'],
      image: 'assets/projects/car.png',
    ),
  ];
}
