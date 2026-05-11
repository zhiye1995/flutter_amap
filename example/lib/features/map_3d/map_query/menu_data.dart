import '../../navigation/place_picker.dart';
import '../menu_models.dart';
import 'poi_keyword_search.dart';
import 'weather.dart';

const mapQueryCategory = Map3dCategoryData('查询地图数据', [
  Map3dItemData(
    'poi关键字搜索',
    pageBuilder: PoiKeywordSearchPage.new,
    isCompleted: true,
  ),
  Map3dItemData('poi周边搜索'),
  Map3dItemData('poilD搜索功能'),
  Map3dItemData('沿途搜索'),
  Map3dItemData('输入提示'),
  Map3dItemData('POI父子关系'),
  Map3dItemData(
    '天气查询',
    pageBuilder: WeatherPage.new,
    isCompleted: true,
  ),
  Map3dItemData('地理编码功能'),
  Map3dItemData('逆地理编码功能'),
  Map3dItemData('行政区划查询'),
  Map3dItemData('行政区划边界查询'),
  Map3dItemData('Busline公交查询'),
  Map3dItemData('公交站点查询'),
  Map3dItemData('云图检素'),
]);
