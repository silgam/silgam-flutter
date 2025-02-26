import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_dto.freezed.dart';
part 'auth_dto.g.dart';

@freezed
class AuthRequest with _$AuthRequest {
  const factory AuthRequest({required String token}) = _AuthRequest;

  factory AuthRequest.fromJson(Map<String, dynamic> json) =>
      _$AuthRequestFromJson(json);

  factory AuthRequest.fromJsonString(String json) =>
      AuthRequest.fromJson(jsonDecode(json));
}

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({required String firebaseToken}) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  factory AuthResponse.fromJsonString(String json) =>
      AuthResponse.fromJson(jsonDecode(json));
}
