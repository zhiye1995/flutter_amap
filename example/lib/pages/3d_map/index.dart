import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'add_remove_marker.dart';
import 'map_controls.dart';
import 'map_controls_position.dart';
import 'map_events.dart';
import 'map_restriction.dart';
import 'map_setting.dart';
import 'map_listview.dart';
import 'two_map.dart';
import 'map_view.dart';
import 'show_map.dart';
import 'user_location.dart';
import 'weather.dart';
import 'poi_click.dart';
import '../navigation/navigation.dart';
import '../navigation/place_picker.dart';

// ──────────────────────────────────────────────────────────
//  数据模型（纯数据，不持有 Widget 引用以优化 const 构造）
// ──────────────────────────────────────────────────────────

class _ItemData {
  final String title;
  final Widget Function()? pageBuilder;
  final bool isCompleted;

  const _ItemData(this.title, {this.pageBuilder, this.isCompleted = false});
}

class _CategoryData {
  final String title;
  final List<_ItemData> items;

  const _CategoryData(this.title, this.items);
}

// ──────────────────────────────────────────────────────────
//  菜单数据源（使用 pageBuilder 延迟创建目标页面，避免顶层 const
//  对 Widget 实例的持有导致不必要的内存占用）
// ──────────────────────────────────────────────────────────

final List<_CategoryData> _menuData = [
  _CategoryData('创建地图', [
    _ItemData('显示地图', pageBuilder: () => const ShowMapPage(), isCompleted: true),
    _ItemData('地图ListView', pageBuilder: () => const MapListViewPage(), isCompleted: true),
    _ItemData('地图Recycle'),
    _ItemData('显示地图(6种实现地图的方式)'),
    _ItemData('ViewPager TextureMapView'),
    _ItemData('地图多实例', pageBuilder: () => const TwoMapPage(), isCompleted: true),
    _ItemData('室内地图功能'),
    _ItemData('AMapOptions实现地图'),
  ]),
  _CategoryData('地图交互', [
    _ItemData('UI Settings功能', pageBuilder: () => const MapControlsPage(), isCompleted: true),
    _ItemData('地图Logo位置', pageBuilder: () => const MapControlsPositionPage(), isCompleted: true),
    _ItemData('Layers图层功能'),
    _ItemData('手势交互', pageBuilder: () => const MapSettingPage(), isCompleted: true),
    
    _ItemData('Events功能', pageBuilder: () => const MapEventsPage(), isCompleted: true),
    _ItemData('地图Poi点击功能', pageBuilder: () => const PoiClickPage(), isCompleted: true),
    _ItemData('改变地图中心点', pageBuilder: () => const MapViewPage(), isCompleted: true),
    _ItemData('地图动画效果'),
    _ItemData('自定义缩放', pageBuilder: () => const MapViewPage(), isCompleted: true),
    _ItemData('地图截屏功能', pageBuilder: () => const MapEventsPage(), isCompleted: true),
    _ItemData('限制缩放级别功能', pageBuilder: () => const MapRestrictionPage(), isCompleted: true),
    _ItemData('限制显示区域功能', pageBuilder: () => const MapRestrictionPage(), isCompleted: true),
  ]),
  _CategoryData('地图上绘制', [
    _ItemData('Markers功能', pageBuilder: () => const AddRemoveMarkerPage(), isCompleted: true),
    _ItemData('Marker点击回调'),
    _ItemData('Marker动画功能'),
    _ItemData('InfoWindow功能'),
    _ItemData('自定义Marker'),
    _ItemData('Location几种模式', pageBuilder: () => const UserLocationPage(), isCompleted: true),
    _ItemData('Location小蓝点自定义功能'),
    _ItemData('Location小蓝点自定义模式'),
    _ItemData('Polylines功能', pageBuilder: () => const MapEventsPage(), isCompleted: true),
    _ItemData('绘制多彩线'),
    _ItemData('绘制大地曲线'),
    _ItemData('绘制弧线'),
    _ItemData('NavigateArrowICircles功能'),
    _ItemData('Polygons功能'),
    _ItemData('热力图功能'),
    _ItemData('GroundOverlay功能'),
    _ItemData('Opengl接口功能'),
    _ItemData('自定义建筑物'),
    _ItemData('海量点功能'),
    _ItemData('绘制空心多边形功能'),
    _ItemData('显示单个省份地图'),
    _ItemData('粒子效果'),
    _ItemData('粒子效果+天气示例'),
    _ItemData('蜂窝热力图'),
  ]),
  _CategoryData('查询地图数据', [
    _ItemData('poi关键字搜索', pageBuilder: () => const PlacePickerPage(), isCompleted: true),
    _ItemData('poi周边搜索'),
    _ItemData('poilD搜索功能'),
    _ItemData('沿途搜索'),
    _ItemData('输入提示'),
    _ItemData('POI父子关系'),
    _ItemData('天气查询', pageBuilder: () => const WeatherPage(), isCompleted: true),
    _ItemData('地理编码功能'),
    _ItemData('逆地理编码功能'),
    _ItemData('行政区划查询'),
    _ItemData('行政区划边界查询'),
    _ItemData('Busline公交查询'),
    _ItemData('公交站点查询'),
    _ItemData('云图检素'),
  ]),
  _CategoryData('出行路线规划', [
    _ItemData('驾车路径规划', pageBuilder: () => const NavigationPage(), isCompleted: true),
    _ItemData('驾车未来路径规划'),
    _ItemData('步行路径规划'),
    _ItemData('公交路径规划'),
    _ItemData('骑行路径规划'),
    _ItemData('货车路径规划'),
    _ItemData('距离测量', pageBuilder: () => const MapViewPage(), isCompleted: true),
    _ItemData('Route路径规划'),
  ]),
  _CategoryData('短串分享', [
    _ItemData('短串分享'),
  ]),
  _CategoryData('离线地图', [
    _ItemData('离线地图功能(已过时)', pageBuilder: () => const MapSettingPage(), isCompleted: true),
    _ItemData('离线地图功能(组件包含UI)'),
  ]),
  _CategoryData('地图计算工具', [
    _ItemData('坐标系转换', pageBuilder: () => const MapViewPage(), isCompleted: true),
    _ItemData('经纬度转屏幕像素'),
    _ItemData('两点间距离', pageBuilder: () => const MapViewPage(), isCompleted: true),
    _ItemData('点是否在多边形内'),
  ]),
  _CategoryData('扩展功能', [
    _ItemData('轨迹纠偏功能'),
    _ItemData('轨迹纠偏功能_便捷版'),
    _ItemData('平滑移动'),
  ]),
];

// ──────────────────────────────────────────────────────────
//  主页面 — 使用 StatelessWidget，不在这层管理状态
// ──────────────────────────────────────────────────────────

class Map3dIndexPage extends StatelessWidget {
  const Map3dIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D地图目录'),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      // ListView.builder 按需构建，仅渲染可见区域
      body: ListView.builder(
        itemCount: _menuData.length,
        // 每个分类作为一个独立的 StatefulWidget，
        // 折叠 / 展开只重建自身，不会触发整个列表重建
        itemBuilder: (context, index) {
          return _CategoryTile(
            key: ValueKey(index),
            category: _menuData[index],
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
//  单个分类折叠块 — 独立的 StatefulWidget
//  核心优化：setState 的作用域被限制在这一个分类内部，
//  展开 / 折叠不会导致其它分类重建。
// ──────────────────────────────────────────────────────────

class _CategoryTile extends StatefulWidget {
  final _CategoryData category;

  const _CategoryTile({super.key, required this.category});

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool _isExpanded = false;

  // 预构建子项列表，避免每次 build 都重新 .map().toList()
  late final List<Widget> _children = _buildChildren();

  List<Widget> _buildChildren() {
    return widget.category.items.map((item) {
      return _FeatureItemTile(item: item);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary 将本分类块的绘制与其他分隔开，
    // 减少展开 / 折叠时的重绘范围
    return RepaintBoundary(
      child: Theme(
        // 只创建一次，隐藏 ExpansionTile 自带的分割线
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          backgroundColor: Colors.white,
          collapsedBackgroundColor: const Color(0xFFF5F5F5),
          title: Text(
            widget.category.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          children: _children,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
//  单个功能项 — 无状态、轻量级的独立 Widget
//  优化：从 .map() 闭包中提取为独立组件，
//  Flutter 框架能更高效地进行 diff 比较和复用。
// ──────────────────────────────────────────────────────────

class _FeatureItemTile extends StatelessWidget {
  final _ItemData item;

  const _FeatureItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 48, right: 16),
      title: Text(
        item.title,
        style: TextStyle(
          fontSize: 13,
          color: item.isCompleted ? Colors.black87 : Colors.black45,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: () => _handleTap(context),
    );
  }

  void _handleTap(BuildContext context) {
    if (item.isCompleted && item.pageBuilder != null) {
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (_) => item.pageBuilder!()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('「${item.title}」功能正在开发中，敬请期待！'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
