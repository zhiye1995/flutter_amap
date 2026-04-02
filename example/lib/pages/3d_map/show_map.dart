import 'package:flutter/services.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter/material.dart';

/// 显示地图页面 — 高度模仿官方 Android Demo UI（仅 iOS / Android）
class ShowMapPage extends StatefulWidget {
  const ShowMapPage({super.key});

  static const title = '显示地图';

  @override
  State<ShowMapPage> createState() => _ShowMapPageState();
}

class _ShowMapPageState extends State<ShowMapPage> {
  /// 为 `null` 表示当前使用离线自定义样式（与 mapType 互斥）；非空为所选底图类型
  MapType? _mapType = MapType.standard;

  /// 取消离线样式时恢复的地图类型（进入离线样式前记住）
  MapType _mapTypeBeforeCustom = MapType.standard;

  /// 离线自定义样式（需 assets 资源）
  bool _customLookEnabled = false;

  Uint8List? _styleData;
  Uint8List? _styleExtraData;

  /// 离线自定义样式生效中（与 mapType 二选一）
  bool get _offlineCustomActive =>
      _customLookEnabled && _styleData != null && _styleExtraData != null;

  @override
  void initState() {
    super.initState();
    _loadOfflineStyleAssets();
  }

  Future<void> _loadOfflineStyleAssets() async {
    try {
      final style = await rootBundle.load('assets/style.data');
      final extra = await rootBundle.load('assets/style_extra.data');
      if (!mounted) {
        return;
      }
      // 在当帧布局/语义结束后再更新，避免与 PlatformView 叠层触发 parentDataDirty 断言
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _styleData = style.buffer.asUint8List();
          _styleExtraData = extra.buffer.asUint8List();
        });
      });
    } catch (_) {
      // 未放置样式文件时跳过离线自定义样式
    }
  }

  CustomStyleOptions? get _customStyleOptions {
    if (!_offlineCustomActive) {
      return null;
    }
    return CustomStyleOptions(
      true,
      styleData: _styleData,
      styleExtraData: _styleExtraData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ShowMapPage.title),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 底层地图：必须用 Positioned.fill，否则 Stack 中非 Positioned 子节点约束异常，
          // 易与 PlatformView 语义树冲突触发 '!semantics.parentDataDirty'
          Positioned.fill(
            child: AMapFlutter(
              initCameraPosition: CameraPosition(
                position: Position(latitude: 39.984120, longitude: 116.307484),
                zoom: 17.2,
              ),
              // 离线自定义样式与 mapType 互斥：启用离线样式时不传 mapType
              mapType: _offlineCustomActive ? null : (_mapType ?? MapType.standard),
              customStyleOptions: _customStyleOptions,
            ),
          ),

          // 左上角叠加面板：离线自定义样式
          Positioned(
            top: 20,
            left: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _customLookEnabled,
                    onChanged: (value) {
                      setState(() {
                        final on = value ?? false;
                        if (on && _styleData != null && _styleExtraData != null) {
                          if (_mapType != null) {
                            _mapTypeBeforeCustom = _mapType!;
                          }
                          _mapType = null;
                          _customLookEnabled = true;
                        } else if (!on) {
                          _customLookEnabled = false;
                          _mapType = _mapTypeBeforeCustom;
                        } else {
                          _customLookEnabled = on;
                        }
                      });
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                  Text(
                    _styleData != null ? '离线自定义样式' : '离线样式(无资源)',
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),

          // 右上角叠加面板：地图类型切换组
          Positioned(
            top: 20,
            right: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildMapTypeButton('标准地图', MapType.standard),
                const SizedBox(height: 8),
                _buildMapTypeButton('卫星地图', MapType.satellite),
                const SizedBox(height: 8),
                _buildMapTypeButton('夜间模式', MapType.standardNight),
                const SizedBox(height: 8),
                _buildMapTypeButton('导航模式', MapType.navi),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建地图类型切换按钮
  Widget _buildMapTypeButton(String title, MapType type) {
    final isSelected =
        !_offlineCustomActive && _mapType != null && _mapType == type;
    return SizedBox(
      width: 100,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          elevation: 2,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onPressed: () {
          setState(() {
            _customLookEnabled = false;
            _mapType = type;
            _mapTypeBeforeCustom = type;
          });
        },
        child: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
        ),
      ),
    );
  }
}
