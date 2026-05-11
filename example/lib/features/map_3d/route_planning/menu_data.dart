import '../../navigation/navigation.dart';
import '../menu_models.dart';
import 'map_view.dart';

const routePlanningCategory = Map3dCategoryData('出行路线规划', [
  Map3dItemData(
    '驾车路径规划',
    pageBuilder: NavigationPage.new,
    isCompleted: true,
  ),
  Map3dItemData('驾车未来路径规划'),
  Map3dItemData('步行路径规划'),
  Map3dItemData('公交路径规划'),
  Map3dItemData('骑行路径规划'),
  Map3dItemData('货车路径规划'),
  Map3dItemData(
    '距离测量',
    pageBuilder: MapViewPage.new,
    isCompleted: true,
  ),
  Map3dItemData('Route路径规划'),
]);
