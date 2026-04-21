import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils.dart';

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

  bool _showPanel = false;

  void _showOptions() {
    setState(() {
      _showPanel = !_showPanel;
    });
  }

  Widget _buildOptionsContent() {
    void bump(String key, UIControlPosition next) {
      setState(() => _positions[key] = next);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 48), // Placeholder to center text
              Text(
                '控件显示位置',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              IconButton(
                onPressed: () => setState(() => _showPanel = false),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (PlatformUtil.isAndroid) ...[
                    _AndroidLogoSection(
                      position: _positions[logo]!,
                      onChanged: (p) => bump(logo, p),
                    ),
                    const SizedBox(height: 8),
                    _AndroidZoomSection(
                      position: _positions[zoom]!,
                      onChanged: (p) => bump(zoom, p),
                    ),
                    const SizedBox(height: 12),
                    _buildHelpText('说明：Android 仅支持设置 Logo 与缩放按钮的锚点。'),
                  ] else if (PlatformUtil.isIOS) ...[
                    _IosControlCard(
                      title: logo,
                      position: _positions[logo]!,
                      anchors: UIControlAnchor.values,
                      offsetEnabled: true,
                      onChanged: (p) => bump(logo, p),
                    ),
                    const SizedBox(height: 8),
                    _IosControlCard(
                      title: compass,
                      position: _positions[compass]!,
                      anchors: UIControlAnchor.values,
                      offsetEnabled: true,
                      onChanged: (p) => bump(compass, p),
                    ),
                    const SizedBox(height: 8),
                    _IosControlCard(
                      title: scale,
                      position: _positions[scale]!,
                      anchors: UIControlAnchor.values,
                      offsetEnabled: true,
                      onChanged: (p) => bump(scale, p),
                    ),
                    const SizedBox(height: 8),
                    _buildHelpText('说明：iOS 端目前调整比例尺与指南针位置。'),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpText(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
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
      bottomNavigationBar: Material(
        elevation: 16,
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              alignment: Alignment.topCenter,
              child: _showPanel
                  ? _buildOptionsContent()
                  : const SizedBox(width: double.infinity, height: 0),
            ),
          ),
        ),
      ),
      body: AMapWidget(
        initCameraPosition: CameraPosition(
          position: Position(latitude: 39.984120, longitude: 116.307484),
          zoom: 17.2,
        ),
        scaleControlEnabled: true,
        zoomControlEnabled: true,
        compassControlEnabled: true,
        logoPosition: _positions[logo],
        scaleControlPosition: PlatformUtil.isIOS ? _positions[scale] : null,
        compassControlPosition: PlatformUtil.isIOS ? _positions[compass] : null,
        zoomControlPosition: PlatformUtil.isAndroid ? _positions[zoom] : null,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Text(
              'Logo 位置',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            SegmentedButton<UIControlAnchor>(
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              segments: _MapControlsPositionPageState.androidLogoAnchors
                  .map(
                    (a) => ButtonSegment<UIControlAnchor>(
                      value: a,
                      label: Text(_labels[a]!,
                          style: const TextStyle(fontSize: 12)),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Text(
              '缩放按钮',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            SegmentedButton<UIControlAnchor>(
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              segments: _MapControlsPositionPageState.androidZoomAnchors
                  .map(
                    (a) => ButtonSegment<UIControlAnchor>(
                      value: a,
                      label: Text(_labels[a]!,
                          style: const TextStyle(fontSize: 12)),
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

/// iOS：锚点 + 偏移
class _IosControlCard extends StatelessWidget {
  const _IosControlCard({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.place_outlined, size: 16, color: scheme.primary),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                DropdownButton<UIControlAnchor>(
                  value: position.anchor,
                  underline: const SizedBox(),
                  style: Theme.of(context).textTheme.bodySmall,
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
              ],
            ),
            if (offsetEnabled) ...[
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('偏移: ',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                  _CompactMiniTextField(
                    label: 'X',
                    initValue: position.offset.x.toStringAsFixed(0),
                    onChanged: (v) => onChanged(
                      position.copyWith(
                        offset: position.offset.copyWith(x: v),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CompactMiniTextField(
                    label: 'Y',
                    initValue: position.offset.y.toStringAsFixed(0),
                    onChanged: (v) => onChanged(
                      position.copyWith(
                        offset: position.offset.copyWith(y: v),
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

class _CompactMiniTextField extends StatelessWidget {
  const _CompactMiniTextField({
    required this.label,
    required this.initValue,
    required this.onChanged,
  });

  final String label;
  final String initValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: TextFormField(
        initialValue: initValue,
        onChanged: (value) {
          onChanged(value.isNotEmpty ? double.tryParse(value) ?? 0 : 0);
        },
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          prefixText: '$label: ',
          prefixStyle: const TextStyle(fontSize: 10, color: Colors.grey),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          border: const UnderlineInputBorder(),
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
