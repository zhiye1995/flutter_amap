import '../menu_models.dart';
import 'coordinate_convert_page.dart';
import 'line_distance_page.dart';
import 'polygon_contains_page.dart';
import 'screen_location_page.dart';

const mapToolsCategory = Map3dCategoryData('地图计算工具', [
  Map3dItemData(
    CoordinateConvertPage.title,
    pageBuilder: CoordinateConvertPage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    ScreenLocationPage.title,
    pageBuilder: ScreenLocationPage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    LineDistancePage.title,
    pageBuilder: LineDistancePage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    PolygonContainsPage.title,
    pageBuilder: PolygonContainsPage.new,
    isCompleted: true,
  ),
]);
