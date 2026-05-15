import '../menu_models.dart';
import 'smooth_move_page.dart';

const extensionsCategory = Map3dCategoryData('扩展功能', [
  Map3dItemData('轨迹纠偏功能'),
  Map3dItemData('轨迹纠偏功能_便捷版'),
  Map3dItemData('平滑移动', pageBuilder: SmoothMovePage.new, isCompleted: true),
]);
