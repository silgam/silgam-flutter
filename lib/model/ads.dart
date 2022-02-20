import 'package:json_annotation/json_annotation.dart';

part 'ads.g.dart';

@JsonSerializable()
class Ads {
  final String title;
  final String imagePath;
  final int priority;
  final String? url;

  const Ads({
    required this.title,
    required this.imagePath,
    required this.priority,
    this.url,
  });

  factory Ads.fromJson(Map<String, dynamic> json) => _$AdsFromJson(json);

  Map<String, dynamic> toJson() => _$AdsToJson(this);

  @override
  String toString() {
    return 'Ads{title: $title, imagePath: $imagePath, priority: $priority, url: $url}';
  }
}
