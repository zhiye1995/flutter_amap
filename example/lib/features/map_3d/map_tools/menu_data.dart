import '../menu_models.dart';
import '../route_planning/map_view.dart';

const mapToolsCategory = Map3dCategoryData('地图计算工具', [
  Map3dItemData(
    '坐标系转换',
    pageBuilder: MapViewPage.new,
    isCompleted: true,
  ),
  Map3dItemData('经纬度转屏幕像素'),
  Map3dItemData(
    '两点间距离',
    pageBuilder: MapViewPage.new,
    isCompleted: true,
  ),
  Map3dItemData('点是否在多边形内'),
]);
