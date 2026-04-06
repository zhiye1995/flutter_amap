import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils.dart';

/// 地图控件位置设置页面
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
  static const logo = "Logo";
  static const scale = "比例尺";
  static const compass = "指南针";
  static const zoom = "缩放按钮";

  // 根据 AMapWidget 的定义：
  // logoPosition: Support iOS/Android
  // scaleControlPosition: All (Web/iOS/Android)
  // compassControlPosition: All (Web/iOS/Android)
  // zoomControlPosition: Support Web/Android
  
  static const webSupport = [scale, compass, zoom];
  static const androidSupport = [logo, scale, compass, zoom];
  static const iOSSupport = [logo, scale, compass];

  final Map<String, UIControlPosition> _positions = {
    logo: UIControlPosition(
      anchor: UIControlAnchor.bottomLeft,
      offset: UIControlOffset(x: 10, y: 10),
    ),
    scale:  UIControlPosition(
      anchor: UIControlAnchor.bottomLeft,
      offset: UIControlOffset(x: 10, y: 10),
    ),
    compass:  UIControlPosition(
      anchor: UIControlAnchor.topRight,
      offset: UIControlOffset(x: 10, y: 10),
    ),
    zoom:  UIControlPosition(
      anchor: UIControlAnchor.bottomRight,
      offset: UIControlOffset(x: 10, y: 10),
    ),
  };

  void showOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter stateSetter) {
            final Iterable<String> keys = switch (PlatformUtil.platform) {
              PlatformEnum.web => webSupport,
              PlatformEnum.android => androidSupport,
              PlatformEnum.ios => iOSSupport,
              PlatformEnum.unknown => [],
            };

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    "控件显示位置设置",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: keys.map((item) {
                          return _LabelControlPosition(
                            name: item,
                            position: _positions[item]!,
                            onChanged: (UIControlPosition position) {
                              stateSetter(() {
                                _positions[item] = position;
                              });
                              setState(() {
                                _positions[item] = position;
                              });
                            },
                            // Android 下除了 Logo 以外，大部分控件目前不支持自定义偏移（具体看 AMapApi.kt 的处理）
                            // 实际上 AMapApi.kt 只是简单将 anchor 转给 native。
                            // 这里遵循用户要求：不需要显示的/没有对应API的不显示。
                            offsetDisable: PlatformUtil.isAndroid,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("完成"),
                    ),
                  ),
                ],
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
            icon: const Icon(Icons.settings_outlined),
            onPressed: showOptions,
          ),
        ],
      ),
      body: AMapWidget(
        initCameraPosition: CameraPosition(
          position:  Position(latitude: 39.984120, longitude: 116.307484),
          zoom: 17.2,
        ),
        scaleControlEnabled: true,
        zoomControlEnabled: true,
        compassControlEnabled: true,
        logoPosition: _positions[logo],
        scaleControlPosition: _positions[scale],
        zoomControlPosition: _positions[zoom],
        compassControlPosition: _positions[compass],
      ),
    );
  }
}

class _LabelControlPosition extends StatelessWidget {
  const _LabelControlPosition({
    required this.name,
    required this.position,
    required this.onChanged,
    this.offsetDisable = false,
  });

  static const anchorLabels = {
    UIControlAnchor.topLeft: "左上角",
    UIControlAnchor.topCenter: "顶部",
    UIControlAnchor.topRight: "右上角",
    UIControlAnchor.centerLeft: "左侧",
    UIControlAnchor.center: "中心心",
    UIControlAnchor.centerRight: "右侧",
    UIControlAnchor.bottomLeft: "左下角",
    UIControlAnchor.bottomCenter: "底部",
    UIControlAnchor.bottomRight: "右下角",
  };

  final String name;
  final UIControlPosition position;
  final ValueChanged<UIControlPosition> onChanged;
  final bool offsetDisable;

  List<UIControlAnchor> get supportOptions {
    if (kIsWeb) {
      return [
        UIControlAnchor.topLeft,
        UIControlAnchor.topRight,
        UIControlAnchor.bottomLeft,
        UIControlAnchor.bottomRight,
      ];
    }
    if (PlatformUtil.isAndroid) {
      if (name == _MapControlsPositionPageState.logo) {
        return [
          UIControlAnchor.bottomLeft,
          UIControlAnchor.bottomCenter,
          UIControlAnchor.bottomRight,
        ];
      } else if (name == _MapControlsPositionPageState.zoom) {
        return [
          UIControlAnchor.centerRight,
          UIControlAnchor.bottomRight,
        ];
      }
      // 其他控件在 Android 下通常有默认位置
    }
    return UIControlAnchor.values;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.control_point_duplicate, size: 18),
              const SizedBox(width: 8),
              Text(
                name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<UIControlAnchor>(
                      isExpanded: true,
                      value: position.anchor,
                      items: UIControlAnchor.values.map((anchor) {
                        final enabled = supportOptions.contains(anchor);
                        return DropdownMenuItem(
                          value: anchor,
                          enabled: enabled,
                          child: Text(
                            anchorLabels[anchor]!,
                            style: TextStyle(
                              fontSize: 14,
                              color: enabled ? null : Theme.of(context).disabledColor,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (UIControlAnchor? anchor) {
                        if (anchor != null) {
                          onChanged(position.copyWith(anchor: anchor));
                        }
                      },
                    ),
                  ),
                ),
              ),
              if (!offsetDisable) ...[
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _MiniTextField(
                    label: "X轴",
                    initValue: position.offset.x.toStringAsFixed(0),
                    onChanged: (value) => onChanged(
                      position.copyWith(offset: position.offset.copyWith(x: value)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _MiniTextField(
                    label: "Y轴",
                    initValue: position.offset.y.toStringAsFixed(0),
                    onChanged: (value) => onChanged(
                      position.copyWith(offset: position.offset.copyWith(y: value)),
                    ),
                  ),
                ),
              ],
            ],
          )
        ],
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
        LengthLimitingTextInputFormatter(4),
        FilteringTextInputFormatter.allow(RegExp(r'-?[0-9]*')),
      ],
      style: const TextStyle(fontSize: 13),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
