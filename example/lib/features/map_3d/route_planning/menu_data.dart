import '../menu_models.dart';
import 'distance_measure_page.dart';
import 'route_plan_page.dart';

const routePlanningCategory = Map3dCategoryData('出行路线规划', [
  Map3dItemData('驾车路径规划', pageBuilder: RoutePlanPage.drive, isCompleted: true),
  Map3dItemData('驾车未来路径规划'),
  Map3dItemData('步行路径规划', pageBuilder: RoutePlanPage.walk, isCompleted: true),
  Map3dItemData('公交路径规划'),
  Map3dItemData('骑行路径规划', pageBuilder: RoutePlanPage.ride, isCompleted: true),
  Map3dItemData('货车路径规划'),
  Map3dItemData(
    '距离测量',
    pageBuilder: DistanceMeasurePage.new,
    isCompleted: true,
  ),
  Map3dItemData('Route路径规划'),
]);
