part of '../../../../flutter_amap.dart';

class _LocationPickerEntry {
  const _LocationPickerEntry._({
    required this.title,
    required this.subtitle,
    this.poi,
    this.inputTip,
  });

  factory _LocationPickerEntry.fromInputTip(InputTip tip) {
    return _LocationPickerEntry._(
      title: tip.name,
      subtitle: _locationPickerEntrySubtitle(
        <String?>[tip.district, tip.address],
      ),
      inputTip: tip,
    );
  }

  factory _LocationPickerEntry.fromPoi(PoiItem poi) {
    return _LocationPickerEntry._(
      title: poi.name,
      subtitle: _locationPickerEntrySubtitle(
        <String?>[poi.adName, poi.address],
      ),
      poi: poi,
    );
  }

  final String title;
  final String subtitle;
  final PoiItem? poi;
  final InputTip? inputTip;
}

/// 高德位置选择器全屏页面。
class AMapLocationPicker extends StatefulWidget {
  const AMapLocationPicker({
    super.key,
    this.config = const LocationPickerConfig(),
  });

  final LocationPickerConfig config;

  /// 打开位置选择器。
  static Future<LocationPickerResult?> show(
    BuildContext context, {
    LocationPickerConfig config = const LocationPickerConfig(),
  }) {
    return Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(
        builder: (context) => AMapLocationPicker(config: config),
      ),
    );
  }

  @override
  State<AMapLocationPicker> createState() => _AMapLocationPickerState();
}

class _AMapLocationPickerState extends State<AMapLocationPicker> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final UserLocationStyle _userLocationStyle = UserLocationStyle(
    userLocationType: UserLocationType.locationTypeLocate,
  );

  AMapController? _controller;
  Location? _lastLocation;
  Timer? _debounceTimer;
  List<_LocationPickerEntry> _entries = const <_LocationPickerEntry>[];
  var _isLoading = false;
  var _isResolving = false;
  String? _errorMessage;
  int _searchGeneration = 0;

  LocationPickerConfig get config => widget.config;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    final initialKeyword = config.initialKeyword?.trim();
    if (initialKeyword != null && initialKeyword.isNotEmpty) {
      _searchController.text = initialKeyword;
      _searchByKeyword(initialKeyword);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _controller?.destroy();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      setState(() {
        _entries = const <_LocationPickerEntry>[];
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _debounceTimer = Timer(config.debounceDelay, () {
      _searchByKeyword(keyword);
    });
  }

  Future<void> _searchByKeyword(String keyword) async {
    final generation = ++_searchGeneration;
    try {
      final entries = switch (config.searchMode) {
        LocationPickerSearchMode.poiKeywords => await _searchPoi(keyword),
        LocationPickerSearchMode.inputTips ||
        LocationPickerSearchMode.auto =>
          await _searchInputTips(keyword),
      };

      if (!mounted ||
          generation != _searchGeneration ||
          _searchController.text.trim() != keyword) {
        return;
      }
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted ||
          generation != _searchGeneration ||
          _searchController.text.trim() != keyword) {
        return;
      }
      setState(() {
        _entries = const <_LocationPickerEntry>[];
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<List<_LocationPickerEntry>> _searchInputTips(String keyword) async {
    final tips = await AMapSearch.requestInputTips(
      keywords: keyword,
      city: config.city,
      cityLimit: config.cityLimit,
      types: config.types,
      location: _searchLocation,
    );
    return tips.map(_LocationPickerEntry.fromInputTip).toList();
  }

  Future<List<_LocationPickerEntry>> _searchPoi(String keyword) async {
    final result = await AMapSearch.searchPOIKeywords(
      PoiKeywordSearchQuery(
        keywords: keyword,
        types: config.types,
        city: config.city,
        cityLimit: config.cityLimit,
        pageSize: config.pageSize,
        location: _searchLocation,
        sortByDistance: _searchLocation != null,
      ),
    );
    return result.items.map(_LocationPickerEntry.fromPoi).toList();
  }

  Position? get _searchLocation => config.location ?? _lastLocation?.position;

  Future<void> _onEntryTap(_LocationPickerEntry entry) async {
    if (_isResolving) return;
    setState(() {
      _isResolving = true;
      _errorMessage = null;
    });
    try {
      final result = await _resolveEntry(entry);
      if (!mounted) return;
      Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }

  Future<LocationPickerResult> _resolveEntry(_LocationPickerEntry entry) async {
    final poi = entry.poi;
    if (poi != null) {
      return LocationPickerResult.fromPoi(poi);
    }

    final tip = entry.inputTip;
    if (tip == null) {
      throw StateError('位置结果无效');
    }
    final position = tip.position;
    if (position != null) {
      return LocationPickerResult.fromInputTip(tip, position: position);
    }

    final matchedPoi = await _resolveInputTipPoi(tip);
    if (matchedPoi != null) {
      return LocationPickerResult.fromInputTip(
        tip,
        position: matchedPoi.position,
        poi: matchedPoi,
      );
    }

    final geocodes = await AMapSearch.searchGeocode(
      GeocodeQuery(address: tip.name, city: config.city ?? tip.district),
    );
    if (geocodes.isNotEmpty) {
      return LocationPickerResult.fromInputTip(
        tip,
        position: geocodes.first.position,
      );
    }

    throw StateError('未能解析该地点坐标');
  }

  Future<PoiItem?> _resolveInputTipPoi(InputTip tip) async {
    final result = await AMapSearch.searchPOIKeywords(
      PoiKeywordSearchQuery(
        keywords: tip.name,
        types: config.types ?? tip.typeCode,
        city: config.city ?? tip.adcode ?? tip.district,
        cityLimit: config.cityLimit,
        pageSize: 10,
        location: _searchLocation,
        sortByDistance: _searchLocation != null,
      ),
    );
    if (result.items.isEmpty) return null;
    final poiId = _locationPickerEmptyToNull(tip.poiId);
    if (poiId != null) {
      for (final poi in result.items) {
        if (poi.poiId == poiId) return poi;
      }
    }
    for (final poi in result.items) {
      if (poi.name == tip.name) return poi;
    }
    return result.items.first;
  }

  Future<void> _onCurrentLocation() async {
    if (_isResolving) return;
    setState(() {
      _isResolving = true;
      _errorMessage = null;
    });

    try {
      final controller = _controller;
      final location = _lastLocation ??
          (controller == null
              ? null
              : await controller.waitForUserLocation(
                  timeout: config.currentLocationTimeout,
                ));
      if (location == null) {
        throw StateError('定位尚未就绪');
      }
      _lastLocation = location;

      ReGeocodeResult? reGeocode;
      try {
        reGeocode = await AMapSearch.searchReGeocode(
          ReGeocodeQuery(
            position: location.position,
            extensions: ReGeocodeExtensions.all,
            poiTypes: config.types,
          ),
        );
      } catch (_) {
        reGeocode = null;
      }

      if (!mounted) return;
      Navigator.of(context).pop(
        LocationPickerResult.fromCurrentLocation(
          position: location.position,
          name: config.currentLocationText,
          reGeocode: reGeocode,
        ),
      );
    } on TimeoutException catch (e) {
      if (kDebugMode) print('Failed to get current location: $e');

      if (!mounted) return;
      setState(() {
        _errorMessage = '定位超时，请确认已授予定位权限并稍后重试';
      });
    } catch (e) {
      if (kDebugMode) print('Failed to get current location: $e');

      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              _LocationPickerSearchBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                hintText: config.hintText ?? '搜索地点',
                currentLocationText: config.currentLocationText,
                includeCurrentLocation: config.includeCurrentLocation,
                onBack: () => Navigator.of(context).pop(),
                onCurrentLocation: _onCurrentLocation,
              ),
              Expanded(child: _buildBody()),
            ],
          ),
          Offstage(
            offstage: true,
            child: SizedBox(
              width: 1,
              height: 1,
              child: AMapWidget(
                showUserLocation: config.includeCurrentLocation,
                userLocationStyle: _userLocationStyle,
                initCameraPosition: CameraPosition(position: config.location),
                onMapCreated: (controller) {
                  _controller = controller;
                },
                onUserLocationChange: (location) {
                  _lastLocation = location;
                },
              ),
            ),
          ),
          if (_isResolving)
            const ColoredBox(
              color: Color(0x1F000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = _errorMessage;
    if (error != null) {
      return _LocationPickerMessageView(
        icon: Icons.error_outline,
        title: '搜索失败',
        message: error,
        actionText: _searchController.text.trim().isEmpty ? null : '重试',
        onAction: () => _searchByKeyword(_searchController.text.trim()),
      );
    }

    if (_entries.isEmpty) {
      final hasKeyword = _searchController.text.trim().isNotEmpty;
      return _LocationPickerMessageView(
        icon: hasKeyword ? Icons.location_off_outlined : Icons.search,
        title: hasKeyword ? '未找到相关地点' : '请输入地点名称',
        message: hasKeyword ? '换个关键词试试' : null,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return _LocationPickerResultItem(
          title: entry.title,
          subtitle: entry.subtitle,
          onTap: () => _onEntryTap(entry),
        );
      },
    );
  }
}

class _LocationPickerMessageView extends StatelessWidget {
  const _LocationPickerMessageView({
    required this.icon,
    required this.title,
    this.message,
    this.actionText,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: const Color(0xFFBDBDBD)),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 13,
                ),
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onAction, child: Text(actionText!)),
            ],
          ],
        ),
      ),
    );
  }
}

String _locationPickerEntrySubtitle(List<String?> parts) {
  final text = parts
      .map((part) => part?.trim())
      .whereType<String>()
      .where((part) => part.isNotEmpty)
      .join(' ');
  return text;
}
