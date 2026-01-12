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

class _AMapMapPlacePickerState extends State<AMapMapPlacePicker> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  AMapController? _mapController;
  Position? _currentPosition; // 当前定位位置
  Position? _mapCenterPosition; // 地图中心位置
  List<PoiItem> _poiList = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _debounceTimer;

  // 当前选中的 POI 索引
  int _selectedIndex = 0;

  // 是否正在搜索关键词（区分周边搜索和关键词搜索）
  bool _isKeywordSearch = false;

  MapPlacePickerConfig get config => widget.config;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mapController?.destroy();
    super.dispose();
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

  /// 地图创建完成回调
  void _onMapCreated(AMapController controller) {
    print("地图创建完成回调");
    _mapController = controller;
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
      _searchNearby(location.position);
    }
  }

  /// 地图移动结束回调
  void _onCameraChangeFinish(CameraPosition cameraPosition) {
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
        keywords: '',
        types: config.types,
        radius: config.searchRadius,
        city: config.city,
      );

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
        types: config.types,
        radius: config.searchRadius,
        city: config.city,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      body: Column(
        children: [
          // 地图区域
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                // 地图
                AMapFlutter(
                  showUserLocation: true,
                  // 连续定位，蓝点跟随设备移动，但不自动移动地图中心
                  userLocationStyle: UserLocationStyle(
                    //   ///定位一次，且将视角移动到地图中心点
                    //   locationTypeLocate,
                    //
                    //   ///连续定位、且将视角移动到地图中心点，定位蓝点跟随设备移动。（1秒1次定位）
                    //   locationTypeFollow,
                    //
                    //   ///连续定位、且将视角移动到地图中心点，地图依照设备方向旋转，定位点会跟随设备移动。（1秒1次定位）
                    //   locationTypeMapRotate,
                    userLocationType: UserLocationType.locationTypeLocate,
                  ),
                  initCameraPosition: CameraPosition(
                    zoom: 16,
                  ),
                  zoomControlEnabled: true,
                  zoomControlPosition: UIControlPosition(
                    anchor: UIControlAnchor.centerRight,
                    offset: UIControlOffset(x: 10, y: 0),
                  ),
                  onMapCreated: _onMapCreated,
                  onMapCompleted: () {},
                  onUserLocationChange: _onUserLocationChange,
                  onCameraChangeFinish: _onCameraChangeFinish,
                ),

                // 中心标记点（固定在地图中央）
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: _buildCenterMarker(colorScheme),
                  ),
                ),

                // 顶部操作栏
                Positioned(
                  top: mediaQuery.padding.top,
                  left: 0,
                  right: 0,
                  child: _buildTopBar(colorScheme),
                ),

                // 当前位置按钮
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: _buildLocationButton(colorScheme),
                ),
              ],
            ),
          ),

          // 底部面板
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
                    child: _buildSearchField(colorScheme),
                  ),

                  // 分割线
                  Divider(
                    height: 1,
                    color: colorScheme.outline.withOpacity(0.2),
                  ),

                  // POI 列表
                  Expanded(
                    child: _buildPoiList(theme, colorScheme),
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
  Widget _buildTopBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 取消按钮
          TextButton(
            onPressed: _onBack,
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurface,
            ),
            child: const Text('取消'),
          ),

          // 发送/确认按钮
          FilledButton(
            onPressed: _poiList.isNotEmpty ? _onConfirm : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }

  /// 构建中心标记点
  Widget _buildCenterMarker(ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标记点图标
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF07C160),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
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
          painter: _MarkerPointerPainter(
            color: const Color(0xFF07C160),
          ),
        ),
      ],
    );
  }

  /// 构建当前位置按钮
  Widget _buildLocationButton(ColorScheme colorScheme) {
    return Material(
      color: colorScheme.surface,
      elevation: 2,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: _onBackToCurrentLocation,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            Icons.my_location,
            color: colorScheme.primary,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// 构建搜索框
  Widget _buildSearchField(ColorScheme colorScheme) {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      decoration: InputDecoration(
        hintText: config.hintText ?? '搜索地点',
        prefixIcon: Icon(
          Icons.search,
          color: colorScheme.onSurface.withOpacity(0.5),
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                },
                icon: Icon(
                  Icons.clear,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              )
            : null,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
  Widget _buildPoiList(ThemeData theme, ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
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
              color: colorScheme.error.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              '搜索失败',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.5),
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
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '未找到附近地点',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
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
        return _buildPoiItem(poi, index, isSelected, theme, colorScheme);
      },
    );
  }

  /// 构建 POI 列表项
  Widget _buildPoiItem(
    PoiItem poi,
    int index,
    bool isSelected,
    ThemeData theme,
    ColorScheme colorScheme,
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

    return InkWell(
      onTap: () => _onPoiSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outline.withOpacity(0.1),
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
                  Text(
                    poi.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // 选中标记
            if (isSelected)
              Icon(
                Icons.check,
                color: const Color(0xFF07C160),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

/// 标记点下方小尖角绘制器
class _MarkerPointerPainter extends CustomPainter {
  _MarkerPointerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, ui.Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
