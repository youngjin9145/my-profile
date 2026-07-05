import '../models/l10n.dart';
import '../models/project.dart';

class ProfileData {
  ProfileData._();

  static const String handle = 'Youngjin Lee';
  static const String terminalTitle = 'yj@shadow: ~';

  static const List<L10n> roles = [
    L10n('Flutter App Developer', 'Flutter 앱 개발자'),
    L10n('Security Enthusiast', '보안 애호가'),
    L10n('Game Hacker (for fun)', '게임 해커 (취미로)'),
  ];

  static const about = L10n(
    'App developer by trade, security tinkerer by obsession.\n\n'
    'I craft cross-platform apps with Flutter & Dart, and spend my off-hours '
    'reverse-engineering games and poking at systems to learn how they really work.\n\n'
    'I like building things — and understanding them well enough to take them apart.',
    '직업은 앱 개발자, 취미는 보안 만지작거리기.\n\n'
    'Flutter와 Dart로 크로스플랫폼 앱을 만들고, 남는 시간엔 게임을 리버스 엔지니어링하며 '
    '시스템이 실제로 어떻게 돌아가는지 파고듭니다.\n\n'
    '무언가를 만드는 것도, 그걸 뜯어볼 만큼 제대로 이해하는 것도 좋아합니다.',
  );

  static const List<String> skills = [
    'Dart',
    'Flutter',
    'Cross-platform Apps',
    'Reverse Engineering',
    'Game Hacking',
    'Cybersecurity',
  ];

  static const List<L10n> awards = [
    L10n('Industrial Engineer Information Security', '정보보안산업기사'),
    L10n('Silver — National Skills Competition (Cyber Security)',
        '은상 — 전국기능경기대회 (사이버 보안)'),
    L10n('Golden — Regional Skills Competition (Mobile App)',
        '금상 — 지방기능경기대회 (모바일 앱)'),
  ];

  static const List<Project> projects = [
    Project(
      name: 'Survev.io Game Hack',
      description: L10n(
        'Aimbot & ESP for survev.io, an open-source browser game — a reverse-engineering exercise.',
        '오픈소스 브라우저 게임 survev.io용 에임봇 & ESP — 리버스 엔지니어링 연습작.',
      ),
      tech: ['JavaScript'],
      image: 'assets/projects/survev.png',
      note: L10n(
        'Built & tested in an isolated environment only — never used against real players.',
        '격리된 환경에서만 제작·테스트 — 실제 유저 대상 사용 없음.',
      ),
    ),
    Project(
      name: 'Tarot Reader',
      description: L10n(
        'Card-pick tarot app with multiple spreads — birth-date, love, and more.',
        '여러 스프레드를 지원하는 카드 선택 타로 앱 — 생년월일, 연애 등.',
      ),
      tech: ['Flutter', 'Dart'],
      image: 'assets/projects/tarot.png',
    ),
    Project(
      name: 'Car Control',
      description: L10n(
        'Vehicle remote-control prototype built with sample data.',
        '샘플 데이터로 만든 차량 원격제어 프로토타입.',
      ),
      tech: ['Flutter', 'Dart'],
      image: 'assets/projects/car.png',
    ),
  ];

  static const String github = 'https://github.com/youngjin9145';
  static const String linkedin =
      'https://www.linkedin.com/in/%EC%98%81%EC%A7%84-%EC%9D%B4-089a013a5/';
  static const String email = 'aronia3006@gmail.com';
  static const String instagram = 'https://www.instagram.com/realyoung___public/';
}
