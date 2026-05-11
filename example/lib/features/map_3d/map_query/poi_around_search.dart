import 'package:flutter/material.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';

/// POI 周边搜索：对齐高德圆形范围检索参数。
class PoiAroundSearchPage extends StatefulWidget {
  const PoiAroundSearchPage({super.key});

  static const title = 'poi周边搜索';

  @override
  State<PoiAroundSearchPage> createState() => _PoiAroundSearchPageState();
}

class _PoiAroundSearchPageState extends State<PoiAroundSearchPage> {
  static final _defaultCenter =
      Position(latitude: 39.984120, longitude: 116.307484);

  final _keywordController = TextEditingController(text: '餐饮');
  final _typesController = TextEditingController(text: '050000');
  final _cityController = TextEditingController(text: '北京');
  final _radiusController = TextEditingController(text: '1000');
  final _pageSizeController = TextEditingController(text: '10');

  AMapController? _controller;
  Position _center = _defaultCenter;
  PoiSearchResult? _result;
  var _page = 1;
  var _useExtension = false;
  var _children = false;
  var _sortByDistance = true;
  var _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _keywordController.dispose();
    _typesController.dispose();
    _cityController.dispose();
    _radiusController.dispose();
    _pageSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(PoiAroundSearchPage.title)),
      body: Column(
        children: [
          SizedBox(
            height: 220,
            child: AMapWidget(
              initCameraPosition: CameraPosition(position: _center, zoom: 15),
              markers: _markers,
              onMapCreated: (controller) => _controller = controller,
              onCameraChangeFinish: (camera) {
                if (camera.position != null) {
                  setState(() => _center = camera.position!);
                }
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _buildSearchCard(),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  _buildErrorCard(),
                ],
                const SizedBox(height: 8),
                _buildResultHeader(),
                const SizedBox(height: 8),
                ..._buildResultTiles(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> get _markers {
    final items = _result?.items ?? const <PoiItem>[];
    return <Marker>{
      Marker(
        id: 'poi_around_center',
        position: _center,
        title: '搜索中心',
        snippet: '${_center.latitude}, ${_center.longitude}',
      ),
      for (var i = 0; i < items.length; i++)
        Marker(
          id: 'poi_around_$i',
          position: items[i].position,
          title: items[i].name,
          snippet: items[i].address,
        ),
    };
  }

  Widget _buildSearchCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '移动地图后，以地图中心作为周边搜索中心。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              '中心点：${_center.latitude.toStringAsFixed(6)}, '
              '${_center.longitude.toStringAsFixed(6)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _keywordController,
              decoration: const InputDecoration(
                labelText: '关键字（可选）',
                hintText: '例如：餐饮|咖啡',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(resetPage: true),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _typesController,
              decoration: const InputDecoration(
                labelText: 'POI 类型（可选）',
                hintText: '类型名或编码，多个用 | 分隔，如 050000',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: '城市（可选）',
                      hintText: '北京 / 010 / 110000',
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
                const SizedBox(width: 8),
                SizedBox(
                  width: 82,
                  child: TextField(
                    controller: _pageSizeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '每页',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                FilterChip(
                  label: const Text('按距离排序'),
                  selected: _sortByDistance,
                  onSelected: (value) =>
                      setState(() => _sortByDistance = value),
                ),
                FilterChip(
                  label: const Text('扩展信息'),
                  selected: _useExtension,
                  onSelected: (value) => setState(() => _useExtension = value),
                ),
                FilterChip(
                  label: const Text('子 POI'),
                  selected: _children,
                  onSelected: (value) => setState(() => _children = value),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _loading ? null : () => _search(resetPage: true),
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(_loading ? '搜索中...' : '搜索周边 POI'),
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

  Widget _buildResultHeader() {
    final result = _result;
    final totalText = result?.total == null ? '未知' : '${result!.total}';
    return Row(
      children: [
        Expanded(
          child: Text(
            result == null
                ? '暂无搜索结果'
                : '第 ${result.page} 页，共 ${result.items.length} 条，总数 $totalText',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        IconButton(
          tooltip: '上一页',
          onPressed: _loading || _page <= 1 ? null : _previousPage,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          tooltip: '下一页',
          onPressed: _loading || result == null || result.items.isEmpty
              ? null
              : _nextPage,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  List<Widget> _buildResultTiles() {
    final items = _result?.items ?? const <PoiItem>[];
    if (items.isEmpty) {
      return const <Widget>[
        Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('移动地图或调整参数后搜索')),
          ),
        ),
      ];
    }

    return <Widget>[
      for (final item in items)
        Card(
          child: ListTile(
            title: Text(item.name),
            subtitle: Text(
              [
                if (item.address != null && item.address!.isNotEmpty)
                  item.address,
                if (item.typeName != null && item.typeName!.isNotEmpty)
                  item.typeName,
                if (item.adName != null && item.adName!.isNotEmpty)
                  '${item.cityName ?? ''}${item.adName}',
                'adcode：${item.adCode ?? '-'}',
                '坐标：${item.position.latitude.toStringAsFixed(6)}, '
                    '${item.position.longitude.toStringAsFixed(6)}',
                if (item.distance != null) '距离：${item.distance}m',
              ].whereType<String>().join('\n'),
            ),
            isThreeLine: true,
            onTap: () => _focusPoi(item),
          ),
        ),
    ];
  }

  Future<void> _search({required bool resetPage}) async {
    if (resetPage) _page = 1;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final result = await AMapSearch.searchPOIAroundWithQuery(
        PoiAroundSearchQuery(
          center: _center,
          keywords: _emptyToNull(_keywordController.text),
          types: _emptyToNull(_typesController.text),
          radius: int.tryParse(_radiusController.text.trim()) ?? 1000,
          city: _emptyToNull(_cityController.text),
          page: _page,
          pageSize: int.tryParse(_pageSizeController.text.trim()) ?? 10,
          extensions: _useExtension
              ? PoiSearchExtensions.all
              : PoiSearchExtensions.base,
          children: _children,
          sortByDistance: _sortByDistance,
        ),
      );
      if (!mounted) return;
      setState(() => _result = result);
      _fitResult(result.items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
      LoadingUtil.showError('周边搜索失败: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _emptyToNull(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  void _previousPage() {
    if (_page <= 1) return;
    _page -= 1;
    _search(resetPage: false);
  }

  void _nextPage() {
    _page += 1;
    _search(resetPage: false);
  }

  void _focusPoi(PoiItem item) {
    _controller?.moveCamera(
      CameraPosition(position: item.position, zoom: 17),
      const Duration(milliseconds: 300),
    );
  }

  void _fitResult(List<PoiItem> items) {
    if (items.isEmpty) return;
    if (items.length == 1) {
      _focusPoi(items.first);
      return;
    }
    _controller?.moveCameraToFitPosition(
      [_center, ...items.map((item) => item.position)],
      EdgePadding(top: 60, right: 60, bottom: 60, left: 60),
      const Duration(milliseconds: 300),
    );
  }
}
