part of '../../../amap_flutter.dart';

/// 地图地点选择器配置
class MapPlacePickerConfig {
  const MapPlacePickerConfig({
    this.title,
    this.hintText,
    this.city,
    this.types,
    this.initialPosition,
    this.searchRadius = 1000,
    this.debounceDelay = const Duration(milliseconds: 500),
  });

  /// 标题
  final String? title;

  /// 搜索框提示文字
  final String? hintText;

  /// 搜索城市
  final String? city;

  /// POI 类型限制
  final String? types;

  /// 初始位置（如果不设置则使用当前定位）
  final Position? initialPosition;

  /// 周边搜索半径（米）
  final int searchRadius;

  /// 搜索防抖延迟
  final Duration debounceDelay;
}

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

class _AMapMapPlacePickerState extends State<AMapMapPlacePicker>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  AMapController? _mapController;
  Position? _currentPosition; // 当前定位位置
  Position? _mapCenterPosition; // 地图中心位置
  List<PoiItem> _poiList = [];
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _debounceTimer;

  // 当前选中的 POI 索引
  int _selectedIndex = 0;

  // 是否正在搜索关键词（区分周边搜索和关键词搜索）
  bool _isKeywordSearch = false;

  // 是否是代码触发的地图移动（区分用户手动拖动和代码调用 moveCamera）
  bool _isProgrammaticMove = false;

  // 键盘相关状态
  late KeyboardVisibilityController _keyboardVisibilityController;
  late StreamSubscription<bool> _keyboardSubscription;
  bool _isKeyboardVisible = false;
  double _keyboardHeight = 0;

  MapPlacePickerConfig get config => widget.config;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_onSearchChanged);

    // 初始化键盘可见性监听
    _keyboardVisibilityController = KeyboardVisibilityController();
    _keyboardSubscription =
        _keyboardVisibilityController.onChange.listen((bool visible) {
      setState(() {
        _isKeyboardVisible = visible;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _keyboardSubscription.cancel();
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mapController?.destroy();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // 获取键盘高度
    final bottomInset = WidgetsBinding
        .instance.platformDispatcher.views.first.viewInsets.bottom;
    final devicePixelRatio =
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    final keyboardHeight = bottomInset / devicePixelRatio;

    if (keyboardHeight != _keyboardHeight) {
      setState(() {
        _keyboardHeight = keyboardHeight;
      });
    }
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();

    final keywords = _searchController.text.trim();

    if (keywords.isEmpty) {
      // 关键词为空时，切回周边搜索模式
      setState(() {
        _isKeywordSearch = false;
      });
      if (_mapCenterPosition != null) {
        _searchNearby(_mapCenterPosition!);
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _isKeywordSearch = true;
      _errorMessage = null;
    });

    _debounceTimer = Timer(config.debounceDelay, () {
      _searchByKeywords(keywords);
    });
  }

  /// 用户位置变化回调
  void _onUserLocationChange(Location location) {
    if (_currentPosition == null) {
      _currentPosition = location.position;
      print(
          '用户位置变化回调: ${_currentPosition?.latitude}, ${_currentPosition!.longitude},'
          '地图是否已创建: ${_mapController != null}');
      _mapCenterPosition = location.position;

      // 搜索当前位置周边 POI
      // _searchNearby(location.position);
    }
  }

  /// 地图移动结束回调
  void _onCameraChangeFinish(CameraPosition cameraPosition) {
    // 如果是代码触发的移动，重置标志位并跳过搜索
    if (_isProgrammaticMove) {
      _isProgrammaticMove = false;
      return;
    }
    if(_currentPosition == null) return;

    // 如果正在搜索关键词，不响应地图移动
    if (_isKeywordSearch) return;

    _mapCenterPosition = cameraPosition.position;

    // 防抖搜索
    _debounceTimer?.cancel();
    _debounceTimer = Timer(config.debounceDelay, () {
      _searchNearby(cameraPosition.position!);
    });
  }

  /// 搜索中心点周边 POI
  Future<void> _searchNearby(Position position) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pois = await AMapSearch.searchPOIAround(
        center: position,
        // keywords: '公司|小区|学校|公交|商场|写字楼|酒店|医院|景点|地铁',
        keywords: '',
        // 120000	商务住宅
        // 130000	政府机构及社会团体
        // 140000	科教文化服务
        // 170000	公司企业
        // 190000	地名地址信息
        // 050000	餐饮服务
        // 070000	生活服务
        types: config.types ?? '120000|130000|170000|190000',
        radius: config.searchRadius,
        city: config.city,
      );

      print('搜索中心点周边 POI : types${config.types}, '
          'radius:${config.searchRadius}, city:${config.city}, '
          '结果数量: ${pois.length},'
          'position: ${position.latitude}, ${position.longitude}');

      if (mounted && !_isKeywordSearch) {
        setState(() {
          _poiList = pois;
          _selectedIndex = 0; // 自动选中第一个
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && !_isKeywordSearch) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// 根据关键词搜索
  Future<void> _searchByKeywords(String keywords) async {
    final searchPosition = _mapCenterPosition ?? _currentPosition;
    if (searchPosition == null) return;

    try {
      final pois = await AMapSearch.searchPOIAround(
        center: searchPosition,
        keywords: keywords,
        // types: config.types,
        // radius: config.searchRadius,
        // city: config.city,
      );

      if (mounted && _searchController.text.trim() == keywords) {
        setState(() {
          _poiList = pois;
          _selectedIndex = 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && _searchController.text.trim() == keywords) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// 选中 POI
  void _onPoiSelected(int index) {
    if (index < 0 || index >= _poiList.length) return;

    final poi = _poiList[index];

    setState(() {
      _selectedIndex = index;
    });

    // 标记为代码触发的移动，避免触发周边搜索
    _isProgrammaticMove = true;

    // 移动地图到选中位置
    _mapController?.moveCamera(
      CameraPosition(
        position: poi.position,
        zoom: 16,
      ),
      const Duration(milliseconds: 300),
    );

    // 更新地图中心位置
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
  void _onBackToCurrentLocation() {
    if (_currentPosition != null) {
      // 标记为代码触发的移动，避免触发周边搜索
      _isProgrammaticMove = true;

      _mapController?.moveCamera(
        CameraPosition(
          position: _currentPosition!,
          zoom: 16,
        ),
        const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final platform = defaultTargetPlatform;

    const double borderRadius = 16.0;
    const double keyboardVisiblePanelHeight = 200.0;

    // 根据平台设置键盘动画时长和曲线
    // iOS: 250ms，使用 easeOut 曲线（接近系统 spring 动画）
    // Android: 280ms，使用 easeInOut 曲线
    final Duration animationDuration = platform == TargetPlatform.iOS
        ? const Duration(milliseconds: 250)
        : const Duration(milliseconds: 150);
    final Curve animationCurve =
        platform == TargetPlatform.iOS ? Curves.easeOut : Curves.easeInOut;

    // 底部面板高度：键盘弹出时固定为 200，否则为屏幕高度的 4/9
    final double defaultPanelHeight = mediaQuery.size.height * 4 / 9;
    final double bottomPanelHeight =
        _isKeyboardVisible ? keyboardVisiblePanelHeight : defaultPanelHeight;

    // 地图区域底部位置：
    // 键盘弹出时：总高度 - 键盘高度 - 200 + borderRadius
    // 键盘隐藏时：bottomPanelHeight - borderRadius
    final double mapBottomOffset = _isKeyboardVisible
        ? _keyboardHeight + keyboardVisiblePanelHeight - borderRadius
        : bottomPanelHeight - borderRadius;

    // print(
    //     '构建地图地点选择器页面, 键盘可见: $_isKeyboardVisible, 键盘高度: $_keyboardHeight, 底部面板高度: $bottomPanelHeight, 地图底部偏移: $mapBottomOffset');

    return Scaffold(
      resizeToAvoidBottomInset: false, // 禁止 Scaffold 自动调整大小
      body: Stack(
        children: [
          // 地图区域（使用 AnimatedPositioned 实现动画过渡）
          AnimatedPositioned(
            duration: animationDuration,
            curve: animationCurve,
            top: 0,
            left: 0,
            right: 0,
            bottom: mapBottomOffset,
            child: Stack(
              children: [
                // 地图
                AMapFlutter(
                  showUserLocation: true,
                  // 连续定位，蓝点跟随设备移动，但不自动移动地图中心
                  userLocationStyle: UserLocationStyle(
                    userLocationType: UserLocationType.locationTypeLocate,
                  ),
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
                  /// 当地图视野变化结束时触发该回调(Support iOS/Android)
                  onCameraChangeStart: (cameraPosition) {
                    print("地图开始移动: $cameraPosition");
                  },
                  onCameraChangeFinish: _onCameraChangeFinish,
                ),

                // 中心标记点（固定在地图中央）
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: _buildCenterMarker(),
                  ),
                ),

                // 顶部操作栏
                Positioned(
                  top: mediaQuery.padding.top,
                  left: 0,
                  right: 0,
                  child: _buildTopBar(),
                ),

                // 当前位置按钮
                Positioned(
                  left: 16,
                  bottom: 16 + borderRadius, // 调整位置，避免被底部面板遮挡
                  child: _buildLocationButton(),
                ),
              ],
            ),
          ),

          // 底部面板（使用 AnimatedPositioned 实现动画过渡）
          AnimatedPositioned(
            duration: animationDuration,
            curve: animationCurve,
            left: 0,
            right: 0,
            bottom: _isKeyboardVisible ? _keyboardHeight : 0,
            height: bottomPanelHeight,
            child: AnimatedContainer(
              duration: animationDuration,
              curve: animationCurve,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(borderRadius),
                  topRight: Radius.circular(borderRadius),
                ),
                // 阴影
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 搜索框
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: _buildSearchField(),
                  ),

                  // 分割线
                  const Divider(
                    height: 1,
                    color: Color(0xFFE0E0E0),
                  ),

                  // POI 列表
                  Expanded(
                    child: _buildPoiList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建顶部操作栏
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 取消按钮
          FilledButton(
            onPressed: _onBack,
            style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.grey.withValues(alpha: 0.7)),
            child: const Text('取消'),
          ),

          // 发送/确认按钮
          FilledButton(
            onPressed: _poiList.isNotEmpty ? _onConfirm : null,
            style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                backgroundColor: Colors.green),
            child: const Text('发送'),
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
        // 标记点图标
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF07C160),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        // 标记点下方的小尖角
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
        onTap: _onBackToCurrentLocation,
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

  /// 构建搜索框
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      decoration: InputDecoration(
        hintText: config.hintText ?? '搜索地点',
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF999999),
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                },
                icon: const Icon(
                  Icons.clear,
                  color: Color(0xFF999999),
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFEAE8E8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      textInputAction: TextInputAction.search,
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
              color: Colors.red.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              '搜索失败',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                if (_mapCenterPosition != null) {
                  _searchNearby(_mapCenterPosition!);
                }
              },
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
              color: Colors.black.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '未找到附近地点',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _poiList.length,
      itemBuilder: (context, index) {
        final poi = _poiList[index];
        final isSelected = index == _selectedIndex;
        return _buildPoiItem(poi, index, isSelected);
      },
    );
  }

  /// 构建 POI 列表项
  Widget _buildPoiItem(
    PoiItem poi,
    int index,
    bool isSelected,
  ) {
    // 距离显示
    String distanceText = '';
    if (poi.distance != null && poi.distance! > 0) {
      if (poi.distance! < 1000) {
        distanceText = '${poi.distance}m内';
      } else {
        distanceText = '${(poi.distance! / 1000).toStringAsFixed(1)}km内';
      }
    }

    // 构建地址显示
    String addressText = '';
    final parts = <String>[];
    if (poi.adName != null && poi.adName!.isNotEmpty) {
      parts.add(poi.adName!);
    }
    if (poi.address != null && poi.address!.isNotEmpty) {
      parts.add(poi.address!);
    }
    if (parts.isNotEmpty) {
      addressText = parts.join('');
    }

    // 副标题：距离 | 地址
    String subtitle = '';
    if (distanceText.isNotEmpty && addressText.isNotEmpty) {
      subtitle = '$distanceText | $addressText';
    } else if (distanceText.isNotEmpty) {
      subtitle = distanceText;
    } else if (addressText.isNotEmpty) {
      subtitle = addressText;
    }

    // 文字样式
    const titleStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFF333333),
    );
    const subtitleStyle = TextStyle(
      fontSize: 12,
      color: Color(0xFF999999),
    );
    const highlightStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFF07C160),
    );

    // 搜索关键词高亮
    final searchKeyword = _searchController.text.trim();
    final highlightWords = <String, HighlightedWord>{};
    if (searchKeyword.isNotEmpty && _isKeywordSearch) {
      highlightWords[searchKeyword] = HighlightedWord(
        textStyle: highlightStyle,
      );
    }

    return InkWell(
      onTap: () => _onPoiSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFE0E0E0),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // POI 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (highlightWords.isNotEmpty)
                    TextHighlight(
                      text: poi.name,
                      words: highlightWords,
                      textStyle: titleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      poi.name,
                      style: titleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    if (highlightWords.isNotEmpty)
                      TextHighlight(
                        text: subtitle,
                        words: highlightWords,
                        textStyle: subtitleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        subtitle,
                        style: subtitleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ],
              ),
            ),

            // 选中标记
            if (isSelected)
              const Icon(
                Icons.check,
                color: Color(0xFF07C160),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
