import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'cruise_map_page.dart';
import 'navigation.dart';
import 'place_picker.dart';

// ──────────────────────────────────────────────────────────
//  数据模型
// ──────────────────────────────────────────────────────────

class _ItemData {
  final String title;
  final Widget Function()? pageBuilder;
  final bool isCompleted;
  final bool mobileOnly;

  const _ItemData(
    this.title, {
    this.pageBuilder,
    this.isCompleted = false,
    this.mobileOnly = false,
  });

  bool get isAvailable {
    if (!isCompleted) return false;
    if (mobileOnly && kIsWeb) return false;
    return pageBuilder != null;
  }
}

class _CategoryData {
  final String title;
  final List<_ItemData> items;

  const _CategoryData(this.title, this.items);
}

// ──────────────────────────────────────────────────────────
//  菜单数据源（对齐导航 SDK 8.0.0 文档目录；综合能力见「组件直接导航」）
// ──────────────────────────────────────────────────────────

final List<_CategoryData> _menuData = [
  _CategoryData('导航组件(新)', [
    _ItemData('起终点算路'),
    _ItemData('无起点算路'),
    _ItemData('途经点算路'),
    _ItemData('组件直接导航',
        pageBuilder: () => const NavigationPage(),
        isCompleted: true,
        mobileOnly: true),
    _ItemData('自定义 Activity 的导航组件（Android 原生容器）'),
    _ItemData('选取地点 (POI)（示例）',
        pageBuilder: () => const PlacePickerPage(),
        isCompleted: true,
        mobileOnly: true),
  ]),
  _CategoryData('路径规划', [
    _ItemData('驾车路径规划'),
    _ItemData('步行路径规划'),
    _ItemData('骑行路径规划'),
    _ItemData('货车导航路径规划'),
    _ItemData('独立路径规划'),
  ]),
  _CategoryData('多类型导航', [
    _ItemData('内置语音导航'),
    _ItemData('实时导航'),
    _ItemData('模拟导航'),
    _ItemData('货车导航'),
    _ItemData('智能巡航',
        pageBuilder: () => const CruiseMapPage(),
        isCompleted: true,
        mobileOnly: true),

    _ItemData('HUD导航'),
  ]),
  _CategoryData('导航UI自定义', [
    _ItemData('自定义车标'),
    _ItemData('自定义路线UI'),
    _ItemData('自定义路线纹理'),
    _ItemData('自定义路口转向提示'),
    _ItemData('正北模式'),
    _ItemData('自定义全览模式'),
    _ItemData('自定义指南针'),
    _ItemData('自定义路况按钮'),
    _ItemData('自定义放大缩小按钮'),
    _ItemData('自定义路口放大图'),
    _ItemData('自定义导航光柱(new)'),
    _ItemData('自定义车道信息'),
  ]),
  _CategoryData('导航完全自定义示例', [
    _ItemData('自车改变位置和绘制路线示例'),
    _ItemData('路名、剩余距离、转向图标示例'),
    _ItemData('绘制导航路况条示例'),
    _ItemData('自定义车道信息示例'),
    _ItemData('路口放大图示例'),
    _ItemData('摄像头违章提醒示例'),
    _ItemData('各组件整合导航示例'),
  ]),
  _CategoryData('导航扩展', [
    _ItemData('传入GPS数据导航'),
    _ItemData('展示导航路径详情'),
    _ItemData('主辅路切换'),
    _ItemData('科大讯飞语音集成'),
  ]),
];

// ──────────────────────────────────────────────────────────
//  主页面
// ──────────────────────────────────────────────────────────

class NavigationIndexPage extends StatelessWidget {
  const NavigationIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('导航目录'),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: _menuData.length,
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
//  分类折叠块 — 独立 StatefulWidget，setState 仅重建自身
// ──────────────────────────────────────────────────────────

class _CategoryTile extends StatefulWidget {
  final _CategoryData category;

  const _CategoryTile({super.key, required this.category});

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool _isExpanded = false;

  late final List<Widget> _children = widget.category.items
      .map((item) => _FeatureItemTile(item: item))
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
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
//  功能项 — 独立 StatelessWidget
// ──────────────────────────────────────────────────────────

class _FeatureItemTile extends StatelessWidget {
  final _ItemData item;

  const _FeatureItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.only(left: 48, right: 16),
          title: Text(
            item.title,
            style: TextStyle(
              fontSize: 15,
              color: item.isAvailable ? Colors.black87 : Colors.black45,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.mobileOnly)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '仅移动端',
                    style: TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ),
              if (!item.isCompleted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '开发中',
                    style: TextStyle(fontSize: 10, color: Colors.orange),
                  ),
                )
              else
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
          onTap: () => _handleTap(context),
        ),
        const Divider(
            height: 1, indent: 48, endIndent: 16, color: Colors.black12),
      ],
    );
  }

  void _handleTap(BuildContext context) {
    if (item.isAvailable && item.pageBuilder != null) {
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (_) => item.pageBuilder!()),
      );
    } else if (!item.isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('「${item.title}」功能正在开发中，敬请期待！'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (item.mobileOnly && kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('此功能仅在移动端可用'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
