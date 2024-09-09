class AnnouncementType {
  final int id;
  final String title;
  final String description;

  const AnnouncementType({
    required this.id,
    required this.title,
    required this.description,
  });
}

const announcementTypes = [
  AnnouncementType(
    id: 2,
    title: '클래식 음악',
    description: '2024학년도 수능에 사용된 음원',
  ),
  AnnouncementType(
    id: 1,
    title: '부저음',
    description: '2022학년도 수능에 사용된 음원 (코로나 관련 안내 포함)',
  ),
];

final AnnouncementType defaultAnnouncementType = announcementTypes.first;
