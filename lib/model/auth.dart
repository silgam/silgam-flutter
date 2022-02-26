import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'auth.g.dart';

@JsonSerializable()
class AuthResponse {
  final String firebaseToken;

  const AuthResponse({
    required this.firebaseToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);

  factory AuthResponse.fromJsonString(String json) => AuthResponse.fromJson(jsonDecode(json));

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  @override
  String toString() {
    return 'AuthResponse{firebaseToken: $firebaseToken}';
  }
}
