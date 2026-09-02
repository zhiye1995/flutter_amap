import UIKit
import AMapNaviKit

/// 导航类型枚举
enum AMapNaviType: Int {
    case driver = 0
    case walk = 1
    case ride = 2
}

/// 导航页面类型枚举
enum AMapNaviPageType: Int {
    case route = 0  // 路线规划页
    case navi = 1   // 导航页
}

// 注意：AMapNaviViewController 已不再需要
// 现在直接通过 AMapNaviApi 使用 AMapNaviCompositeManager 来展示原生导航界面
// AMapNaviCompositeManager 会自动管理所有视图的展示和退出
