import '../menu_models.dart';
import 'map_listview.dart';
import 'show_map.dart';
import 'two_map.dart';

const createMapCategory = Map3dCategoryData('创建地图', [
  Map3dItemData(
    '显示地图',
    pageBuilder: ShowMapPage.new,
    isCompleted: true,
  ),
  Map3dItemData(
    '地图ListView',
    pageBuilder: MapListViewPage.new,
    isCompleted: true,
  ),
  Map3dItemData('地图Recycle'),
  Map3dItemData('显示地图(6种实现地图的方式)'),
  Map3dItemData('ViewPager TextureMapView'),
  Map3dItemData(
    '地图多实例',
    pageBuilder: TwoMapPage.new,
    isCompleted: true,
  ),
  Map3dItemData('室内地图功能'),
  Map3dItemData('AMapOptions实现地图'),
]);
