import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isDefault,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  final String id;
  final String name;
  final String icon;
  final String color;
  @JsonKey(name: 'isDefault', defaultValue: false)
  final bool isDefault;

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
}
