import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';

/// POI 关键字搜索：对齐高德 `PoiSearch.Query` / `AMapPOIKeywordsSearchRequest` 参数。
class PoiKeywordSearchPage extends StatefulWidget {
  const PoiKeywordSearchPage({super.key});

  static const title = 'poi关键字搜索';

  @override
  State<PoiKeywordSearchPage> createState() => _PoiKeywordSearchPageState();
}

class _PoiKeywordSearchPageState extends State<PoiKeywordSearchPage> {
  static final _beijingCenter =
      Position(latitude: 39.908722, longitude: 116.397499);

  final _keywordController = TextEditingController(text: '天安门');
  final _cityController = TextEditingController(text: '北京');
  final _typesController = TextEditingController();
  final _pageSizeController = TextEditingController(text: '10');

  AMapController? _controller;
  Timer? _tipsDebounce;
  Position? _searchCenter = _beijingCenter;
  PoiSearchResult? _result;
  List<InputTip> _tips = const <InputTip>[];
  var _page = 1;
  var _cityLimit = true;
  var _useExtension = false;
  var _children = false;
  var _sortByDistance = true;
  var _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _keywordController.addListener(_onKeywordChanged);
  }

  @override
  void dispose() {
    _keywordController.removeListener(_onKeywordChanged);
    _keywordController.dispose();
    _cityController.dispose();
    _typesController.dispose();
    _pageSizeController.dispose();
    _tipsDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(PoiKeywordSearchPage.title)),
      body: Column(
        children: [
          SizedBox(
            height: 220,
            child: AMapWidget(
              initCameraPosition: CameraPosition(
                position: _beijingCenter,
                zoom: 13,
              ),
              markers: _resultMarkers,
              onMapCreated: (controller) => _controller = controller,
              onCameraChangeFinish: (camera) {
                if (camera.position != null) {
                  setState(() => _searchCenter = camera.position);
                }
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _buildSearchCard(),
                if (_tips.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildTipsCard(),
                ],
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

  Set<Marker> get _resultMarkers {
    final items = _result?.items ?? const <PoiItem>[];
    return <Marker>{
      for (var i = 0; i < items.length; i++)
        Marker(
          id: 'poi_keyword_$i',
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
            TextField(
              controller: _keywordController,
              decoration: const InputDecoration(
                labelText: '关键字',
                hintText: '例如：天安门|故宫',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(resetPage: true),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: '城市 / citycode / adcode',
                      hintText: '北京 或 010 或 110000',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 96,
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
            const SizedBox(height: 10),
            TextField(
              controller: _typesController,
              decoration: const InputDecoration(
                labelText: 'POI 类型（可选）',
                hintText: '类型名或编码，多个用 | 分隔，如 050000|060000',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                FilterChip(
                  label: const Text('城市限制'),
                  selected: _cityLimit,
                  onSelected: (value) => setState(() => _cityLimit = value),
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
                FilterChip(
                  label: const Text('按地图中心距离排序'),
                  selected: _sortByDistance,
                  onSelected: (value) =>
                      setState(() => _sortByDistance = value),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _searchCenter == null
                  ? '未设置中心点'
                  : '中心点：${_searchCenter!.latitude.toStringAsFixed(6)}, '
                      '${_searchCenter!.longitude.toStringAsFixed(6)}',
              style: Theme.of(context).textTheme.bodySmall,
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
              label: Text(_loading ? '搜索中...' : '搜索 POI'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Card(
      child: Column(
        children: [
          const ListTile(
            dense: true,
            title: Text('输入提示'),
            subtitle: Text('点选后会回填关键字，并使用提示坐标作为搜索中心'),
          ),
          for (final tip in _tips.take(5))
            ListTile(
              dense: true,
              title: Text(tip.name),
              subtitle: Text(tip.address ?? tip.district ?? '无地址'),
              trailing: const Icon(Icons.north_west, size: 18),
              onTap: () => _applyTip(tip),
            ),
        ],
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
            child: Center(child: Text('请输入关键字后搜索')),
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
                if (item.tel != null && item.tel!.isNotEmpty) '电话：${item.tel}',
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

  void _onKeywordChanged() {
    _tipsDebounce?.cancel();
    final keywords = _keywordController.text.trim();
    if (keywords.isEmpty) {
      setState(() => _tips = const <InputTip>[]);
      return;
    }
    _tipsDebounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final tips = await AMapSearch.requestInputTips(
          keywords: keywords,
          city: _cityController.text.trim(),
          cityLimit: _cityLimit,
          types: _typesController.text.trim().isEmpty
              ? null
              : _typesController.text.trim(),
          location: _searchCenter,
        );
        if (mounted && _keywordController.text.trim() == keywords) {
          setState(() => _tips = tips);
        }
      } catch (_) {
        if (mounted) setState(() => _tips = const <InputTip>[]);
      }
    });
  }

  void _applyTip(InputTip tip) {
    _keywordController.text = tip.name;
    if (tip.position != null) {
      setState(() => _searchCenter = tip.position);
      _controller?.moveCamera(
        CameraPosition(position: tip.position, zoom: 16),
      );
    }
    setState(() => _tips = const <InputTip>[]);
  }

  Future<void> _search({required bool resetPage}) async {
    final keywords = _keywordController.text.trim();
    final types = _typesController.text.trim();
    if (keywords.isEmpty && types.isEmpty) {
      LoadingUtil.showToast('请输入关键字或 POI 类型');
      return;
    }
    if (resetPage) _page = 1;

    setState(() {
      _loading = true;
      _errorMessage = null;
      _tips = const <InputTip>[];
    });

    try {
      final result = await AMapSearch.searchPOIKeywords(
        PoiKeywordSearchQuery(
          keywords: keywords,
          types: types.isEmpty ? null : types,
          city: _cityController.text.trim().isEmpty
              ? null
              : _cityController.text.trim(),
          cityLimit: _cityLimit,
          page: _page,
          pageSize: int.tryParse(_pageSizeController.text.trim()) ?? 10,
          location: _sortByDistance ? _searchCenter : null,
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
      LoadingUtil.showError('POI 搜索失败: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
      items.map((item) => item.position).toList(),
      EdgePadding(top: 60, right: 60, bottom: 60, left: 60),
      const Duration(milliseconds: 300),
    );
  }
}
