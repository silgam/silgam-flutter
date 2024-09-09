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
    title: '2024학년도 수능 타종 소리 (경기도교육청)',
    description: '클래식 음악',
  ),
  AnnouncementType(
    id: 1,
    title: '2022학년도 수능 타종 소리 (인천광역시교육청)',
    description: '삐 소리, 코로나 관련 안내가 포함되어 있음',
  ),
];

final AnnouncementType defaultAnnouncementType = announcementTypes.first;
