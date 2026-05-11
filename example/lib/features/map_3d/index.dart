import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';
import 'create_map/menu_data.dart';
import 'extensions/menu_data.dart';
import 'map_interaction/menu_data.dart';
import 'map_overlay/menu_data.dart';
import 'map_query/menu_data.dart';
import 'map_tools/menu_data.dart';
import 'menu_models.dart';
import 'offline_map/menu_data.dart';
import 'route_planning/menu_data.dart';
import 'short_link/menu_data.dart';

// ──────────────────────────────────────────────────────────
//  菜单数据源（使用 pageBuilder 延迟创建目标页面，避免顶层 const
//  对 Widget 实例的持有导致不必要的内存占用）
// ──────────────────────────────────────────────────────────

const List<Map3dCategoryData> _menuData = [
  /// 创建地图
  createMapCategory,
  /// 地图交互
  mapInteractionCategory,
  /// 地图上绘制
  mapOverlayCategory,
  /// 查询地图数据
  mapQueryCategory,
  /// 出行路线规划
  routePlanningCategory,
  /// 短串分享
  shortLinkCategory,
  /// 离线地图
  offlineMapCategory,
  /// 地图计算工具
  mapToolsCategory,
  /// 扩展功能
  extensionsCategory,
];

// ──────────────────────────────────────────────────────────
//  主页面 — 统一管理当前展开的分类，保证同一时间只展开一个
// ──────────────────────────────────────────────────────────

class Map3dIndexPage extends StatefulWidget {
  const Map3dIndexPage({super.key});

  @override
  State<Map3dIndexPage> createState() => _Map3dIndexPageState();
}

class _Map3dIndexPageState extends State<Map3dIndexPage> {
  int? _expandedCategoryIndex;

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
        itemBuilder: (context, index) {
          return _CategoryTile(
            key: ValueKey(index),
            category: _menuData[index],
            isExpanded: _expandedCategoryIndex == index,
            onExpansionChanged: (expanded) {
              setState(() {
                _expandedCategoryIndex = expanded ? index : null;
              });
            },
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
//  单个分类折叠块
// ──────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final Map3dCategoryData category;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;

  const _CategoryTile({
    super.key,
    required this.category,
    required this.isExpanded,
    required this.onExpansionChanged,
  });

  List<Widget> _buildChildren() {
    return category.items.map((item) {
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
          key: ValueKey(isExpanded),
          initiallyExpanded: isExpanded,
          onExpansionChanged: onExpansionChanged,
          backgroundColor: Colors.white,
          collapsedBackgroundColor: const Color(0xFFF5F5F5),
          title: Text(
            category.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          children: _buildChildren(),
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
  final Map3dItemData item;

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
      LoadingUtil.showToast('「${item.title}」功能正在开发中，敬请期待！');
    }
  }
}
