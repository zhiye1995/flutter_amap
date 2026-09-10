import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_amap_plus/flutter_amap.dart';

import 'package:flutter_amap_example/core/utils/utils.dart';

final _mapCenter = Position(latitude: 39.984120, longitude: 116.307484);
final _linePadding = EdgePadding(top: 80, right: 60, bottom: 120, left: 60);
const _polylineTextureAsset = 'assets/texture_green.png';
const _polylineTextureAltAsset = 'assets/polyline_texture_alt.png';

/// Polylines 功能：普通折线的添加、删除、样式更新，以及地图点击追加路径点。
class PolylinesPage extends StatefulWidget {
  const PolylinesPage({super.key});

  static const title = 'Polylines功能';

  @override
  State<PolylinesPage> createState() => _PolylinesPageState();
}

class _PolylinesPageState extends State<PolylinesPage>
    with _OverlayActions<PolylinesPage> {
  static const _lineId = 'polyline_basic_demo';
  static const _minLineWidth = 4.0;
  static const _maxLineWidth = 30.0;

  @override
  Future<void> retryDrawing() async {
    final c = _controller;
    if (c == null) return;
    if (!_ready) {
      await _bootstrap(c);
    } else {
      await _draw();
    }
  }

  AMapController? _controller;
  var _ready = false;
  var _visible = true;
  var _hidden = false;
  var _lineWidth = 10.0;
  var _red = false;
  var _points = <Position>[
    Position(latitude: 39.984080, longitude: 116.305260),
    Position(latitude: 39.984520, longitude: 116.306240),
    Position(latitude: 39.983830, longitude: 116.307600),
    Position(latitude: 39.984260, longitude: 116.308760),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(PolylinesPage.title)),
      body: Column(
        children: [
          Expanded(
            child: AMapWidget(
              initCameraPosition: CameraPosition(
                position: _mapCenter,
                zoom: 16.4,
              ),
              onMapCreated: (c) => run(() => _bootstrap(c)),
              onPolylineClick: (id) => context.snackBar('已选中折线：$id'),
              onMapPress: (point) => run(() => _appendPoint(point)),
              onPoiClick: (poi) => run(() => _appendPoint(poi.position)),
            ),
          ),
          SafeArea(
            top: false,
            child: _Panel(
              title: _ready ? '点地图追加折线节点，当前 ${_points.length} 个点。' : '地图加载中...',
              footer: _LineWidthSlider(
                value: _lineWidth,
                min: _minLineWidth,
                max: _maxLineWidth,
                enabled: _ready && !busy && _visible,
                onChanged: (value) => preview(() => _setLineWidth(value)),
                onChangeEnd: (value) =>
                    preview(() => _setLineWidth(value), immediate: true),
              ),
              children: [
                ...actionStatus,
                OutlinedButton(
                  onPressed: !_ready || busy || _points.isEmpty
                      ? null
                      : () => run(() async {
                          setState(
                            () => _points = _points.sublist(
                              0,
                              _points.length - 1,
                            ),
                          );
                          await _draw();
                        }),
                  child: const Text('撤销末点'),
                ),
                OutlinedButton(
                  onPressed: !_ready || busy || _points.isEmpty
                      ? null
                      : () => run(() async {
                          setState(() => _points = []);
                          await _draw();
                        }),
                  child: const Text('清空节点'),
                ),
                OutlinedButton(
                  onPressed: !_ready || busy || !_visible || _points.length < 2
                      ? null
                      : () => run(() async {
                          setState(() => _hidden = !_hidden);
                          await _draw();
                        }),
                  child: Text(_hidden ? '显示折线' : '隐藏折线'),
                ),
                OutlinedButton(
                  onPressed: !_ready || busy || _points.length < 2
                      ? null
                      : () => run(() async {
                          await _controller!.moveCameraToFitPosition(
                            _points,
                            _linePadding,
                            const Duration(milliseconds: 300),
                          );
                        }),
                  child: const Text('适配视野'),
                ),
                FilledButton(
                  onPressed: !_ready || busy ? null : () => run(_toggleVisible),
                  child: Text(_visible ? '移除折线' : '添加折线'),
                ),
                FilledButton(
                  onPressed: !_ready || busy || !_visible
                      ? null
                      : () => run(_toggleWidth),
                  child: Text(_lineWidth > 14 ? '细线' : '粗线'),
                ),
                FilledButton(
                  onPressed: !_ready || busy || !_visible
                      ? null
                      : () => run(_toggleColor),
                  child: Text(_red ? '蓝色' : '红色'),
                ),
                OutlinedButton(
                  onPressed: !_ready || busy ? null : () => run(_reset),
                  child: const Text('重置'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bootstrap(AMapController c) async {
    setState(() => _controller = c);
    await c.waitForMapCompleted(throwOnTimeout: true);
    if (!mounted || _controller != c) return;
    await _draw();
    await c.moveCameraToFitPosition(
      _points,
      _linePadding,
      const Duration(milliseconds: 300),
    );
    if (mounted) {
      setState(() => _ready = true);
      context.snackBar('点击地图空白处或 POI，可把点追加到折线尾部。');
    }
  }

  Future<void> _draw() async {
    final c = _controller;
    if (c == null) return;
    if (!_visible || _points.length < 2) {
      await c.removePolyline(_lineId);
      return;
    }
    await c.updatePolyline(
      Polyline(
        id: _lineId,
        points: _points,
        color: _red ? const Color(0xFFE53935) : const Color(0xFF1976D2),
        width: _lineWidth,
        visible: !_hidden,
        clickable: true,
      ),
    );
  }

  Future<void> _replaceLine() async {
    final c = _controller;
    if (c == null) return;
    await _draw();
  }

  Future<void> _appendPoint(Position position) async {
    if (!_ready || !_visible) return;
    if (_points.isNotEmpty &&
        _points.last.latitude == position.latitude &&
        _points.last.longitude == position.longitude) {
      return;
    }
    setState(() => _points = [..._points, position]);
    await _replaceLine();
  }

  Future<void> _toggleVisible() async {
    final c = _controller;
    if (c == null) return;
    setState(() => _visible = !_visible);
    if (_visible) {
      await _draw();
    } else {
      await c.removePolyline(_lineId);
    }
  }

  Future<void> _toggleWidth() async {
    setState(() => _lineWidth = _lineWidth > 14 ? 10 : 18);
    await _replaceLine();
  }

  Future<void> _setLineWidth(double value) async {
    setState(() => _lineWidth = value);
    await _replaceLine();
  }

  Future<void> _toggleColor() async {
    setState(() => _red = !_red);
    await _replaceLine();
  }

  Future<void> _reset() async {
    setState(() {
      _visible = true;
      _hidden = false;
      _lineWidth = 10;
      _red = false;
      _points = <Position>[
        Position(latitude: 39.984080, longitude: 116.305260),
        Position(latitude: 39.984520, longitude: 116.306240),
        Position(latitude: 39.983830, longitude: 116.307600),
        Position(latitude: 39.984260, longitude: 116.308760),
      ];
    });
    await _replaceLine();
  }
}

/// 绘制多彩线：同一条折线按线段设置不同颜色，并支持渐变模式。
class MultiColorPolylinePage extends StatefulWidget {
  const MultiColorPolylinePage({super.key});

  static const title = '绘制多彩线';

  @override
  State<MultiColorPolylinePage> createState() => _MultiColorPolylinePageState();
}

class _MultiColorPolylinePageState extends State<MultiColorPolylinePage>
    with _OverlayActions<MultiColorPolylinePage> {
  static const _lineId = 'polyline_multicolor_demo';

  @override
  Future<void> retryDrawing() async {
    final c = _controller;
    if (c == null) return;
    if (!_ready) {
      await _bootstrap(c);
    } else {
      await _draw();
    }
  }

  AMapController? _controller;
  var _ready = false;
  var _gradient = false;
  var _grouped = false;

  final _points = <Position>[
    Position(latitude: 39.982870, longitude: 116.304980),
    Position(latitude: 39.984000, longitude: 116.305920),
    Position(latitude: 39.983360, longitude: 116.307160),
    Position(latitude: 39.984620, longitude: 116.308080),
    Position(latitude: 39.983920, longitude: 116.309360),
  ];

  final _colors = const <Color>[
    Color(0xFFE53935),
    Color(0xFFFFB300),
    Color(0xFF43A047),
    Color(0xFF1E88E5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(MultiColorPolylinePage.title)),
      body: Column(
        children: [
          Expanded(
            child: AMapWidget(
              initCameraPosition: CameraPosition(
                position: _mapCenter,
                zoom: 16.2,
              ),
              onMapCreated: (c) => run(() => _bootstrap(c)),
            ),
          ),
          SafeArea(
            top: false,
            child: _Panel(
              title: _gradient
                  ? '渐变多彩线：五个节点分别设置颜色，末端为紫色。'
                  : _grouped
                  ? '前两段红色、后两段蓝色，使用独立颜色编号。'
                  : '分段多彩线：每一段使用一个独立颜色。',
              children: [
                ...actionStatus,
                for (final color
                    in (_gradient
                        ? [..._colors, const Color(0xFF8E24AA)]
                        : _grouped
                        ? [_colors.first, _colors.last]
                        : _colors))
                  _ColorDot(color: color),
                OutlinedButton(
                  onPressed: !_ready || busy || _gradient
                      ? null
                      : () => run(() async {
                          setState(() => _grouped = !_grouped);
                          await _draw();
                        }),
                  child: Text(_grouped ? '恢复逐段颜色' : '前后各两段同色'),
                ),
                FilledButton(
                  onPressed: !_ready || busy
                      ? null
                      : () => run(_toggleGradient),
                  child: Text(_gradient ? '切换为分段' : '切换为渐变'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bootstrap(AMapController c) async {
    setState(() => _controller = c);
    await c.waitForMapCompleted(throwOnTimeout: true);
    if (!mounted || _controller != c) return;
    await _draw();
    await c.moveCameraToFitPosition(
      _points,
      _linePadding,
      const Duration(milliseconds: 300),
    );
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _draw() async {
    final c = _controller;
    if (c == null) return;
    await c.updatePolyline(
      Polyline(
        id: _lineId,
        points: _points,
        color: _colors.first,
        colors: _gradient
            ? [..._colors, const Color(0xFF8E24AA)]
            : _grouped
            ? [_colors.first, _colors.last]
            : _colors,
        colorIndexes: !_gradient && _grouped ? const [0, 0, 1, 1] : const [],
        gradient: _gradient,
        width: 16,
      ),
    );
  }

  Future<void> _toggleGradient() async {
    setState(() => _gradient = !_gradient);
    await _draw();
  }
}

/// Polyline 样式增强：演示纹理线、分段纹理、虚线和 zIndex 叠放。
class PolylineStylePage extends StatefulWidget {
  const PolylineStylePage({super.key});

  static const title = 'Polyline样式增强';

  @override
  State<PolylineStylePage> createState() => _PolylineStylePageState();
}

class _PolylineStylePageState extends State<PolylineStylePage>
    with _OverlayActions<PolylineStylePage> {
  static const _dottedId = 'polyline_style_dotted';
  static const _textureId = 'polyline_style_texture';
  static const _multiTextureId = 'polyline_style_multi_texture';
  static const _zBackId = 'polyline_style_z_back';
  static const _zFrontId = 'polyline_style_z_front';
  static const _minLineWidth = 4.0;
  static const _maxLineWidth = 30.0;

  @override
  Future<void> retryDrawing() async {
    final c = _controller;
    if (c == null) return;
    if (!_ready) {
      await _bootstrap(c);
    } else {
      await _draw();
    }
  }

  AMapController? _controller;
  var _ready = false;
  var _useTexture = true;
  var _frontOnTop = true;
  var _lineWidth = 18.0;
  var _dashType = PolylineDash.square;
  var _lineCap = PolylineCap.butt;
  var _lineJoin = PolylineJoin.bevel;
  final _drawn = <String, Polyline>{};

  Future<void> _submit(Polyline line) async {
    if (_drawn[line.id] == line) return;
    await _controller!.updatePolyline(line);
    _drawn[line.id] = line;
  }

  final _dottedPoints = <Position>[
    Position(latitude: 39.985130, longitude: 116.303780),
    Position(latitude: 39.986020, longitude: 116.305260),
    Position(latitude: 39.985360, longitude: 116.306760),
    Position(latitude: 39.986110, longitude: 116.308180),
  ];

  final _texturePoints = <Position>[
    Position(latitude: 39.983880, longitude: 116.303960),
    Position(latitude: 39.984280, longitude: 116.305280),
    Position(latitude: 39.983540, longitude: 116.306520),
    Position(latitude: 39.984060, longitude: 116.307760),
  ];

  final _multiTexturePoints = <Position>[
    Position(latitude: 39.982720, longitude: 116.304240),
    Position(latitude: 39.982980, longitude: 116.305620),
    Position(latitude: 39.982420, longitude: 116.306840),
    Position(latitude: 39.982900, longitude: 116.308140),
    Position(latitude: 39.982320, longitude: 116.309300),
  ];

  final _zBackPoints = <Position>[
    Position(latitude: 39.985020, longitude: 116.309200),
    Position(latitude: 39.983900, longitude: 116.310780),
  ];

  final _zFrontPoints = <Position>[
    Position(latitude: 39.983880, longitude: 116.309200),
    Position(latitude: 39.985040, longitude: 116.310780),
  ];

  List<Position> get _fitPoints => [
    ..._dottedPoints,
    ..._texturePoints,
    ..._multiTexturePoints,
    ..._zBackPoints,
    ..._zFrontPoints,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(PolylineStylePage.title)),
      body: Column(
        children: [
          Expanded(
            child: AMapWidget(
              initCameraPosition: CameraPosition(
                position: _mapCenter,
                zoom: 16.1,
              ),
              onMapCreated: (c) => run(() => _bootstrap(c)),
            ),
          ),
          SafeArea(
            top: false,
            child: _Panel(
              title: _useTexture
                  ? '纹理线启用中；iOS 仅 3D 地图支持，纹理会覆盖颜色样式。'
                  : '纹理线关闭后展示普通线，虚线和 zIndex 仍生效。',
              footer: _LineWidthSlider(
                value: _lineWidth,
                min: _minLineWidth,
                max: _maxLineWidth,
                enabled: _ready && !busy,
                onChanged: (value) => preview(() => _setLineWidth(value)),
                onChangeEnd: (value) =>
                    preview(() => _setLineWidth(value), immediate: true),
              ),
              children: [
                ...actionStatus,
                OutlinedButton(
                  onPressed: !_ready || busy
                      ? null
                      : () => run(() async {
                          setState(
                            () => _dashType = _dashType == PolylineDash.square
                                ? PolylineDash.circle
                                : PolylineDash.square,
                          );
                          await _draw();
                        }),
                  child: Text(
                    _dashType == PolylineDash.square ? '方形虚线' : '圆点虚线',
                  ),
                ),
                OutlinedButton(
                  onPressed: !_ready || busy
                      ? null
                      : () => run(() async {
                          setState(
                            () => _lineCap =
                                PolylineCap.values[(_lineCap.index + 1) %
                                    PolylineCap.values.length],
                          );
                          await _draw();
                        }),
                  child: Text('端点：${const ['平头', '方头', '圆头'][_lineCap.index]}'),
                ),
                OutlinedButton(
                  onPressed: !_ready || busy
                      ? null
                      : () => run(() async {
                          setState(
                            () => _lineJoin =
                                PolylineJoin.values[(_lineJoin.index + 1) %
                                    PolylineJoin.values.length],
                          );
                          await _draw();
                        }),
                  child: Text(
                    '连接：${const ['斜面', '尖角', '圆角'][_lineJoin.index]}',
                  ),
                ),
                const _LegendDot(color: Color(0xFF7B1FA2), label: '虚线'),
                const _LegendDot(color: Color(0xFF00897B), label: '单纹理'),
                const _LegendDot(color: Color(0xFFFF8F00), label: '分段纹理'),
                FilledButton(
                  onPressed: !_ready || busy ? null : () => run(_toggleTexture),
                  child: Text(_useTexture ? '关闭纹理' : '启用纹理'),
                ),
                FilledButton(
                  onPressed: !_ready || busy ? null : () => run(_toggleZIndex),
                  child: Text(_frontOnTop ? '蓝线置底' : '蓝线置顶'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bootstrap(AMapController c) async {
    if (_controller != c) _drawn.clear();
    setState(() => _controller = c);
    await c.waitForMapCompleted(throwOnTimeout: true);
    if (!mounted || _controller != c) return;
    await _draw();
    await c.moveCameraToFitPosition(
      _fitPoints,
      _linePadding,
      const Duration(milliseconds: 300),
    );
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _draw() async {
    final c = _controller;
    if (c == null) return;
    await _submit(
      Polyline(
        id: _dottedId,
        points: _dottedPoints,
        color: const Color(0xFF7B1FA2),
        width: _lineWidth,
        lineCap: _lineCap,
        lineJoin: _lineJoin,
        dottedLine: true,
        dashType: _dashType,
        zIndex: 1,
      ),
    );
    await _submit(
      Polyline(
        id: _textureId,
        points: _texturePoints,
        color: const Color(0xFF00897B),
        width: _lineWidth,
        lineCap: _lineCap,
        lineJoin: _lineJoin,
        useTexture: _useTexture,
        texture: _useTexture
            ? Bitmap(
                asset: _polylineTextureAsset,
                size: Size(width: 64, height: 64),
              )
            : null,
        zIndex: 2,
      ),
    );
    await _submit(
      Polyline(
        id: _multiTextureId,
        points: _multiTexturePoints,
        color: const Color(0xFFFF8F00),
        width: _lineWidth,
        lineCap: _lineCap,
        lineJoin: _lineJoin,
        useTexture: _useTexture,
        textures: _useTexture
            ? <Bitmap>[
                Bitmap(
                  asset: _polylineTextureAsset,
                  size: Size(width: 64, height: 64),
                ),
                Bitmap(
                  asset: _polylineTextureAltAsset,
                  size: Size(width: 64, height: 64),
                ),
              ]
            : const <Bitmap>[],
        textureIndexes: _useTexture ? const <int>[0, 1, 0, 1] : const <int>[],
        zIndex: 3,
      ),
    );
    await _submit(
      Polyline(
        id: _zBackId,
        points: _zBackPoints,
        color: const Color(0xFFE53935),
        width: _lineWidth,
        lineCap: _lineCap,
        lineJoin: _lineJoin,
        zIndex: _frontOnTop ? 4 : 6,
      ),
    );
    await _submit(
      Polyline(
        id: _zFrontId,
        points: _zFrontPoints,
        color: const Color(0xFF1976D2),
        width: _lineWidth,
        lineCap: _lineCap,
        lineJoin: _lineJoin,
        zIndex: _frontOnTop ? 6 : 4,
      ),
    );
  }

  Future<void> _setLineWidth(double value) async {
    setState(() => _lineWidth = value);
    await _draw();
  }

  Future<void> _toggleTexture() async {
    setState(() => _useTexture = !_useTexture);
    await _draw();
  }

  Future<void> _toggleZIndex() async {
    setState(() => _frontOnTop = !_frontOnTop);
    await _draw();
  }
}

/// NavigateArrow 功能：沿轨迹绘制 3D 导航箭头线。
class NavigateArrowPage extends StatefulWidget {
  const NavigateArrowPage({super.key});

  static const title = 'NavigateArrow功能';

  @override
  State<NavigateArrowPage> createState() => _NavigateArrowPageState();
}

class _NavigateArrowPageState extends State<NavigateArrowPage>
    with _OverlayActions<NavigateArrowPage> {
  static const _arrowId = 'navigate_arrow_demo';

  @override
  Future<void> retryDrawing() async {
    final c = _controller;
    if (c == null) return;
    if (!_ready) {
      await _bootstrap(c);
    } else {
      await _draw();
    }
  }

  AMapController? _controller;
  var _ready = false;
  var _visible = true;
  var _wide = false;
  var _red = false;

  final _points = <Position>[
    Position(latitude: 39.9871, longitude: 116.4789),
    Position(latitude: 39.9879, longitude: 116.4777),
    Position(latitude: 39.9897, longitude: 116.4797),
    Position(latitude: 39.9887, longitude: 116.4813),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(NavigateArrowPage.title)),
      body: Column(
        children: [
          Expanded(
            child: AMapWidget(
              initCameraPosition: CameraPosition(
                position: Position(latitude: 39.9875, longitude: 116.48047),
                zoom: 16,
                skew: 38.5,
                heading: 300,
              ),
              onMapCreated: (c) => run(() => _bootstrap(c)),
            ),
          ),
          SafeArea(
            top: false,
            child: _Panel(
              title: '参考官方 Demo 坐标绘制导航箭头；iOS 使用 3D 箭头线等效展示。',
              children: [
                ...actionStatus,
                _LegendDot(
                  color: _red
                      ? const Color(0xFFE53935)
                      : const Color(0xFF1976D2),
                  label: _red ? '红色箭头' : '蓝色箭头',
                ),
                FilledButton(
                  onPressed: !_ready || busy ? null : () => run(_toggleVisible),
                  child: Text(_visible ? '移除箭头' : '添加箭头'),
                ),
                FilledButton(
                  onPressed: !_ready || busy || !_visible
                      ? null
                      : () => run(_toggleWidth),
                  child: Text(_wide ? '细箭头' : '粗箭头'),
                ),
                FilledButton(
                  onPressed: !_ready || busy || !_visible
                      ? null
                      : () => run(_toggleColor),
                  child: Text(_red ? '蓝色' : '红色'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bootstrap(AMapController c) async {
    setState(() => _controller = c);
    await c.waitForMapCompleted(throwOnTimeout: true);
    if (!mounted || _controller != c) return;
    await _draw();
    await c.moveCameraToFitPosition(
      _points,
      _linePadding,
      const Duration(milliseconds: 300),
    );
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _draw() async {
    final c = _controller;
    if (c == null) return;
    if (!_visible) {
      await c.removeNavigateArrow(_arrowId);
      return;
    }
    await c.addNavigateArrow(
      NavigateArrow(
        id: _arrowId,
        points: _points,
        color: _red ? const Color(0xFFE53935) : const Color(0xFF1976D2),
        sideColor: _red ? const Color(0xFF8E1B14) : const Color(0xFF0D47A1),
        width: _wide ? 24 : 16,
      ),
    );
  }

  Future<void> _replaceArrow() async {
    final c = _controller;
    if (c == null) return;
    await _draw();
  }

  Future<void> _toggleVisible() async {
    final c = _controller;
    if (c == null) return;
    setState(() => _visible = !_visible);
    if (_visible) {
      await _draw();
    } else {
      await c.removeNavigateArrow(_arrowId);
    }
  }

  Future<void> _toggleWidth() async {
    setState(() => _wide = !_wide);
    await _replaceArrow();
  }

  Future<void> _toggleColor() async {
    setState(() => _red = !_red);
    await _replaceArrow();
  }
}

/// 绘制大地曲线：同一组远距离点分别以普通折线和大地曲线展示，便于观察曲率差异。
class GeodesicPolylinePage extends StatefulWidget {
  const GeodesicPolylinePage({super.key});

  static const title = '绘制大地曲线';

  @override
  State<GeodesicPolylinePage> createState() => _GeodesicPolylinePageState();
}

class _GeodesicPolylinePageState extends State<GeodesicPolylinePage>
    with _OverlayActions<GeodesicPolylinePage> {
  static const _straightId = 'polyline_straight_compare';
  static const _geodesicId = 'polyline_geodesic_demo';

  @override
  Future<void> retryDrawing() async {
    final c = _controller;
    if (c == null) return;
    if (!_ready) {
      await _bootstrap(c);
    } else {
      await _draw();
    }
  }

  AMapController? _controller;
  var _ready = false;
  var _showCompare = true;
  var _twoPoints = false;

  final _cityPoints = <Position>[
    Position(latitude: 39.904211, longitude: 116.407395), // 北京
    Position(latitude: 31.230416, longitude: 121.473701), // 上海
    Position(latitude: 22.543099, longitude: 114.057868), // 深圳
    Position(latitude: 35.689487, longitude: 139.691711), // 东京
  ];

  List<Position> get _points => _twoPoints
      ? [_cityPoints.first, Position(latitude: 51.5074, longitude: -0.1278)]
      : _cityPoints;

  Future<void> _fit() => _controller!.moveCameraToFitPosition(
    _sampleGeodesic(_points),
    _linePadding,
    const Duration(milliseconds: 300),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(GeodesicPolylinePage.title)),
      body: Column(
        children: [
          Expanded(
            child: AMapWidget(
              initCameraPosition: CameraPosition(
                position: Position(latitude: 31.8, longitude: 123.0),
                zoom: 4.2,
              ),
              onMapCreated: (c) => run(() => _bootstrap(c)),
            ),
          ),
          SafeArea(
            top: false,
            child: _Panel(
              title: _twoPoints ? '北京—伦敦：两点远距离曲线对比。' : '橙色为大地曲线；蓝色为普通折线对比。',
              children: [
                ...actionStatus,
                OutlinedButton(
                  onPressed: !_ready || busy
                      ? null
                      : () => run(() async {
                          setState(() => _twoPoints = !_twoPoints);
                          await _addCityMarkers(_controller!);
                          await _draw();
                          await _fit();
                        }),
                  child: Text(_twoPoints ? '切换多点路线' : '切换两点远距离'),
                ),
                OutlinedButton(
                  onPressed: !_ready || busy ? null : () => run(_fit),
                  child: const Text('适配整条曲线'),
                ),
                const _LegendDot(color: Color(0xFFFF6F00), label: '大地曲线'),
                if (_showCompare)
                  const _LegendDot(color: Color(0xFF1976D2), label: '普通折线'),
                FilledButton(
                  onPressed: !_ready || busy ? null : () => run(_toggleCompare),
                  child: Text(_showCompare ? '隐藏普通线' : '显示普通线'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bootstrap(AMapController c) async {
    setState(() => _controller = c);
    await c.waitForMapCompleted(throwOnTimeout: true);
    if (!mounted || _controller != c) return;
    await _addCityMarkers(c);
    await _draw();
    await _fit();
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _addCityMarkers(AMapController c) async {
    final names = _twoPoints ? ['北京', '伦敦'] : ['北京', '上海', '深圳', '东京'];
    for (var i = 0; i < 4; i++) {
      await c.removeMarker('geodesic_city_$i');
    }
    for (var i = 0; i < _points.length; i++) {
      await c.addMarker(
        Marker(
          id: 'geodesic_city_$i',
          position: _points[i],
          title: names[i],
          snippet: '大地曲线节点',
        ),
      );
    }
  }

  Future<void> _draw() async {
    final c = _controller;
    if (c == null) return;
    if (!_showCompare) await c.removePolyline(_straightId);
    if (_showCompare) {
      await c.updatePolyline(
        Polyline(
          id: _straightId,
          points: _points,
          color: const Color(0x991976D2),
          width: 8,
        ),
      );
    }
    await c.updatePolyline(
      Polyline(
        id: _geodesicId,
        points: _points,
        color: const Color(0xFFFF6F00),
        width: 10,
        geodesic: true,
      ),
    );
  }

  Future<void> _toggleCompare() async {
    setState(() => _showCompare = !_showCompare);
    await _draw();
  }
}

/// 绘制弧线：起点、途经点、终点三点决定圆弧形状。
class ArcPolylinePage extends StatefulWidget {
  const ArcPolylinePage({super.key});

  static const title = '绘制弧线';

  @override
  State<ArcPolylinePage> createState() => _ArcPolylinePageState();
}

class _ArcPolylinePageState extends State<ArcPolylinePage>
    with _OverlayActions<ArcPolylinePage> {
  static const _arcId = 'arc_demo';
  static const _referenceId = 'arc_reference_line';

  @override
  Future<void> retryDrawing() async {
    final c = _controller;
    if (c == null) return;
    if (!_ready) {
      await _bootstrap(c);
    } else {
      await _draw();
    }
  }

  AMapController? _controller;
  var _ready = false;
  var _useNorthPassed = true;

  final _start = Position(latitude: 39.982950, longitude: 116.304900);
  final _northPassed = Position(latitude: 39.987050, longitude: 116.307200);
  final _southPassed = Position(latitude: 39.981200, longitude: 116.307200);
  final _end = Position(latitude: 39.983050, longitude: 116.310200);

  Position get _passed => _useNorthPassed ? _northPassed : _southPassed;

  List<Position> get _fitPoints => [_start, _northPassed, _southPassed, _end];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(ArcPolylinePage.title)),
      body: Column(
        children: [
          Expanded(
            child: AMapWidget(
              initCameraPosition: CameraPosition(
                position: _mapCenter,
                zoom: 15.8,
              ),
              onMapCreated: (c) => run(() => _bootstrap(c)),
            ),
          ),
          SafeArea(
            top: false,
            child: _Panel(
              title: _useNorthPassed
                  ? '当前使用北侧途经点，弧线向上拱起。'
                  : '当前使用南侧途经点，弧线向下拱起。',
              children: [
                ...actionStatus,
                const _LegendDot(color: Color(0xFFE53935), label: 'Arc'),
                const _LegendDot(color: Color(0x661976D2), label: '三点参考线'),
                FilledButton(
                  onPressed: !_ready || busy
                      ? null
                      : () => run(_togglePassedPoint),
                  child: const Text('切换途经点'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bootstrap(AMapController c) async {
    setState(() => _controller = c);
    await c.waitForMapCompleted(throwOnTimeout: true);
    if (!mounted || _controller != c) return;
    await _addMarkers(c);
    await _draw();
    await c.moveCameraToFitPosition(
      _fitPoints,
      _linePadding,
      const Duration(milliseconds: 300),
    );
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _addMarkers(AMapController c) async {
    final markers = <(String, String, Position)>[
      ('arc_start', '起点', _start),
      ('arc_passed_north', '北侧途经点', _northPassed),
      ('arc_passed_south', '南侧途经点', _southPassed),
      ('arc_end', '终点', _end),
    ];
    for (final (id, title, position) in markers) {
      await c.addMarker(Marker(id: id, position: position, title: title));
    }
  }

  Future<void> _draw() async {
    final c = _controller;
    if (c == null) return;
    await c.updatePolyline(
      Polyline(
        id: _referenceId,
        points: [_start, _passed, _end],
        color: const Color(0x661976D2),
        width: 6,
      ),
    );
    await c.addArc(
      Arc(
        id: _arcId,
        start: _start,
        passed: _passed,
        end: _end,
        color: const Color(0xFFE53935),
        width: 12,
      ),
    );
  }

  Future<void> _togglePassedPoint() async {
    setState(() => _useNorthPassed = !_useNorthPassed);
    await _draw();
  }
}

// Sample the same great-circle geometry for fitting, without changing SDK inputs.
List<Position> _sampleGeodesic(List<Position> points) {
  final result = <Position>[];
  List<double> vector(Position p) {
    final lat = p.latitude * math.pi / 180;
    final lon = p.longitude * math.pi / 180;
    return [
      math.cos(lat) * math.cos(lon),
      math.cos(lat) * math.sin(lon),
      math.sin(lat),
    ];
  }

  for (var i = 1; i < points.length; i++) {
    final a = vector(points[i - 1]), b = vector(points[i]);
    final angle = math.acos(
      (a[0] * b[0] + a[1] * b[1] + a[2] * b[2]).clamp(-1.0, 1.0),
    );
    for (var step = 0; step <= 64; step++) {
      final t = step / 64;
      if (math.sin(angle).abs() < 1e-10) {
        result.add(points[i - 1]);
        continue;
      }
      final u = math.sin((1 - t) * angle) / math.sin(angle);
      final v = math.sin(t * angle) / math.sin(angle);
      final x = u * a[0] + v * b[0],
          y = u * a[1] + v * b[1],
          z = u * a[2] + v * b[2];
      result.add(
        Position(
          latitude: math.atan2(z, math.sqrt(x * x + y * y)) * 180 / math.pi,
          longitude: math.atan2(y, x) * 180 / math.pi,
        ),
      );
    }
  }
  return [...points, ...result];
}

mixin _OverlayActions<T extends StatefulWidget> on State<T> {
  bool busy = false;
  String? _error;
  Future<void> Function()? _retry;
  Timer? _previewTimer;

  List<Widget> get actionStatus => [
    if (busy) const Text('正在更新…'),
    if (_error != null)
      Text(_error!, style: const TextStyle(color: Colors.red)),
    if (_error != null)
      OutlinedButton(
        onPressed: busy || _retry == null ? null : () => run(_retry!),
        child: const Text('重试'),
      ),
  ];

  Future<void> run(Future<void> Function() action) async {
    if (!mounted || busy) return;
    setState(() {
      busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error is TimeoutException ? '地图加载超时，请重试。' : '更新未完成，请重试。';
          _retry = retryDrawing;
        });
      }
      debugPrint('Polyline demo operation failed: $error');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  /// Retry the current desired configuration, never repeat a toggle.
  Future<void> retryDrawing();

  void preview(Future<void> Function() action, {bool immediate = false}) {
    _previewTimer?.cancel();
    if (!mounted) return;
    if (immediate && !busy) {
      run(action);
      return;
    }
    _previewTimer = Timer(const Duration(milliseconds: 60), () {
      if (busy) {
        preview(action);
      } else {
        run(action);
      }
    });
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    super.dispose();
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.children, this.footer});

  final String title;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.42,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: children,
              ),
              if (footer != null) ...[const SizedBox(height: 8), footer!],
            ],
          ),
        ),
      ),
    );
  }
}

class _LineWidthSlider extends StatelessWidget {
  const _LineWidthSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.enabled,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final double value;
  final double min;
  final double max;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final valueText = '${value.round()} px';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('线条宽度', style: Theme.of(context).textTheme.bodySmall),
            const Spacer(),
            Text(valueText, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          label: valueText,
          onChanged: enabled ? onChanged : null,
          onChangeEnd: enabled ? onChangeEnd : null,
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ColorDot(color: color),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12),
      ),
    );
  }
}
