import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isDefault,
  });

  final String id;
  final String name;
  final String icon;
  final String color;
  final bool isDefault;

  @override
  List<Object?> get props => [id, name, icon, color, isDefault];
}
