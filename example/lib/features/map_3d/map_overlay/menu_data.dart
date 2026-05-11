import '../menu_models.dart';
import 'add_remove_marker.dart';
import 'custom_marker_page.dart';
import 'info_window_page.dart';
import 'marker_animation_page.dart';
import 'marker_click_callback_page.dart';
import 'polyline_pages.dart';
import 'user_location.dart';
import 'user_location_custom_page.dart';

const mapOverlayCategory = Map3dCategoryData('地图上绘制', [
  Map3dItemData(
    'Markers功能',
    pageBuilder: AddRemoveMarkerPage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    'Marker点击回调',
    pageBuilder: MarkerClickCallbackPage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    'Marker动画功能',
    pageBuilder: MarkerAnimationPage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    'InfoWindow功能',
    pageBuilder: InfoWindowPage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    '自定义Marker',
    pageBuilder: CustomMarkerPage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    'Location几种模式',
    pageBuilder: UserLocationPage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    'Location小蓝点自定义功能',
    pageBuilder: UserLocationCustomPage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    'Location小蓝点自定义模式',
    pageBuilder: UserLocationCustomPage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    'Polylines功能',
    pageBuilder: PolylinesPage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    '绘制多彩线',
    pageBuilder: MultiColorPolylinePage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    '绘制大地曲线',
    pageBuilder: GeodesicPolylinePage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    '绘制弧线',
    pageBuilder: ArcPolylinePage.new,
    isCompleted: true,
  ),
  Map3dItemData('NavigateArrowICircles功能'),
  Map3dItemData('Polygons功能'),
  Map3dItemData('热力图功能'),
  Map3dItemData('GroundOverlay功能'),
  Map3dItemData('Opengl接口功能'),
  Map3dItemData('自定义建筑物'),
  Map3dItemData('海量点功能'),
  Map3dItemData('绘制空心多边形功能'),
  Map3dItemData('显示单个省份地图'),
  Map3dItemData('粒子效果'),
  Map3dItemData('粒子效果+天气示例'),
  Map3dItemData('蜂窝热力图'),
]);
