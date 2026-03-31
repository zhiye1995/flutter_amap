import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
//  菜单数据源
// ──────────────────────────────────────────────────────────

final List<_CategoryData> _menuData = [
  _CategoryData('导航组件', [
    _ItemData('使用导航组件',
        pageBuilder: () => const NavigationPage(),
        isCompleted: true,
        mobileOnly: true),
  ]),
  _CategoryData('出行路线规划', [
    _ItemData('驾车路线规划'),
    _ItemData('货车路线规划'),
    _ItemData('步行路线规划'),
    _ItemData('骑行路线规划'),
  ]),
  _CategoryData('在地图上导航', [
    _ItemData('实时导航'),
    _ItemData('模拟导航'),
    _ItemData('智能巡航'),
    _ItemData('传入外部GPS数据'),
    _ItemData('导航UI定制化'),
  ]),
  _CategoryData('HUD导航模式', [
    _ItemData('HUD导航'),
  ]),
  _CategoryData('获取导航数据', [
    _ItemData('导航数据'),
  ]),
  _CategoryData('语音播报', [
    _ItemData('语音合成'),
  ]),
  _CategoryData('位置选择', [
    _ItemData('选取地点 (POI)',
        pageBuilder: () => const PlacePickerPage(),
        isCompleted: true,
        mobileOnly: true),
  ]),
  _CategoryData('线路规划 (旧版)', [
    _ItemData('驾车路线规划',
        pageBuilder: () => const NavigationPage(),
        isCompleted: true,
        mobileOnly: true),
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
