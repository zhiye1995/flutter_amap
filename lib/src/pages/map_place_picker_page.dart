part of '../../../flutter_amap.dart';

const _kMapPlacePickerPanelAnimationDuration = Duration(milliseconds: 280);
const _kMapPlacePickerCameraAnimationDuration = Duration(milliseconds: 300);
const _kMapPlacePickerPanelAnimationCurve = Curves.easeInOutCubic;

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
  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);

  final UserLocationStyle _userLocationStyleForPicker = UserLocationStyle(
    userLocationType: UserLocationType.locationTypeLocate,
  );

  AMapController? _mapController;
  Position? _currentPosition;
  Position? _mapCenterPosition;
  List<PoiItem> _poiList = [];
  List<String> _poiSubtitles = const <String>[];
  bool _isLoading = true;
  String? _errorMessage;
  String? _lastKeywordSearchText;
  Timer? _keywordDebounceTimer;
  Timer? _cameraDebounceTimer;

  bool _isKeywordSearch = false;
  bool _isProgrammaticMove = false;
  bool _isSearchExpanded = false;
  bool _showSearchTextField = false;
  bool _showLoadingOnNextNearbySearch = false;

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
    _selectedIndexNotifier.dispose();
    _mapController?.destroy();
    super.dispose();
  }

  void _onSearchChanged() {
    final keywords = _searchController.text.trim();

    if (keywords.isEmpty) {
      _keywordDebounceTimer?.cancel();
      _lastKeywordSearchText = null;
      if (_isKeywordSearch) {
        setState(() {
          _isKeywordSearch = false;
        });
      }
      final center = _mapCenterPosition;
      if (center != null) {
        final showLoading = _showLoadingOnNextNearbySearch || _poiList.isEmpty;
        _showLoadingOnNextNearbySearch = false;
        _searchNearby(
          center,
          showLoading: showLoading,
        );
      }
      return;
    }

    _keywordDebounceTimer?.cancel();
    final nextNeedsLoading = _lastKeywordSearchText != keywords;
    _lastKeywordSearchText = keywords;
    if (!_isKeywordSearch ||
        (nextNeedsLoading && !_isLoading) ||
        _errorMessage != null) {
      setState(() {
        if (nextNeedsLoading) {
          _isLoading = true;
        }
        _isKeywordSearch = true;
        _errorMessage = null;
      });
    }

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
      _showLoadingOnNextNearbySearch = true;
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
      _searchNearby(center, showLoading: true);
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
        _poiSubtitles = _mapPlacePickerBuildSubtitles(pois);
        _selectedIndexNotifier.value = 0;
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

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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
        _poiSubtitles = _mapPlacePickerBuildSubtitles(result.items);
        _selectedIndexNotifier.value = 0;
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
    final sameItem = index == _selectedIndexNotifier.value;

    if (sameItem && closeEnough) {
      return;
    }

    _selectedIndexNotifier.value = index;

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
      _kMapPlacePickerCameraAnimationDuration,
    );
    if (!mounted) return;
    _mapCenterPosition = poi.position;
  }

  /// 确认选中
  void _onConfirm() {
    final selectedIndex = _selectedIndexNotifier.value;
    if (_poiList.isNotEmpty && selectedIndex < _poiList.length) {
      Navigator.of(context).pop(_poiList[selectedIndex]);
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
      _kMapPlacePickerCameraAnimationDuration,
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
  double getEstimatedKeyboardHeight(double height) {
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
    final mediaPadding = MediaQuery.paddingOf(context);
    final statusBarHeight = mediaPadding.top;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final totalHeight = constraints.maxHeight;
          final pickerHeight = (_isSearchExpanded
                  ? getEstimatedKeyboardHeight(totalHeight) + 240
                  : totalHeight * 0.4)
              .clamp(0.0, totalHeight);
          final mapHeight = totalHeight - pickerHeight;

          return Column(
            children: [
              AnimatedContainer(
                duration: _kMapPlacePickerPanelAnimationDuration,
                curve: _kMapPlacePickerPanelAnimationCurve,
                height: mapHeight,
                child: Stack(
                  children: [
                    RepaintBoundary(
                      child: AMapWidget(
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
                        onUserLocationChange: _onUserLocationChange,
                        onCameraChangeFinish: _onCameraChangeFinish,
                      ),
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
                duration: _kMapPlacePickerPanelAnimationDuration,
                curve: _kMapPlacePickerPanelAnimationCurve,
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
                    Expanded(child: _buildPoiList()),
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
          const Spacer(),
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
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0xFF07C160),
            shape: BoxShape.circle,
            border: Border.fromBorderSide(
              BorderSide(color: Colors.white, width: 2),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox(
            width: 20,
            height: 20,
          ),
        ),
        CustomPaint(
          size: ui.Size(12, 8),
          painter: MarkerPointerPainter(
            color: Color(0xFF07C160),
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
      return const _MapPlacePickerLoadingView();
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
      return const _MapPlacePickerEmptyView();
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
        return _MapPlacePickerPoiListItem(
          poi: poi,
          index: index,
          selectedIndexListenable: _selectedIndexNotifier,
          subtitle: _poiSubtitles[index],
          highlightWords: highlights,
          onTap: _onPoiSelected,
        );
      },
    );
  }
}

class _MapPlacePickerLoadingView extends StatelessWidget {
  const _MapPlacePickerLoadingView();

  @override
  Widget build(BuildContext context) {
    final indicator = const CupertinoActivityIndicator(
      color: Colors.black,
      radius: 16,
    );
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (!isKeyboardVisible) {
      return Center(
        child: indicator,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Align(
        alignment: Alignment.topCenter,
        child: indicator,
      ),
    );
  }
}

class _MapPlacePickerEmptyView extends StatelessWidget {
  const _MapPlacePickerEmptyView();

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    return AnimatedPadding(
      duration: _kMapPlacePickerPanelAnimationDuration,
      curve: _kMapPlacePickerPanelAnimationCurve,
      padding: EdgeInsets.only(top: isKeyboardVisible ? 20 : 0),
      child: AnimatedAlign(
        duration: _kMapPlacePickerPanelAnimationDuration,
        curve: _kMapPlacePickerPanelAnimationCurve,
        alignment: isKeyboardVisible ? Alignment.topCenter : Alignment.center,
        child: const _MapPlacePickerEmptyContent(),
      ),
    );
  }
}

class _MapPlacePickerEmptyContent extends StatelessWidget {
  const _MapPlacePickerEmptyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.location_off,
          size: 45,
          color: Colors.black.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 12),
        Text(
          '未找到附近地点',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
