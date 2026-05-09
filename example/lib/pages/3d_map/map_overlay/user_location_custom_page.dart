import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amap/flutter_amap.dart' as amap;

/// 演示 Location 小蓝点自定义能力。
///
/// Android 主要对应高德 `MyLocationStyle`；iOS 主要对应 `MAUserLocationRepresentation`。
class UserLocationCustomPage extends StatefulWidget {
  const UserLocationCustomPage({super.key});

  static const title = 'Location小蓝点自定义功能';

  @override
  State<UserLocationCustomPage> createState() => _UserLocationCustomPageState();
}

class _UserLocationCustomPageState extends State<UserLocationCustomPage> {
  amap.AMapController? controller;
  amap.Location? _lastLocation;

  amap.UserLocationType _mode = amap.UserLocationType.locationTypeFollow;
  bool _useCustomIcon = false;
  bool _showLocationDot = true;
  bool _showsAccuracyRing = true;
  bool _showsHeadingIndicator = true;
  bool _enablePulseAnimation = true;
  double _anchorX = 0.5;
  double _anchorY = 0.5;
  double _lineWidth = 2;
  int _intervalMs = 1000;
  Color _accuracyFillColor = const Color(0x332196F3);
  Color _accuracyStrokeColor = const Color(0xFF1E88E5);
  Color _dotBgColor = const Color(0xFFFFFFFF);
  Color _dotFillColor = const Color(0xFF1E88E5);

  @override
  void dispose() {
    controller?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(UserLocationCustomPage.title),
        actions: [
          IconButton(
            tooltip: '回到当前位置',
            onPressed: controller == null ? null : _moveToCurrentLocation,
            icon: const Icon(Icons.my_location),
          ),
          IconButton(
            tooltip: '恢复默认',
            onPressed: _resetStyle,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: amap.AMapWidget(
              initCameraPosition: amap.CameraPosition(zoom: 16),
              showUserLocation: true,
              geolocationControlEnabled: true,
              userLocationStyle: _buildLocationStyle(),
              onUserLocationChange: (location) {
                _lastLocation = location;
              },
              onMapCreated: (c) {
                setState(() => controller = c);
              },
            ),
          ),
          _ControlPanel(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
              children: [
                _buildPlatformSummary(context),
                const SizedBox(height: 12),
                _buildModeSection(context),
                const SizedBox(height: 12),
                _buildCommonSection(context),
                const SizedBox(height: 12),
                _buildAccuracyRingSection(context),
                const SizedBox(height: 12),
                _buildAndroidSection(context),
                const SizedBox(height: 12),
                _buildIosSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  amap.UserLocationStyle _buildLocationStyle() {
    return amap.UserLocationStyle(
      userLocationType: _mode,
      fillColor: _accuracyFillColor,
      strokeColor: _accuracyStrokeColor,
      lineWidth: _lineWidth,
      image:
          _useCustomIcon ? amap.Bitmap(asset: 'assets/map-marker.png') : null,
      showLocationDot: _showLocationDot,
      anchor: amap.Anchor(x: _anchorX, y: _anchorY),
      showsAccuracyRing: _showsAccuracyRing,
      showsHeadingIndicator: _showsHeadingIndicator,
      locationDotBgColor: _dotBgColor,
      locationDotFillColor: _dotFillColor,
      enablePulseAnimation: _enablePulseAnimation,
      intervalMs: _intervalMs,
    );
  }

  Widget _buildPlatformSummary(BuildContext context) {
    final platform = defaultTargetPlatform.name;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('当前平台：$platform', style: textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          '公共能力：自定义图标、精度圈颜色、边线宽度。Android 额外支持小蓝点显隐、图标锚点、定位频次；iOS 额外支持精度圈开关、方向指示、圆点颜色、律动效果。',
          style: textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildModeSection(BuildContext context) {
    return _Section(
      title: '定位模式',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: amap.UserLocationType.values.map((type) {
            return ChoiceChip(
              label: Text(_modeTitle(type)),
              tooltip: type.platformAvailabilityLabel,
              selected: _mode == type,
              onSelected: (selected) {
                if (!selected) return;
                setState(() => _mode = type);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCommonSection(BuildContext context) {
    return _Section(
      title: '双端公共样式',
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('使用自定义定位图标'),
          subtitle: const Text('Android: myLocationIcon；iOS: image'),
          value: _useCustomIcon,
          onChanged: (value) => setState(() => _useCustomIcon = value),
        ),
        _ColorSelector(
          title: '精度圈填充色',
          value: _accuracyFillColor,
          colors: _accuracyFillColors,
          onChanged: (value) => setState(() => _accuracyFillColor = value),
        ),
        _ColorSelector(
          title: '精度圈边线色',
          value: _accuracyStrokeColor,
          colors: _strokeColors,
          onChanged: (value) => setState(() => _accuracyStrokeColor = value),
        ),
        _SliderRow(
          label: '精度圈边线宽度',
          valueText: _lineWidth.toStringAsFixed(1),
          value: _lineWidth,
          min: 0,
          max: 8,
          divisions: 16,
          onChanged: (value) => setState(() => _lineWidth = value),
        ),
      ],
    );
  }

  Widget _buildAndroidSection(BuildContext context) {
    return _Section(
      title: 'Android 专属',
      subtitle: '对应高德 MyLocationStyle；iOS 无完全等价 API。',
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('显示小蓝点'),
          subtitle: const Text('showMyLocation'),
          value: _showLocationDot,
          onChanged: (value) => setState(() => _showLocationDot = value),
        ),
        _SliderRow(
          label: '图标锚点 X',
          valueText: _anchorX.toStringAsFixed(2),
          value: _anchorX,
          min: 0,
          max: 1,
          divisions: 20,
          onChanged: (value) => setState(() => _anchorX = value),
        ),
        _SliderRow(
          label: '图标锚点 Y',
          valueText: _anchorY.toStringAsFixed(2),
          value: _anchorY,
          min: 0,
          max: 1,
          divisions: 20,
          onChanged: (value) => setState(() => _anchorY = value),
        ),
        _SliderRow(
          label: '连续定位频次',
          valueText: '${_intervalMs}ms',
          value: _intervalMs.toDouble(),
          min: 1000,
          max: 5000,
          divisions: 4,
          onChanged: (value) => setState(() => _intervalMs = value.round()),
        ),
      ],
    );
  }

  Widget _buildAccuracyRingSection(BuildContext context) {
    return _Section(
      title: '精度圈显示控制（iOS 原生 / Android 模拟）',
      subtitle: 'iOS 对应 showsAccuracyRing；Android 通过透明颜色和 0 线宽隐藏精度圈。',
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('显示精度圈'),
          value: _showsAccuracyRing,
          onChanged: (value) => setState(() => _showsAccuracyRing = value),
        ),
      ],
    );
  }

  Widget _buildIosSection(BuildContext context) {
    return _Section(
      title: 'iOS 专属',
      subtitle: '对应高德 MAUserLocationRepresentation；Android 无完全等价 API。',
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('显示方向指示'),
          subtitle: const Text('showsHeadingIndicator'),
          value: _showsHeadingIndicator,
          onChanged: (value) => setState(() => _showsHeadingIndicator = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('开启蓝点律动'),
          subtitle: const Text('enablePulseAnnimation'),
          value: _enablePulseAnimation,
          onChanged: (value) => setState(() => _enablePulseAnimation = value),
        ),
        _ColorSelector(
          title: '圆点背景色',
          value: _dotBgColor,
          colors: _dotBgColors,
          onChanged: (value) => setState(() => _dotBgColor = value),
        ),
        _ColorSelector(
          title: '圆点填充色',
          value: _dotFillColor,
          colors: _strokeColors,
          onChanged: (value) => setState(() => _dotFillColor = value),
        ),
      ],
    );
  }

  Future<void> _moveToCurrentLocation() async {
    try {
      final location = _lastLocation ??
          await controller!.waitForUserLocation(
            timeout: const Duration(seconds: 10),
          );
      await controller!.moveCamera(
        amap.CameraPosition(position: location.position, zoom: 16),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('定位获取失败：$e')),
      );
    }
  }

  void _resetStyle() {
    setState(() {
      _mode = amap.UserLocationType.locationTypeFollow;
      _useCustomIcon = false;
      _showLocationDot = true;
      _showsAccuracyRing = true;
      _showsHeadingIndicator = true;
      _enablePulseAnimation = true;
      _anchorX = 0.5;
      _anchorY = 0.5;
      _lineWidth = 2;
      _intervalMs = 1000;
      _accuracyFillColor = const Color(0x332196F3);
      _accuracyStrokeColor = const Color(0xFF1E88E5);
      _dotBgColor = const Color(0xFFFFFFFF);
      _dotFillColor = const Color(0xFF1E88E5);
    });
  }

  static String _modeTitle(amap.UserLocationType t) {
    switch (t) {
      case amap.UserLocationType.locationTypeShow:
        return '仅显示';
      case amap.UserLocationType.locationTypeLocate:
        return '定位一次';
      case amap.UserLocationType.locationTypeFollow:
        return '连续跟随';
      case amap.UserLocationType.locationTypeMapRotate:
        return '地图转向';
      case amap.UserLocationType.locationTypeLocationRotate:
        return '点随向转';
      case amap.UserLocationType.locationTypeLocationRotateNoCenter:
        return '点转不居中';
      case amap.UserLocationType.locationTypeFollowNoCenter:
        return '跟随不居中';
      case amap.UserLocationType.locationTypeMapRotateNoCenter:
        return '图转不居中';
    }
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.48,
            minHeight: 220,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.children,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.titleSmall),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle!, style: textTheme.bodySmall),
        ],
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.valueText,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
  });

  final String label;
  final String valueText;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text(valueText, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: valueText,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ColorSelector extends StatelessWidget {
  const _ColorSelector({
    required this.title,
    required this.value,
    required this.colors,
    required this.onChanged,
  });

  final String title;
  final Color value;
  final List<Color> colors;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: colors.map((color) {
              final selected = color == value;
              return Tooltip(
                message: _hexColor(color),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onChanged(color),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                        width: selected ? 3 : 1,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check, size: 18)
                        : const SizedBox.shrink(),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

String _hexColor(Color color) {
  // ignore: deprecated_member_use
  return '#${color.value.toRadixString(16).padLeft(8, '0')}';
}

const _accuracyFillColors = [
  Color(0x332196F3),
  Color(0x3300C853),
  Color(0x33FF9800),
  Color(0x33E91E63),
  Color(0x00000000),
];

const _strokeColors = [
  Color(0xFF1E88E5),
  Color(0xFF00A86B),
  Color(0xFFF57C00),
  Color(0xFFD81B60),
  Color(0xFF111827),
];

const _dotBgColors = [
  Color(0xFFFFFFFF),
  Color(0xFFE3F2FD),
  Color(0xFFE8F5E9),
  Color(0xFFFFF3E0),
  Color(0xFFFCE4EC),
];
