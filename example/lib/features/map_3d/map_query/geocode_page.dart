import 'package:flutter/material.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';

/// 地理编码 / 逆地理编码功能示例。
class GeocodePage extends StatefulWidget {
  const GeocodePage({
    super.key,
    this.title = defaultTitle,
    this.initialMode = GeocodePageMode.both,
  });

  const GeocodePage.reGeocode({super.key})
      : title = '逆地理编码功能',
        initialMode = GeocodePageMode.reGeocode;

  static const defaultTitle = '地理编码功能';

  final String title;
  final GeocodePageMode initialMode;

  @override
  State<GeocodePage> createState() => _GeocodePageState();
}

enum GeocodePageMode {
  both,
  geocode,
  reGeocode,
}

class _GeocodePageState extends State<GeocodePage> {
  static final _defaultPosition =
      Position(latitude: 39.908722, longitude: 116.397499);

  final _addressController = TextEditingController(text: '北京市天安门');
  final _cityController = TextEditingController(text: '北京');
  final _latController = TextEditingController(text: '39.908722');
  final _lngController = TextEditingController(text: '116.397499');
  final _radiusController = TextEditingController(text: '1000');
  final _poiTypesController = TextEditingController();

  AMapController? _controller;
  List<GeocodeResult> _geocodeResults = const <GeocodeResult>[];
  ReGeocodeResult? _reGeocodeResult;
  Position? _selectedPosition = _defaultPosition;
  var _extensions = ReGeocodeExtensions.all;
  var _coordinateType = ReGeocodeCoordinateType.amap;
  var _loadingGeocode = false;
  var _loadingReGeocode = false;
  String? _errorMessage;

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    _poiTypesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showGeocode = widget.initialMode != GeocodePageMode.reGeocode;
    final showReGeocode = widget.initialMode != GeocodePageMode.geocode;
    final contentCards = widget.initialMode == GeocodePageMode.reGeocode
        ? <Widget>[_buildReGeocodeCard()]
        : <Widget>[
            if (showGeocode) _buildGeocodeCard(),
            if (showGeocode && showReGeocode) const SizedBox(height: 8),
            if (showReGeocode) _buildReGeocodeCard(),
          ];
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          SizedBox(
            height: 220,
            child: AMapWidget(
              initCameraPosition: CameraPosition(
                position: _defaultPosition,
                zoom: 13,
              ),
              markers: _markers,
              onMapCreated: (controller) => _controller = controller,
              onMapPress: _setReversePosition,
              onPoiClick: (poi) => _setReversePosition(poi.position),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                ...contentCards,
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  _buildErrorCard(),
                ],
                const SizedBox(height: 8),
                ..._buildResultCards(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> get _markers {
    return <Marker>{
      if (_selectedPosition != null)
        Marker(
          id: 'geocode_selected',
          position: _selectedPosition!,
          title: '查询点',
          snippet:
              '${_selectedPosition!.latitude}, ${_selectedPosition!.longitude}',
        ),
      for (var i = 0; i < _geocodeResults.length; i++)
        Marker(
          id: 'geocode_result_$i',
          position: _geocodeResults[i].position,
          title: _geocodeResults[i].formattedAddress,
          snippet: _geocodeResults[i].adCode,
        ),
    };
  }

  Widget _buildGeocodeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('地址转坐标', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '地址',
                hintText: '例如：北京市天安门',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: '城市（可选）',
                hintText: '北京 / 010 / 110000',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _loadingGeocode ? null : _searchGeocode,
              icon: _loadingGeocode
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(_loadingGeocode ? '查询中...' : '地理编码查询'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReGeocodeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('坐标转地址', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '点地图或 POI 可回填坐标。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '纬度',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _lngController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '经度',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 92,
                  child: TextField(
                    controller: _radiusController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '半径m',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _poiTypesController,
              decoration: const InputDecoration(
                labelText: '扩展 POI 类型（可选）',
                hintText: 'requireExtension=all 时生效，如 050000',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('返回扩展信息'),
                  selected: _extensions == ReGeocodeExtensions.all,
                  onSelected: (value) => setState(() {
                    _extensions = value
                        ? ReGeocodeExtensions.all
                        : ReGeocodeExtensions.base;
                  }),
                ),
                FilterChip(
                  label: const Text('GPS 坐标'),
                  selected: _coordinateType == ReGeocodeCoordinateType.gps,
                  onSelected: (value) => setState(() {
                    _coordinateType = value
                        ? ReGeocodeCoordinateType.gps
                        : ReGeocodeCoordinateType.amap;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _loadingReGeocode ? null : _searchReGeocode,
              icon: _loadingReGeocode
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.place),
              label: Text(_loadingReGeocode ? '查询中...' : '逆地理编码查询'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          _errorMessage!,
          style:
              TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
        ),
      ),
    );
  }

  List<Widget> _buildResultCards() {
    return <Widget>[
      if (_geocodeResults.isNotEmpty)
        Card(
          child: Column(
            children: [
              const ListTile(title: Text('地理编码结果')),
              for (final item in _geocodeResults)
                ListTile(
                  title: Text(item.formattedAddress),
                  subtitle: Text(
                    '坐标：${item.position.latitude}, ${item.position.longitude}\n'
                    '省市区：${item.province ?? '-'} ${item.city ?? '-'} ${item.district ?? '-'}\n'
                    'adCode：${item.adCode ?? '-'} level：${item.level ?? '-'}',
                  ),
                  isThreeLine: true,
                  onTap: () => _focusPosition(item.position),
                ),
            ],
          ),
        ),
      if (_reGeocodeResult != null)
        Card(
          child: Column(
            children: [
              const ListTile(title: Text('逆地理编码结果')),
              ListTile(
                title: Text(_reGeocodeResult!.formattedAddress),
                subtitle: Text(
                  '省市区：${_reGeocodeResult!.province ?? '-'} '
                  '${_reGeocodeResult!.city ?? '-'} '
                  '${_reGeocodeResult!.district ?? '-'}\n'
                  '乡镇：${_reGeocodeResult!.township ?? '-'} '
                  'adCode：${_reGeocodeResult!.adCode ?? '-'}\n'
                  '道路：${_reGeocodeResult!.roads.take(3).join('、')}',
                ),
                isThreeLine: true,
              ),
              if (_reGeocodeResult!.pois.isNotEmpty)
                ExpansionTile(
                  title: Text('附近 POI（${_reGeocodeResult!.pois.length}）'),
                  children: [
                    for (final poi in _reGeocodeResult!.pois.take(10))
                      ListTile(
                        dense: true,
                        title: Text(poi.name),
                        subtitle: Text(poi.address ?? poi.typeName ?? ''),
                      ),
                  ],
                ),
            ],
          ),
        ),
    ];
  }

  Future<void> _searchGeocode() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      LoadingUtil.showToast('请输入地址');
      return;
    }
    setState(() {
      _loadingGeocode = true;
      _errorMessage = null;
    });
    try {
      final results = await AMapSearch.searchGeocode(
        GeocodeQuery(
          address: address,
          city: _emptyToNull(_cityController.text),
        ),
      );
      if (!mounted) return;
      setState(() => _geocodeResults = results);
      if (results.isNotEmpty) {
        _setReversePosition(results.first.position, moveCamera: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
      LoadingUtil.showError('地理编码失败: $e');
    } finally {
      if (mounted) setState(() => _loadingGeocode = false);
    }
  }

  Future<void> _searchReGeocode() async {
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    if (lat == null || lng == null) {
      LoadingUtil.showToast('请输入有效经纬度');
      return;
    }
    final position = Position(latitude: lat, longitude: lng);
    setState(() {
      _loadingReGeocode = true;
      _errorMessage = null;
      _selectedPosition = position;
    });
    try {
      final result = await AMapSearch.searchReGeocode(
        ReGeocodeQuery(
          position: position,
          radius: int.tryParse(_radiusController.text.trim()) ?? 1000,
          extensions: _extensions,
          coordinateType: _coordinateType,
          poiTypes: _emptyToNull(_poiTypesController.text),
        ),
      );
      if (!mounted) return;
      setState(() => _reGeocodeResult = result);
      _focusPosition(position);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
      LoadingUtil.showError('逆地理编码失败: $e');
    } finally {
      if (mounted) setState(() => _loadingReGeocode = false);
    }
  }

  void _setReversePosition(Position position, {bool moveCamera = false}) {
    setState(() {
      _selectedPosition = position;
      _latController.text = position.latitude.toStringAsFixed(6);
      _lngController.text = position.longitude.toStringAsFixed(6);
    });
    if (moveCamera) _focusPosition(position);
  }

  void _focusPosition(Position position) {
    _controller?.moveCamera(
      CameraPosition(position: position, zoom: 16),
      const Duration(milliseconds: 300),
    );
  }

  String? _emptyToNull(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }
}
