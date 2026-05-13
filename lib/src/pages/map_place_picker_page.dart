part of '../../../flutter_amap.dart';

/// 地图地点选择器页面（仿微信发送位置）
///
/// 全屏页面，包含地图和 POI 列表
/// - 地图中心固定显示标记点
/// - 拖动地图后自动搜索中心点附近 POI
/// - 自动选中第一个 POI
class AMapMapPlacePicker extends StatefulWidget {
  const AMapMapPlacePicker({
    super.key,
    this.config = const MapPlacePickerConfig(),
  });

  /// 配置
  final MapPlacePickerConfig config;

  /// 显示地图地点选择器（全屏页面）
  ///
  /// 返回选中的 [PoiItem]，如果取消则返回 null
  static Future<PoiItem?> show(
    BuildContext context, {
    MapPlacePickerConfig config = const MapPlacePickerConfig(),
  }) {
    return Navigator.of(context).push<PoiItem>(
      MaterialPageRoute(
        builder: (context) => AMapMapPlacePicker(config: config),
      ),
    );
  }

  @override
  State<AMapMapPlacePicker> createState() => _AMapMapPlacePickerState();
}

class _AMapMapPlacePickerState extends State<AMapMapPlacePicker> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final UserLocationStyle _userLocationStyleForPicker = UserLocationStyle(
    userLocationType: UserLocationType.locationTypeLocate,
  );

  AMapController? _mapController;
  Position? _currentPosition;
  Position? _mapCenterPosition;
  List<PoiItem> _poiList = [];
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _keywordDebounceTimer;
  Timer? _cameraDebounceTimer;

  int _selectedIndex = 0;
  bool _isKeywordSearch = false;
  bool _isProgrammaticMove = false;
  bool _isSearchExpanded = false;
  bool _showSearchTextField = false;

  /// 并发搜索代数：仅最新一次搜索允许写回 UI。
  int _searchGeneration = 0;

  /// 上次周边搜索实际使用的中心（用于最小位移阈值）。
  Position? _lastNearbySearchCenter;

  MapPlacePickerConfig get config => widget.config;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    final initial = config.initialPosition;
    if (initial != null) {
      _mapCenterPosition = initial;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _searchNearby(initial);
      });
    }
  }

  @override
  void dispose() {
    _keywordDebounceTimer?.cancel();
    _cameraDebounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mapController?.destroy();
    super.dispose();
  }

  void _onSearchChanged() {
    final keywords = _searchController.text.trim();

    if (keywords.isEmpty) {
      _keywordDebounceTimer?.cancel();
      setState(() {
        _isKeywordSearch = false;
      });
      final center = _mapCenterPosition;
      if (center != null) {
        _searchNearby(
          center,
          showLoading: _poiList.isEmpty,
        );
      }
      return;
    }

    _keywordDebounceTimer?.cancel();
    setState(() {
      _isLoading = true;
      _isKeywordSearch = true;
      _errorMessage = null;
    });

    _keywordDebounceTimer = Timer(config.debounceDelay, () {
      _searchByKeywords(keywords);
    });
  }

  /// 用户位置变化回调
  void _onUserLocationChange(Location location) {
    final firstFix = _currentPosition == null;
    _currentPosition = location.position;

    if (firstFix && config.initialPosition == null) {
      _mapCenterPosition = location.position;
      _searchNearby(location.position);
    }
  }

  /// 地图移动结束回调
  void _onCameraChangeFinish(CameraPosition cameraPosition) {
    if (_isProgrammaticMove) {
      _isProgrammaticMove = false;
      return;
    }

    final position = cameraPosition.position;
    if (position == null) return;

    _mapCenterPosition = position;

    if (_isKeywordSearch || _searchController.text.trim().isNotEmpty) {
      _keywordDebounceTimer?.cancel();
      _searchController.clear();
      return;
    }

    _cameraDebounceTimer?.cancel();
    _cameraDebounceTimer = Timer(config.debounceDelay, () {
      if (!mounted || _isKeywordSearch) return;
      final center = _mapCenterPosition;
      if (center == null) return;
      if (_lastNearbySearchCenter != null &&
          _mapPlacePickerDistanceMeters(_lastNearbySearchCenter!, center) <
              _kMinNearbySearchMoveMeters) {
        return;
      }
      _searchNearby(center);
    });
  }

  /// 搜索中心点周边 POI
  Future<void> _searchNearby(
    Position position, {
    bool showLoading = true,
  }) async {
    final gen = ++_searchGeneration;

    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
    }

    try {
      final pois = await AMapSearch.searchPOIAround(
        center: position,
        keywords: '',
        // types: config.types ?? '120000|130000|170000|190000',
        types: config.types,
        radius: config.searchRadius,
        city: config.city,
      );

      if (!mounted || gen != _searchGeneration) return;
      if (_isKeywordSearch) return;

      setState(() {
        _poiList = pois;
        _selectedIndex = 0;
        _isLoading = false;
        _lastNearbySearchCenter = position;
      });
    } catch (e) {
      if (!mounted || gen != _searchGeneration) return;
      if (_isKeywordSearch) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  /// 根据关键词搜索
  Future<void> _searchByKeywords(String keywords) async {
    final gen = ++_searchGeneration;
    final searchPosition = _mapCenterPosition ?? _currentPosition;

    try {
      final result = await AMapSearch.searchPOIKeywords(
        PoiKeywordSearchQuery(
          keywords: keywords,
          types: config.types,
          city: config.city,
          location: searchPosition,
          sortByDistance: searchPosition != null,
        ),
      );

      if (!mounted || gen != _searchGeneration) return;
      if (_searchController.text.trim() != keywords) return;

      setState(() {
        _poiList = result.items;
        _selectedIndex = 0;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || gen != _searchGeneration) return;
      if (_searchController.text.trim() != keywords) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  /// 选中 POI
  Future<void> _onPoiSelected(int index) async {
    if (index < 0 || index >= _poiList.length) return;

    final poi = _poiList[index];
    final center = _mapCenterPosition;
    final closeEnough = center != null &&
        _mapPlacePickerDistanceMeters(center, poi.position) <
            _kSkipMoveCameraMeters;
    final sameItem = index == _selectedIndex;

    if (sameItem && closeEnough) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });

    if (closeEnough) {
      _mapCenterPosition = poi.position;
      return;
    }

    _isProgrammaticMove = true;
    await _mapController?.moveCamera(
      CameraPosition(
        position: poi.position,
        zoom: 16,
      ),
      const Duration(milliseconds: 300),
    );
    if (!mounted) return;
    _mapCenterPosition = poi.position;
  }

  /// 确认选中
  void _onConfirm() {
    if (_poiList.isNotEmpty && _selectedIndex < _poiList.length) {
      Navigator.of(context).pop(_poiList[_selectedIndex]);
    }
  }

  /// 返回上一页
  void _onBack() {
    Navigator.of(context).pop();
  }

  /// 回到当前位置
  Future<void> _onBackToCurrentLocation() async {
    final pos = _currentPosition;
    if (pos == null) return;

    _isProgrammaticMove = true;
    _mapCenterPosition = pos;

    await _mapController?.moveCamera(
      CameraPosition(
        position: pos,
        zoom: 16,
      ),
      const Duration(milliseconds: 300),
    );
    if (!mounted) return;
    _searchNearby(pos);
  }

  void _onRetrySearch() {
    if (_isKeywordSearch) {
      final kw = _searchController.text.trim();
      if (kw.isNotEmpty) {
        _searchByKeywords(kw);
      }
      return;
    }
    final center = _mapCenterPosition;
    if (center != null) {
      _searchNearby(center);
    }
  }

  void _expandSearchPanel() {
    if (_isSearchExpanded) return;
    setState(() {
      _isSearchExpanded = true;
      _showSearchTextField = false;
    });
  }

  void _collapseSearchPanel() {
    if (!_isSearchExpanded && !_showSearchTextField) return;
    _searchFocusNode.unfocus();
    setState(() {
      _isSearchExpanded = false;
      _showSearchTextField = false;
    });
  }

  void _onSearchPanelAnimationEnd() {
    if (!_isSearchExpanded || _showSearchTextField || !mounted) return;
    setState(() {
      _showSearchTextField = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isSearchExpanded) return;
      _searchFocusNode.requestFocus();
    });
  }

  // 根据屏幕高度估算键盘高度（用于动画时机判断）
  double getEstimatedKeyboardHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    if (height < 700) {
      return height * 0.42;
    } else if (height < 900) {
      return height * 0.38;
    } else {
      return height * 0.34;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取状态栏高度
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final totalHeight = constraints.maxHeight;
          final pickerHeight = (_isSearchExpanded
                  ? getEstimatedKeyboardHeight(context) + 240
                  : totalHeight * 0.4)
              .clamp(0.0, totalHeight);
          final mapHeight = totalHeight - pickerHeight;

          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                height: mapHeight,
                child: Stack(
                  children: [
                    AMapWidget(
                      showUserLocation: true,
                      userLocationStyle: _userLocationStyleForPicker,
                      initCameraPosition: CameraPosition(
                        position: config.initialPosition,
                        zoom: 16,
                      ),
                      zoomControlEnabled: false,
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      onMapCompleted: () {},
                      onUserLocationChange: _onUserLocationChange,
                      onCameraChangeFinish: _onCameraChangeFinish,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: _buildCenterMarker(),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: statusBarHeight,
                      child: _buildTopBar(),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: _buildLocationButton(),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                height: pickerHeight,
                onEnd: _onSearchPanelAnimationEnd,
                child: Column(
                  children: [
                    if (_isSearchExpanded) _buildCollapseSearchButton(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        _isSearchExpanded ? 6 : 12,
                        16,
                        8,
                      ),
                      child: _MapPlacePickerSearchField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        hintText: config.hintText ?? '搜索地点',
                        active: _showSearchTextField,
                        onTapPlaceholder: _expandSearchPanel,
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: Color(0xFFE0E0E0),
                    ),
                    Expanded(
                      child: _buildPoiList(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 构建顶部操作栏
  Widget _buildTopBar() {
    final title = config.title;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            height: 37,
            width: 64,
            child: FilledButton(
              onPressed: _onBack,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.grey.withValues(alpha: 0.7),
              ),
              child: const Text('取消'),
            ),
          ),
          Spacer(),
          SizedBox(
            height: 37,
            width: 64,
            child: FilledButton(
              onPressed: _poiList.isNotEmpty ? _onConfirm : null,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                backgroundColor: Colors.green,
              ),
              child: const Text('发送'),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建中心标记点
  Widget _buildCenterMarker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF07C160),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        CustomPaint(
          size: const ui.Size(12, 8),
          painter: MarkerPointerPainter(
            color: const Color(0xFF07C160),
          ),
        ),
      ],
    );
  }

  /// 构建当前位置按钮
  Widget _buildLocationButton() {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: () => _onBackToCurrentLocation(),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: const Icon(
            Icons.my_location,
            color: Color(0xFF333333),
            size: 20,
          ),
        ),
      ),
    );
  }

  // 构建收起搜索按钮
  Widget _buildCollapseSearchButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Center(
        child: Material(
          color: const Color(0xFFF2F3F5),
          elevation: 1,
          shadowColor: const Color(0x1A000000),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: _collapseSearchPanel,
            borderRadius: BorderRadius.circular(12),
            child: const SizedBox(
              width: 36,
              height: 22,
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF666666),
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建 POI 列表
  Widget _buildPoiList() {
    if (_isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              '搜索失败',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _onRetrySearch,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_poiList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 48,
              color: Colors.black.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '未找到附近地点',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    final keyword = _searchController.text.trim();
    final highlights = _isKeywordSearch && keyword.isNotEmpty
        ? _mapPlacePickerKeywordHighlights(
            keyword,
            _MapPlacePickerPoiListItem.highlightStyle,
          )
        : null;

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _poiList.length,
      itemBuilder: (context, index) {
        final poi = _poiList[index];
        final subtitle = _mapPlacePickerFormatSubtitle(poi);
        return _MapPlacePickerPoiListItem(
          poi: poi,
          index: index,
          isSelected: index == _selectedIndex,
          subtitle: subtitle,
          highlightWords: highlights,
          onTap: (i) => _onPoiSelected(i),
        );
      },
    );
  }
}
