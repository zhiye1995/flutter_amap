import 'package:flutter/material.dart' hide Size;
import 'package:flutter/services.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';

class ScreenLocationPage extends StatefulWidget {
  const ScreenLocationPage({super.key});

  static const title = '经纬度转屏幕像素';

  @override
  State<ScreenLocationPage> createState() => _ScreenLocationPageState();
}

class _ScreenLocationPageState extends State<ScreenLocationPage> {
  static final _center = Position(latitude: 39.908722, longitude: 116.397499);

  final _xController = TextEditingController(text: '160');
  final _yController = TextEditingController(text: '220');

  AMapController? _controller;
  Position? _position;
  Size? _screenPoint;
  var _ready = false;
  var _loading = false;

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(ScreenLocationPage.title)),
      body: Column(
        children: [
          Expanded(
            child: AMapWidget(
              initCameraPosition: CameraPosition(position: _center, zoom: 16),
              markers: _markers,
              onMapCreated: _onMapCreated,
              onMapPress: _selectPosition,
              onPoiClick: (poi) => _selectPosition(poi.position),
            ),
          ),
          SafeArea(top: false, child: _buildPanel()),
        ],
      ),
    );
  }

  Set<Marker> get _markers {
    return <Marker>{
      if (_position != null)
        Marker(
          id: 'screen_location_marker',
          position: _position!,
          title: '转换点',
          snippet: _formatPosition(_position!),
        ),
    };
  }

  Widget _buildPanel() {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '点击地图获取屏幕像素，或输入像素反查经纬度。',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(_resultText),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _NumberField(
                    controller: _xController,
                    labelText: 'X 像素',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _NumberField(
                    controller: _yController,
                    labelText: 'Y 像素',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: !_ready || _loading
                      ? null
                      : _convertScreenToLatLng,
                  icon: const Icon(Icons.pin_drop_outlined),
                  label: const Text('像素转经纬度'),
                ),
                OutlinedButton.icon(
                  onPressed: !_ready || _loading ? null : _convertCenter,
                  icon: const Icon(Icons.center_focus_strong),
                  label: const Text('转换地图中心'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onMapCreated(AMapController controller) async {
    _controller = controller;
    await controller.waitForMapCompleted();
    if (!mounted || _controller != controller) return;
    setState(() => _ready = true);
    await _selectPosition(_center);
    if (mounted) context.snackBar('点击地图可查看该点对应的屏幕像素。');
  }

  Future<void> _selectPosition(Position position) async {
    final controller = _controller;
    if (controller == null) return;
    setState(() => _loading = true);
    try {
      final point = await controller.toScreenLocation(position);
      if (!mounted) return;
      _xController.text = point.width.toStringAsFixed(0);
      _yController.text = point.height.toStringAsFixed(0);
      setState(() {
        _position = position;
        _screenPoint = point;
      });
    } on Object catch (e) {
      LoadingUtil.showError('经纬度转屏幕像素失败: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _convertScreenToLatLng() async {
    final controller = _controller;
    final x = double.tryParse(_xController.text.trim());
    final y = double.tryParse(_yController.text.trim());
    if (controller == null || x == null || y == null) {
      LoadingUtil.showError('请输入有效像素坐标');
      return;
    }
    setState(() => _loading = true);
    try {
      final position = await controller.fromScreenLocation(
        Size(width: x, height: y),
      );
      if (!mounted) return;
      setState(() {
        _position = position;
        _screenPoint = Size(width: x, height: y);
      });
      await controller.moveCamera(CameraPosition(position: position, zoom: 16));
    } on Object catch (e) {
      LoadingUtil.showError('屏幕像素转经纬度失败: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _convertCenter() async {
    final center = _controller?.currentCamera?.position ?? _center;
    await _selectPosition(center);
  }

  String get _resultText {
    if (!_ready) return '地图加载中...';
    if (_position == null || _screenPoint == null) return '等待转换结果。';
    return '经纬度：${_formatPosition(_position!)}\n'
        '屏幕像素：x=${_screenPoint!.width.toStringAsFixed(1)}, '
        'y=${_screenPoint!.height.toStringAsFixed(1)}';
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.controller, required this.labelText});

  final TextEditingController controller;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

String _formatPosition(Position position) {
  return '${position.latitude.toStringAsFixed(6)}, '
      '${position.longitude.toStringAsFixed(6)}';
}
