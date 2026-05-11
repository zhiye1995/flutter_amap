import '../menu_models.dart';
import 'change_map_center.dart';
import 'custom_zoom.dart';
import 'map_animation.dart';
import 'map_controls.dart';
import 'map_controls_position.dart';
import 'map_events.dart';
import 'map_restriction.dart';
import 'map_screenshot.dart';
import 'map_setting.dart';
import 'map_zoom_restriction.dart';
import 'poi_click.dart';

const mapInteractionCategory = Map3dCategoryData('地图交互', [
  Map3dItemData(
    'UI Settings功能',
    pageBuilder: MapControlsPage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    '地图Logo位置',
    pageBuilder: MapControlsPositionPage.new,
    isCompleted: true,
  ),
  Map3dItemData('Layers图层功能'),
  Map3dItemData(
    '手势交互',
    pageBuilder: MapSettingPage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    'Events功能',
    pageBuilder: MapEventsPage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    '地图Poi点击功能',
    pageBuilder: PoiClickPage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    '改变地图中心点',
    pageBuilder: ChangeMapCenterPage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    '地图动画效果',
    pageBuilder: MapAnimationPage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    '自定义缩放',
    pageBuilder: CustomZoomPage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    '地图截屏功能',
    pageBuilder: MapScreenshotPage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    '限制缩放级别功能',
    pageBuilder: MapZoomRestrictionPage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    '限制显示区域功能',
    pageBuilder: MapRestrictionPage.new,
    isCompleted: true,
  ),
]);
