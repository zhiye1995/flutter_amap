import 'package:flutter/material.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';

/// 地点选择示例页面
class PlacePickerPage extends StatefulWidget {
  const PlacePickerPage({super.key});

  static const title = '地点选择';

  @override
  State<PlacePickerPage> createState() => _PlacePickerPageState();
}

class _PlacePickerPageState extends State<PlacePickerPage> {
  PoiItem? _homeAddress;
  PoiItem? _companyAddress;
  LocationPickerResult? _routeLocation;

  Future<void> _selectHomeAddress() async {
    final result = await AMapMapPlacePicker.show(
      context,
      config: const MapPlacePickerConfig(title: '选择家庭地址', hintText: '搜索小区、街道等'),
    );

    if (result != null) {
      setState(() {
        _homeAddress = result;
      });
    }
  }

  Future<void> _selectCompanyAddress() async {
    final result = await AMapMapPlacePicker.show(
      context,
      config: const MapPlacePickerConfig(
        title: '选择公司地址',
        hintText: '搜索公司、写字楼等',
      ),
    );

    if (result != null) {
      setState(() {
        _companyAddress = result;
      });
    }
  }

  Future<void> _searchWithCity() async {
    final result = await AMapMapPlacePicker.show(
      context,
      config: const MapPlacePickerConfig(
        title: '城市限定搜索',
        hintText: '仅搜索北京市',
        city: '北京',
      ),
    );

    if (result != null && mounted) {
      LoadingUtil.showToast('选中: ${result.name}');
    }
  }

  Future<void> _selectRouteLocation() async {
    final result = await AMapLocationPicker.show(
      context,
      config: const LocationPickerConfig(
        title: '选择路线位置',
        hintText: '搜索地点、公交站、商圈',
        initialKeyword: '北京',
        includeCurrentLocation: true,
      ),
    );

    if (result != null && mounted) {
      setState(() => _routeLocation = result);
      final routePoint = result.toRoutePoint();
      LoadingUtil.showToast('选中: ${routePoint.name ?? result.address ?? '坐标'}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text(PlacePickerPage.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 家庭地址卡片
          _AddressCard(
            icon: Icons.home,
            iconColor: Colors.orange,
            title: '家庭地址',
            address: _homeAddress,
            onTap: _selectHomeAddress,
          ),

          const SizedBox(height: 16),

          // 公司地址卡片
          _AddressCard(
            icon: Icons.business,
            iconColor: Colors.blue,
            title: '公司地址',
            address: _companyAddress,
            onTap: _selectCompanyAddress,
          ),

          const SizedBox(height: 32),

          // 功能说明
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '功能说明',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• 支持地图显示当前定位\n'
                  '• 自动搜索周边 POI 信息\n'
                  '• 支持关键词搜索\n'
                  '• 点击选择后在地图上显示标记\n'
                  '• 确认后返回地点名称、地址、坐标等信息',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 更多示例按钮
          FilledButton.tonal(
            onPressed: _searchWithCity,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_city, size: 18),
                SizedBox(width: 8),
                Text('城市限定搜索示例'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          FilledButton.tonalIcon(
            onPressed: _selectRouteLocation,
            icon: const Icon(Icons.route, size: 18),
            label: const Text('通用位置选择器（路线起终点）'),
          ),

          if (_routeLocation != null) ...[
            const SizedBox(height: 8),
            _LocationResultCard(result: _routeLocation!),
          ],

          const SizedBox(height: 16),

          // 直接调用 API 示例
          OutlinedButton(
            onPressed: _testSearchApi,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.code, size: 18),
                SizedBox(width: 8),
                Text('直接调用搜索 API'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 旧版底部弹窗选择器
          OutlinedButton(
            onPressed: _showOldPicker,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_alt, size: 18),
                SizedBox(width: 8),
                Text('旧版底部弹窗选择器'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testSearchApi() async {
    try {
      // 显示加载
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 直接调用搜索 API
      List<InputTip> tips = await AMapSearch.requestInputTips(
        keywords: '天安门',
        city: '北京',
        cityLimit: true,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // 关闭加载

      // 显示结果
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('搜索结果'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: tips.length.clamp(0, 5),
              itemBuilder: (context, index) {
                final tip = tips[index];
                return ListTile(
                  title: Text(tip.name),
                  subtitle: Text(
                    tip.address ?? tip.district ?? '无地址',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  dense: true,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // 关闭加载

      LoadingUtil.showError('搜索失败: $e');
    }
  }

  Future<void> _showOldPicker() async {
    final result = await AMapPlacePicker.show(
      context,
      config: const PlacePickerConfig(title: '选择地点', hintText: '搜索地点'),
    );

    if (result != null && mounted) {
      LoadingUtil.showToast('选中: ${result.name}');
    }
  }
}

class _LocationResultCard extends StatelessWidget {
  const _LocationResultCard({required this.result});

  final LocationPickerResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.name ?? '已选择位置',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (result.address != null) ...[
              const SizedBox(height: 4),
              Text(
                result.address!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              '坐标: ${result.position.latitude.toStringAsFixed(6)}, ${result.position.longitude.toStringAsFixed(6)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 地址卡片组件
class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.address,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final PoiItem? address;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),

              const SizedBox(width: 16),

              // 内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (address != null) ...[
                      Text(
                        address!.name,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (address!.address != null ||
                          address!.adName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          address!.address ?? address!.adName ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        '坐标: ${address!.position.latitude.toStringAsFixed(6)}, ${address!.position.longitude.toStringAsFixed(6)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary.withOpacity(0.8),
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ] else
                      Text(
                        '点击选择地址',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                  ],
                ),
              ),

              // 箭头
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
