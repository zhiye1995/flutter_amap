import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils.dart';

/// 地图控件位置设置页面。
///
/// Android 与官方 3D Demo 一致：仅 **Logo**（左下 / 底部中央 / 右下）与 **缩放按钮**
///（右侧居中 / 右下角）可设锚点，对应 `AMapOptions` 的 Logo / Zoom 位置常量。
/// 比例尺、指南针在 Android 原生 SDK 中无独立位置接口，故本页不展示对应项。
class MapControlsPositionPage extends StatefulWidget {
  /// 地图控件位置设置页面构造函数
  const MapControlsPositionPage({super.key});

  /// 地图控件位置设置页面标题
  static const title = '地图控件位置';

  @override
  State<MapControlsPositionPage> createState() =>
      _MapControlsPositionPageState();
}

class _MapControlsPositionPageState extends State<MapControlsPositionPage> {
  static const logo = 'Logo';
  static const scale = '比例尺';
  static const compass = '指南针';
  static const zoom = '缩放按钮';

  /// Android：与 [UIControlAnchor.toLogoPosition] / [UIControlAnchor.toZoomPosition] 一致
  static const androidLogoAnchors = <UIControlAnchor>[
    UIControlAnchor.bottomLeft,
    UIControlAnchor.bottomCenter,
    UIControlAnchor.bottomRight,
  ];

  static const androidZoomAnchors = <UIControlAnchor>[
    UIControlAnchor.centerRight,
    UIControlAnchor.bottomRight,
  ];

  final Map<String, UIControlPosition> _positions = {
    logo: UIControlPosition(
      anchor: UIControlAnchor.bottomLeft,
      offset: UIControlOffset(x: 0, y: 0),
    ),
    scale: UIControlPosition(
      anchor: UIControlAnchor.bottomLeft,
      offset: UIControlOffset(x: 10, y: 10),
    ),
    compass: UIControlPosition(
      anchor: UIControlAnchor.topRight,
      offset: UIControlOffset(x: 10, y: 10),
    ),
    zoom: UIControlPosition(
      anchor: UIControlAnchor.bottomRight,
      offset: UIControlOffset(x: 10, y: 10),
    ),
  };

  void _showOptions() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter sheetSetState) {
            final media = MediaQuery.of(context);
            final maxH = media.size.height * 0.62;

            void bump(String key, UIControlPosition next) {
              sheetSetState(() => _positions[key] = next);
              setState(() => _positions[key] = next);
            }

            return Padding(
              padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                      child: Text(
                        '控件显示位置',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (PlatformUtil.isAndroid) ...[
                              _AndroidLogoSection(
                                position: _positions[logo]!,
                                onChanged: (p) => bump(logo, p),
                              ),
                              const SizedBox(height: 16),
                              _AndroidZoomSection(
                                position: _positions[zoom]!,
                                onChanged: (p) => bump(zoom, p),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '说明：Android 高德地图 SDK 仅支持设置 Logo 与缩放按钮的锚点位置；'
                                '比例尺、指南针为系统默认布局，本页不提供位置项。',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ] else if (PlatformUtil.isIOS) ...[
                              _IosWebControlCard(
                                title: logo,
                                position: _positions[logo]!,
                                anchors: UIControlAnchor.values,
                                offsetEnabled: true,
                                onChanged: (p) => bump(logo, p),
                              ),
                              const SizedBox(height: 12),
                              _IosWebControlCard(
                                title: compass,
                                position: _positions[compass]!,
                                anchors: UIControlAnchor.values,
                                offsetEnabled: true,
                                onChanged: (p) => bump(compass, p),
                              ),
                              const SizedBox(height: 12),
                              _IosWebControlCard(
                                title: scale,
                                position: _positions[scale]!,
                                anchors: UIControlAnchor.values,
                                offsetEnabled: true,
                                onChanged: (p) => bump(scale, p),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '说明：iOS 端暂不在原生层应用缩放按钮位置，此处仅调整比例尺与指南针。',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ] else if (kIsWeb) ...[
                              _IosWebControlCard(
                                title: scale,
                                position: _positions[scale]!,
                                anchors: const [
                                  UIControlAnchor.topLeft,
                                  UIControlAnchor.topRight,
                                  UIControlAnchor.bottomLeft,
                                  UIControlAnchor.bottomRight,
                                ],
                                offsetEnabled: true,
                                onChanged: (p) => bump(scale, p),
                              ),
                              const SizedBox(height: 12),
                              _IosWebControlCard(
                                title: compass,
                                position: _positions[compass]!,
                                anchors: const [
                                  UIControlAnchor.topLeft,
                                  UIControlAnchor.topRight,
                                  UIControlAnchor.bottomLeft,
                                  UIControlAnchor.bottomRight,
                                ],
                                offsetEnabled: true,
                                onChanged: (p) => bump(compass, p),
                              ),
                              const SizedBox(height: 12),
                              _IosWebControlCard(
                                title: zoom,
                                position: _positions[zoom]!,
                                anchors: const [
                                  UIControlAnchor.topLeft,
                                  UIControlAnchor.topRight,
                                  UIControlAnchor.bottomLeft,
                                  UIControlAnchor.bottomRight,
                                ],
                                offsetEnabled: true,
                                onChanged: (p) => bump(zoom, p),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('完成'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(MapControlsPositionPage.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: '控件显示位置',
            onPressed: _showOptions,
          ),
        ],
      ),
      body: AMapWidget(
        initCameraPosition: CameraPosition(
          position: Position(latitude: 39.984120, longitude: 116.307484),
          zoom: 17.2,
        ),
        scaleControlEnabled: true,
        zoomControlEnabled: true,
        compassControlEnabled: true,
        logoPosition: !kIsWeb ? _positions[logo] : null,
        scaleControlPosition:
            (PlatformUtil.isIOS || kIsWeb) ? _positions[scale] : null,
        compassControlPosition:
            (PlatformUtil.isIOS || kIsWeb) ? _positions[compass] : null,
        zoomControlPosition:
            (PlatformUtil.isAndroid || kIsWeb) ? _positions[zoom] : null,
      ),
    );
  }
}

/// Android：Logo — 与 AMapOptions.LOGO_POSITION_* 一致
class _AndroidLogoSection extends StatelessWidget {
  const _AndroidLogoSection({
    required this.position,
    required this.onChanged,
  });

  final UIControlPosition position;
  final ValueChanged<UIControlPosition> onChanged;

  static const _labels = {
    UIControlAnchor.bottomLeft: '左下角',
    UIControlAnchor.bottomCenter: '底部中央',
    UIControlAnchor.bottomRight: '右下角',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Logo 位置',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<UIControlAnchor>(
              showSelectedIcon: false,
              segments: _MapControlsPositionPageState.androidLogoAnchors
                  .map(
                    (a) => ButtonSegment<UIControlAnchor>(
                      value: a,
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(_labels[a]!, textAlign: TextAlign.center),
                      ),
                    ),
                  )
                  .toList(),
              selected: {position.anchor},
              onSelectionChanged: (Set<UIControlAnchor> next) {
                final a = next.first;
                onChanged(position.copyWith(anchor: a));
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Android：缩放 — 与 AMapOptions.ZOOM_POSITION_* 一致
class _AndroidZoomSection extends StatelessWidget {
  const _AndroidZoomSection({
    required this.position,
    required this.onChanged,
  });

  final UIControlPosition position;
  final ValueChanged<UIControlPosition> onChanged;

  static const _labels = {
    UIControlAnchor.centerRight: '右侧居中',
    UIControlAnchor.bottomRight: '右下角',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '缩放按钮位置',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<UIControlAnchor>(
              showSelectedIcon: false,
              segments: _MapControlsPositionPageState.androidZoomAnchors
                  .map(
                    (a) => ButtonSegment<UIControlAnchor>(
                      value: a,
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(_labels[a]!),
                      ),
                    ),
                  )
                  .toList(),
              selected: {position.anchor},
              onSelectionChanged: (Set<UIControlAnchor> next) {
                final a = next.first;
                onChanged(position.copyWith(anchor: a));
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// iOS / Web：锚点 + 偏移
class _IosWebControlCard extends StatelessWidget {
  const _IosWebControlCard({
    required this.title,
    required this.position,
    required this.anchors,
    required this.offsetEnabled,
    required this.onChanged,
  });

  final String title;
  final UIControlPosition position;
  final List<UIControlAnchor> anchors;
  final bool offsetEnabled;
  final ValueChanged<UIControlPosition> onChanged;

  static const _anchorLabels = {
    UIControlAnchor.topLeft: '左上角',
    UIControlAnchor.topCenter: '顶部',
    UIControlAnchor.topRight: '右上角',
    UIControlAnchor.centerLeft: '左侧',
    UIControlAnchor.center: '中心',
    UIControlAnchor.centerRight: '右侧',
    UIControlAnchor.bottomLeft: '左下角',
    UIControlAnchor.bottomCenter: '底部',
    UIControlAnchor.bottomRight: '右下角',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.place_outlined, size: 20, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<UIControlAnchor>(
              key: ValueKey('$title-${position.anchor}'),
              initialValue: position.anchor,
              decoration: InputDecoration(
                labelText: '锚点',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: anchors.map((a) {
                return DropdownMenuItem(
                  value: a,
                  child: Text(_anchorLabels[a]!),
                );
              }).toList(),
              onChanged: (a) {
                if (a != null) onChanged(position.copyWith(anchor: a));
              },
            ),
            if (offsetEnabled) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MiniTextField(
                      label: 'X',
                      initValue: position.offset.x.toStringAsFixed(0),
                      onChanged: (v) => onChanged(
                        position.copyWith(
                          offset: position.offset.copyWith(x: v),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniTextField(
                      label: 'Y',
                      initValue: position.offset.y.toStringAsFixed(0),
                      onChanged: (v) => onChanged(
                        position.copyWith(
                          offset: position.offset.copyWith(y: v),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniTextField extends StatelessWidget {
  const _MiniTextField({
    required this.label,
    required this.initValue,
    required this.onChanged,
  });

  final String label;
  final String initValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initValue,
      onChanged: (value) {
        onChanged(value.isNotEmpty ? double.tryParse(value) ?? 0 : 0);
      },
      keyboardType: TextInputType.number,
      inputFormatters: [
        LengthLimitingTextInputFormatter(5),
        FilteringTextInputFormatter.allow(RegExp(r'-?[0-9]*')),
      ],
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
