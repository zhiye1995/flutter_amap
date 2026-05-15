import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';

class CoordinateConvertPage extends StatefulWidget {
  const CoordinateConvertPage({super.key});

  static const title = '坐标系转换';

  @override
  State<CoordinateConvertPage> createState() => _CoordinateConvertPageState();
}

class _CoordinateConvertPageState extends State<CoordinateConvertPage> {
  static final _defaultGps = Position(
    latitude: 39.908692,
    longitude: 116.397477,
  );

  final _latController = TextEditingController(text: '39.908692');
  final _lngController = TextEditingController(text: '116.397477');

  AMapController? _controller;
  Position? _source = _defaultGps;
  Position? _converted;
  var _ready = false;
  var _loading = false;
  var _from = CoordinateConvertType.gps;

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(CoordinateConvertPage.title)),
      body: Column(
        children: [
          Expanded(
            child: AMapWidget(
              initCameraPosition: CameraPosition(
                position: _defaultGps,
                zoom: 15,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: _onMapCreated,
              onMapPress: _setSourceFromMap,
              onPoiClick: (poi) => _setSourceFromMap(poi.position),
            ),
          ),
          SafeArea(top: false, child: _buildPanel()),
        ],
      ),
    );
  }

  Set<Marker> get _markers {
    return <Marker>{
      if (_source != null)
        Marker(
          id: 'coordinate_convert_source',
          position: _source!,
          title: '原始坐标',
          snippet: _formatPosition(_source!),
        ),
      if (_converted != null)
        Marker(
          id: 'coordinate_convert_converted',
          position: _converted!,
          title: '高德坐标',
          snippet: _formatPosition(_converted!),
        ),
    };
  }

  Set<Polyline> get _polylines {
    if (_source == null || _converted == null) return const <Polyline>{};
    return <Polyline>{
      Polyline(
        id: 'coordinate_convert_line',
        points: <Position>[_source!, _converted!],
        color: const Color(0xFF43A047),
        width: 8,
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
              '输入或点击地图选择原始坐标',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<CoordinateConvertType>(
              initialValue: _from,
              decoration: const InputDecoration(
                labelText: '原坐标系',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: CoordinateConvertType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.value)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _from = value);
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _NumberField(
                    controller: _latController,
                    labelText: '纬度',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _NumberField(
                    controller: _lngController,
                    labelText: '经度',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: !_ready || _loading ? null : _convert,
              icon: _loading
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.transform),
              label: const Text('转换为高德坐标'),
            ),
            const SizedBox(height: 10),
            Text(_resultText, style: Theme.of(context).textTheme.bodyMedium),
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
    await _convert();
    if (mounted) context.snackBar('可点击地图选择待转换坐标。');
  }

  void _setSourceFromMap(Position position) {
    _latController.text = position.latitude.toStringAsFixed(6);
    _lngController.text = position.longitude.toStringAsFixed(6);
    setState(() {
      _source = position;
      _converted = null;
    });
  }

  Future<void> _convert() async {
    final controller = _controller;
    final position = _readPosition();
    if (controller == null || position == null) return;
    setState(() {
      _loading = true;
      _source = position;
    });
    try {
      final converted = await controller.convertCoordinate(
        position,
        from: _from,
      );
      if (!mounted) return;
      setState(() => _converted = converted);
      controller.moveCamera(convertedCamera(converted));
    } on Object catch (e) {
      LoadingUtil.showError('坐标转换失败: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Position? _readPosition() {
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    if (lat == null || lng == null) {
      LoadingUtil.showError('请输入有效的经纬度');
      return null;
    }
    return Position(latitude: lat, longitude: lng);
  }

  CameraPosition convertedCamera(Position position) {
    return CameraPosition(position: position, zoom: 16);
  }

  String get _resultText {
    if (_converted == null) {
      return _ready ? '等待转换结果。' : '地图加载中...';
    }
    return '原始：${_formatPosition(_source!)}\n高德：${_formatPosition(_converted!)}';
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
