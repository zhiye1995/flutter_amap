import 'package:flutter/widgets.dart';

class Map3dItemData {
  final String title;
  final Widget Function()? pageBuilder;
  final bool isCompleted;

  const Map3dItemData(
    this.title, {
    this.pageBuilder,
    this.isCompleted = false,
  });
}

class Map3dCategoryData {
  final String title;
  final List<Map3dItemData> items;

  const Map3dCategoryData(this.title, this.items);
}
