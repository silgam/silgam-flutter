// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ads.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ads _$AdsFromJson(Map<String, dynamic> json) => Ads(
      title: json['title'] as String,
      imagePath: json['imagePath'] as String,
      priority: json['priority'] as int,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$AdsToJson(Ads instance) => <String, dynamic>{
      'title': instance.title,
      'imagePath': instance.imagePath,
      'priority': instance.priority,
      'url': instance.url,
    };
