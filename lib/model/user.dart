import 'package:freezed_annotation/freezed_annotation.dart';

import 'product.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  factory User({
    required final String id,
    required final Product activeProduct,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
