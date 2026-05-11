part of '../flutter_amap.dart';

/// 地图基础配置。
class AMapMapOptions {
  const AMapMapOptions({
    this.mapType,
    this.initCameraPosition,
    this.initFitPositions,
    this.minZoom,
    this.maxZoom,
    this.showTraffic,
    this.showBuildings,
    this.showIndoorMap,
    this.customStyleOptions,
  });

  final MapType? mapType;
  final CameraPosition? initCameraPosition;
  final List<Position>? initFitPositions;
  final double? minZoom;
  final double? maxZoom;
  final bool? showTraffic;
  final bool? showBuildings;
  final bool? showIndoorMap;
  final CustomStyleOptions? customStyleOptions;
}

/// 地图手势配置。
class AMapGestureOptions {
  const AMapGestureOptions({
    this.dragEnable,
    this.zoomEnable,
    this.tiltEnable,
    this.rotateEnable,
  });

  final bool? dragEnable;
  final bool? zoomEnable;
  final bool? tiltEnable;
  final bool? rotateEnable;
}

/// 地图控件配置。
class AMapUiOptions {
  const AMapUiOptions({
    this.compassControlEnabled,
    this.scaleControlEnabled,
    this.zoomControlEnabled,
    this.logoPosition,
    this.compassControlPosition,
    this.scaleControlPosition,
    this.zoomControlPosition,
  });

  final bool? compassControlEnabled;
  final bool? scaleControlEnabled;
  final bool? zoomControlEnabled;
  final UIControlPosition? logoPosition;
  final UIControlPosition? compassControlPosition;
  final UIControlPosition? scaleControlPosition;
  final UIControlPosition? zoomControlPosition;
}

/// 定位显示配置。
class AMapLocationOptions {
  const AMapLocationOptions({
    this.showUserLocation,
    this.geolocationControlEnabled,
    this.userLocationStyle,
  });

  final bool? showUserLocation;
  final bool? geolocationControlEnabled;
  final UserLocationStyle? userLocationStyle;
}

/// SDK 初始化配置。
class AMapSdkConfig {
  const AMapSdkConfig({
    required this.apiKey,
    this.agreePrivacy = true,
    this.preloadNaviIcons = true,
  });

  final ApiKey apiKey;
  final bool agreePrivacy;
  final bool preloadNaviIcons;
}

/// 高德地图
class AMapWidget extends StatefulWidget {
  const AMapWidget({
    super.key,
    this.mapOptions,
    this.gestureOptions,
    this.uiOptions,
    this.locationOptions,
    this.mapType,
    this.initCameraPosition,
    this.initFitPositions,
    this.minZoom,
    this.maxZoom,
    this.dragEnable,
    this.zoomEnable,
    this.tiltEnable,
    this.rotateEnable,
    this.compassControlEnabled,
    this.scaleControlEnabled,
    this.zoomControlEnabled,
    this.logoPosition,
    this.compassControlPosition,
    this.scaleControlPosition,
    this.zoomControlPosition,
    this.showTraffic,
    this.showBuildings = false,
    this.showIndoorMap = false,
    this.showUserLocation,
    this.geolocationControlEnabled,
    this.userLocationStyle,
    this.customStyleOptions,
    this.markers = const {},
    this.polylines = const {},
    this.arcs = const {},
    this.polygons = const {},
    this.onMapCreated,
    this.onMapInitComplete,
    this.onMapCompleted,
    this.onMapPress,
    this.onMapLongPress,
    this.onCameraChange,
    this.onCameraChangeStart,
    this.onCameraChangeFinish,
    this.onMapMoveStart,
    this.onMapMove,
    this.onMapMoveEnd,
    this.onMapResized,
    this.onZoomChange,
    this.onZoomChangeStart,
    this.onZoomChangeEnd,
    this.onRotateChange,
    this.onRotateChangeStart,
    this.onRotateChangeEnd,
    this.onPoiClick,
    this.onMarkerClick,
    this.onMarkerDragStart,
    this.onMarkerDrag,
    this.onMarkerDragEnd,
    this.onUserLocationChange,
  });

  /// 地图基础配置。新代码优先使用该分组参数；同名旧参数仍保留兼容。
  final AMapMapOptions? mapOptions;

  /// 地图手势配置。
  final AMapGestureOptions? gestureOptions;

  /// 地图控件配置。
  final AMapUiOptions? uiOptions;

  /// 定位显示配置。
  final AMapLocationOptions? locationOptions;

  /// 地图类型编号(iOS and Android Only)
  final MapType? mapType;

  /// 地图初始视野
  final CameraPosition? initCameraPosition;

  /// 地图初始视野以适应位置
  final List<Position>? initFitPositions;

  /// 地图最小缩放等级
  final double? minZoom;

  /// 地图最大缩放等级
  final double? maxZoom;

  /// 地图是否允许拖拽
  final bool? dragEnable;

  /// 地图是否允许缩放
  final bool? zoomEnable;

  /// 地图是否允许俯仰
  final bool? tiltEnable;

  /// 地图是否允许旋转
  final bool? rotateEnable;

  /// 是否显示指南针控件
  final bool? compassControlEnabled;

  /// 是否显示比例尺控件
  final bool? scaleControlEnabled;

  /// 是否显示缩放控件(Android)
  final bool? zoomControlEnabled;

  /// Logo位置(Support iOS/Android)
  final UIControlPosition? logoPosition;

  /// 指南针控件位置
  final UIControlPosition? compassControlPosition;

  /// 比例尺控件位置
  final UIControlPosition? scaleControlPosition;

  /// 缩放控件位置(Android)
  final UIControlPosition? zoomControlPosition;

  /// 是否显示实时路况
  final bool? showTraffic;

  /// 是否显示楼块图层
  final bool? showBuildings;

  /// 是否显示室内图层
  final bool? showIndoorMap;

  /// 是否显示当前定位
  final bool? showUserLocation;

  /// 是否显示定位按钮
  final bool? geolocationControlEnabled;

  /// 用户定位样式
  final UserLocationStyle? userLocationStyle;

  /// 离线自定义地图样式（iOS / Android）
  final CustomStyleOptions? customStyleOptions;

  /// 声明式点标记集合。
  final Set<Marker> markers;

  /// 声明式折线集合。
  final Set<Polyline> polylines;

  /// 声明式弧线集合。
  final Set<Arc> arcs;

  /// 声明式多边形集合。
  final Set<Polygon> polygons;

  /// 地图创建完成事件回调函数
  ///
  /// 可以使用参数 [AMapController] 调用地图方法
  final void Function(AMapController)? onMapCreated;

  /// 当地图初始化完成时触发该回调(iOS only)
  final void Function()? onMapInitComplete;

  /// 当地图加载完成时触发该回调
  final void Function()? onMapCompleted;

  /// 当地图点击时触发该回调
  final void Function(Position)? onMapPress;

  /// 当地图长按时触发该回调
  final void Function(Position)? onMapLongPress;

  /// 当地图视野变化时触发该回调(Support iOS/Android)
  final void Function(CameraPosition)? onCameraChange;

  /// 当地图视野开始变化时触发该回调(Support iOS)
  final void Function(CameraPosition)? onCameraChangeStart;

  /// 当地图视野变化结束时触发该回调(Support iOS/Android)
  final void Function(CameraPosition)? onCameraChangeFinish;

  /// 当地图平移开始时触发该回调(iOS)
  final void Function(Position)? onMapMoveStart;

  /// 当地图平移时触发该回调(iOS)
  final void Function(Position)? onMapMove;

  /// 当地图平移结束时触发该回调(iOS)
  final void Function(Position)? onMapMoveEnd;

  /// 当地图容器尺寸改变时触发该回调
  final void Function(Size)? onMapResized;

  /// 当地图缩放级别改变时触发该回调
  final void Function(double)? onZoomChange;

  /// 当地图缩放级别开始改变时触发该回调
  final void Function(double)? onZoomChangeStart;

  /// 当地图缩放级别结束改变时触发该回调
  final void Function(double)? onZoomChangeEnd;

  /// 当地图旋转时触发该回调
  final void Function(double)? onRotateChange;

  /// 当地图旋转开始时触发该回调
  final void Function(double)? onRotateChangeStart;

  /// 当地图旋转结束时触发该回调
  final void Function(double)? onRotateChangeEnd;

  /// 当点击地图上任意的POI时调用，方法会传入点击的POI信息
  final void Function(Poi)? onPoiClick;

  /// 当点击点标记时触发该回调
  final void Function(String markerId)? onMarkerClick;

  /// 当开始拖动点标记时触发该回调
  final void Function(String markerId, Position position)? onMarkerDragStart;

  /// 当拖动点标记时触发该回调
  final void Function(String markerId, Position position)? onMarkerDrag;

  /// 当拖动点标记完成时触发该回调
  final void Function(String markerId, Position position)? onMarkerDragEnd;

  /// 当前位置改变时触发该回调
  final void Function(Location)? onUserLocationChange;

  @override
  createState() => AMapWidgetState();

  /// 初始化 SDK，显示地图前必须调用
  /// 请确保用户设置高德地图SDK API key
  /// 请确保用户同意高德地图SDK隐私协议
  static Future<void> init({
    ApiKey? apiKey,
    AMapSdkConfig? config,
    bool agreePrivacy = true,
  }) async {
    final AMapSdkConfig sdkConfig = config ??
        AMapSdkConfig(
          apiKey: apiKey ?? (throw ArgumentError.notNull("apiKey")),
          agreePrivacy: agreePrivacy,
        );
    await AMapFlutterPlatformInterface.instance.setApiKey(sdkConfig.apiKey);
    await AMapFlutterPlatformInterface.instance.agreePrivacy(
      sdkConfig.agreePrivacy,
    );
    if (sdkConfig.preloadNaviIcons) {
      // 预加载导航图标资源
      NaviInfo.preloadAssetIcons();
    }
  }
}

class AMapWidgetState extends State<AMapWidget> {
  static final defaultUIControlOffset = UIControlOffset(x: 0, y: 0);
  int? mapId;
  bool _platformViewReady = false;

  @override
  Widget build(BuildContext context) {
    final MapInitConfig initConfig = _buildInitConfig();
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: "amap_flutter",
          creationParams: {
            "options": initConfig.encode(),
          },
          creationParamsCodec: const AMapApiCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: "amap_flutter",
          creationParams: {
            "options": initConfig.encode(),
          },
          creationParamsCodec: const AMapApiCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
        );
      default:
        return Text("$defaultTargetPlatform is not supported");
    }
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_platformViewReady || mapId == null) {
      return;
    }
    MapUpdateConfig config = MapUpdateConfig();
    if (_mapType(widget) != null && _mapType(widget) != _mapType(oldWidget)) {
      config.mapType = _mapType(widget);
    }
    if (_dragEnable(widget) != null &&
        _dragEnable(widget) != _dragEnable(oldWidget)) {
      config.dragEnable = _dragEnable(widget);
    }
    if (_zoomEnable(widget) != null &&
        _zoomEnable(widget) != _zoomEnable(oldWidget)) {
      config.zoomEnable = _zoomEnable(widget);
    }
    if (_tiltEnable(widget) != null &&
        _tiltEnable(widget) != _tiltEnable(oldWidget)) {
      config.tiltEnable = _tiltEnable(widget);
    }
    if (_rotateEnable(widget) != null &&
        _rotateEnable(widget) != _rotateEnable(oldWidget)) {
      config.rotateEnable = _rotateEnable(widget);
    }
    if (_compassControlEnabled(widget) != null &&
        _compassControlEnabled(widget) != _compassControlEnabled(oldWidget)) {
      config.compassControlEnabled = _compassControlEnabled(widget);
    }
    if (_scaleControlEnabled(widget) != null &&
        _scaleControlEnabled(widget) != _scaleControlEnabled(oldWidget)) {
      config.scaleControlEnabled = _scaleControlEnabled(widget);
    }
    if (_zoomControlEnabled(widget) != null &&
        _zoomControlEnabled(widget) != _zoomControlEnabled(oldWidget)) {
      config.zoomControlEnabled = _zoomControlEnabled(widget);
    }
    if (_logoPosition(widget) != null &&
        _logoPosition(widget) != _logoPosition(oldWidget)) {
      config.logoPosition = _logoPosition(widget);
    }
    if (_compassControlPosition(widget) != null &&
        _compassControlPosition(widget) != _compassControlPosition(oldWidget)) {
      config.compassControlPosition = _compassControlPosition(widget);
    }
    if (_scaleControlPosition(widget) != null &&
        _scaleControlPosition(widget) != _scaleControlPosition(oldWidget)) {
      config.scaleControlPosition = _scaleControlPosition(widget);
    }
    if (_zoomControlPosition(widget) != null &&
        _zoomControlPosition(widget) != _zoomControlPosition(oldWidget)) {
      config.zoomControlPosition = _zoomControlPosition(widget);
    }
    if (_showTraffic(widget) != null &&
        _showTraffic(widget) != _showTraffic(oldWidget)) {
      config.showTraffic = _showTraffic(widget);
    }
    if (_showBuildings(widget) != null &&
        _showBuildings(widget) != _showBuildings(oldWidget)) {
      config.showBuildings = _showBuildings(widget);
    }
    if (_showIndoorMap(widget) != _showIndoorMap(oldWidget)) {
      config.showIndoorMap = _showIndoorMap(widget);
    }
    if (_geolocationControlEnabled(widget) != null &&
        _geolocationControlEnabled(widget) !=
            _geolocationControlEnabled(oldWidget)) {
      config.userLocationConfig = config.userLocationConfig?.copyWith(
            userLocationButton: _geolocationControlEnabled(widget),
          ) ??
          UserLocationConfig(
            userLocationButton: _geolocationControlEnabled(widget),
          );
    }
    if (_showUserLocation(widget) != null &&
        _showUserLocation(widget) != _showUserLocation(oldWidget)) {
      config.userLocationConfig = config.userLocationConfig?.copyWith(
            showUserLocation: _showUserLocation(widget),
          ) ??
          UserLocationConfig(
            showUserLocation: _showUserLocation(widget),
          );
    }
    if (_userLocationStyleFieldsDiffer(
      _userLocationStyle(widget),
      _userLocationStyle(oldWidget),
    )) {
      config.userLocationConfig = config.userLocationConfig?.copyWith(
            userLocationButton: _geolocationControlEnabled(widget),
            showUserLocation: _showUserLocation(widget),
            userLocationStyle: _userLocationStyle(widget),
          ) ??
          UserLocationConfig(
            userLocationButton: _geolocationControlEnabled(widget),
            showUserLocation: _showUserLocation(widget),
            userLocationStyle: _userLocationStyle(widget),
          );
    }
    if (_customStyleOptions(widget) != _customStyleOptions(oldWidget)) {
      config.customStyleOptions = _customStyleOptions(widget);
    }
    if (_minZoom(widget) != _minZoom(oldWidget)) {
      config.minZoom = _minZoom(widget);
    }
    if (_maxZoom(widget) != _maxZoom(oldWidget)) {
      config.maxZoom = _maxZoom(widget);
    }
    AMapFlutterPlatformInterface.instance.updateMapConfig(
      config,
      mapId: mapId!,
    );
    _syncOverlays(oldWidget);
  }

  AMapController? _controller;

  _onPlatformViewCreated(int id) async {
    mapId = id;
    await AMapFlutterPlatformInterface.instance.init(id, widget);
    _controller = AMapController(widget, mapId: id);
    _platformViewReady = true;

    if (!mounted) {
      _controller?.destroy();
      return;
    }

    _initMap();
    _syncOverlays();
    widget.onMapCreated?.call(_controller!);
  }

  @override
  void dispose() {
    _platformViewReady = false;
    _controller?.destroy();
    super.dispose();
  }

  _initMap() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_platformViewReady || mapId == null) {
        return;
      }
      MapUpdateConfig config = MapUpdateConfig(
        mapType: _mapType(widget),
        dragEnable: _dragEnable(widget),
        zoomEnable: _zoomEnable(widget),
        tiltEnable: _tiltEnable(widget),
        rotateEnable: _rotateEnable(widget),
        compassControlEnabled: _compassControlEnabled(widget),
        scaleControlEnabled: _scaleControlEnabled(widget),
        zoomControlEnabled: _zoomControlEnabled(widget),
        logoPosition: _logoPosition(widget),
        compassControlPosition: _compassControlPosition(widget),
        scaleControlPosition: _scaleControlPosition(widget),
        zoomControlPosition: _zoomControlPosition(widget),
        showTraffic: _showTraffic(widget),
        showBuildings: _showBuildings(widget),
        showIndoorMap: _showIndoorMap(widget),
        userLocationConfig: UserLocationConfig(
          userLocationButton: _geolocationControlEnabled(widget),
          showUserLocation: _showUserLocation(widget),
          userLocationStyle: _userLocationStyle(widget),
        ),
        customStyleOptions: _customStyleOptions(widget),
        minZoom: _minZoom(widget),
        maxZoom: _maxZoom(widget),
      );
      AMapFlutterPlatformInterface.instance.updateMapConfig(
        config,
        mapId: mapId!,
      );
    });
  }

  MapInitConfig _buildInitConfig() {
    return MapInitConfig(
      mapType: _mapType(widget),
      cameraPosition: _initCameraPosition(widget),
      fitPositions: _initFitPositions(widget),
      minZoom: _minZoom(widget),
      maxZoom: _maxZoom(widget),
      dragEnable: _dragEnable(widget),
      zoomEnable: _zoomEnable(widget),
      tiltEnable: _tiltEnable(widget),
      rotateEnable: _rotateEnable(widget),
      compassControlEnabled: _compassControlEnabled(widget),
      scaleControlEnabled: _scaleControlEnabled(widget),
      zoomControlEnabled: _zoomControlEnabled(widget),
      logoPosition: _logoPosition(widget),
      showIndoorMap: _showIndoorMap(widget),
      customStyleOptions: _customStyleOptions(widget),
    );
  }

  void _syncOverlays([AMapWidget? oldWidget]) {
    if (!_platformViewReady || _controller == null) {
      return;
    }
    _syncMarkers(oldWidget?.markers ?? const <Marker>{}, widget.markers);
    _syncPolylines(
        oldWidget?.polylines ?? const <Polyline>{}, widget.polylines);
    _syncArcs(oldWidget?.arcs ?? const <Arc>{}, widget.arcs);
    _syncPolygons(oldWidget?.polygons ?? const <Polygon>{}, widget.polygons);
  }

  void _syncMarkers(Set<Marker> oldMarkers, Set<Marker> newMarkers) {
    final Map<String, Marker> oldById = _markersById(oldMarkers);
    final Map<String, Marker> newById = _markersById(newMarkers);
    for (final id in oldById.keys.where((id) => !newById.containsKey(id))) {
      _controller!.removeMarker(id);
    }
    for (final entry in newById.entries) {
      final Marker? oldMarker = oldById[entry.key];
      if (oldMarker == null) {
        _controller!.addMarker(entry.value);
      } else if (oldMarker != entry.value) {
        _controller!.removeMarker(entry.key);
        _controller!.addMarker(entry.value);
      }
    }
  }

  void _syncPolylines(Set<Polyline> oldLines, Set<Polyline> newLines) {
    final Map<String, Polyline> oldById = _polylinesById(oldLines);
    final Map<String, Polyline> newById = _polylinesById(newLines);
    for (final id in oldById.keys.where((id) => !newById.containsKey(id))) {
      _controller!.removePolyline(id);
    }
    for (final entry in newById.entries) {
      final Polyline? oldLine = oldById[entry.key];
      if (oldLine == null) {
        _controller!.addPolyline(entry.value);
      } else if (oldLine != entry.value) {
        _controller!.removePolyline(entry.key);
        _controller!.addPolyline(entry.value);
      }
    }
  }

  void _syncArcs(Set<Arc> oldArcs, Set<Arc> newArcs) {
    final Map<String, Arc> oldById = _arcsById(oldArcs);
    final Map<String, Arc> newById = _arcsById(newArcs);
    for (final id in oldById.keys.where((id) => !newById.containsKey(id))) {
      _controller!.removeArc(id);
    }
    for (final entry in newById.entries) {
      final Arc? oldArc = oldById[entry.key];
      if (oldArc == null) {
        _controller!.addArc(entry.value);
      } else if (oldArc != entry.value) {
        _controller!.removeArc(entry.key);
        _controller!.addArc(entry.value);
      }
    }
  }

  void _syncPolygons(Set<Polygon> oldPolygons, Set<Polygon> newPolygons) {
    final Map<String, Polygon> oldById = _polygonsById(oldPolygons);
    final Map<String, Polygon> newById = _polygonsById(newPolygons);
    for (final id in oldById.keys.where((id) => !newById.containsKey(id))) {
      _controller!.removePolygon(id);
    }
    for (final entry in newById.entries) {
      final Polygon? oldPolygon = oldById[entry.key];
      if (oldPolygon == null) {
        _controller!.addPolygon(entry.value);
      } else if (oldPolygon != entry.value) {
        _controller!.removePolygon(entry.key);
        _controller!.addPolygon(entry.value);
      }
    }
  }
}

Map<String, Marker> _markersById(Set<Marker> markers) {
  return <String, Marker>{
    for (final marker in markers) marker.id: marker,
  };
}

Map<String, Polyline> _polylinesById(Set<Polyline> polylines) {
  return <String, Polyline>{
    for (final polyline in polylines) polyline.id: polyline,
  };
}

Map<String, Arc> _arcsById(Set<Arc> arcs) {
  return <String, Arc>{
    for (final arc in arcs) arc.id: arc,
  };
}

Map<String, Polygon> _polygonsById(Set<Polygon> polygons) {
  return <String, Polygon>{
    for (final polygon in polygons) polygon.id: polygon,
  };
}

MapType? _mapType(AMapWidget widget) =>
    widget.mapOptions?.mapType ?? widget.mapType;

CameraPosition? _initCameraPosition(AMapWidget widget) =>
    widget.mapOptions?.initCameraPosition ?? widget.initCameraPosition;

List<Position>? _initFitPositions(AMapWidget widget) =>
    widget.mapOptions?.initFitPositions ?? widget.initFitPositions;

double? _minZoom(AMapWidget widget) =>
    widget.mapOptions?.minZoom ?? widget.minZoom;

double? _maxZoom(AMapWidget widget) =>
    widget.mapOptions?.maxZoom ?? widget.maxZoom;

bool? _dragEnable(AMapWidget widget) =>
    widget.gestureOptions?.dragEnable ?? widget.dragEnable;

bool? _zoomEnable(AMapWidget widget) =>
    widget.gestureOptions?.zoomEnable ?? widget.zoomEnable;

bool? _tiltEnable(AMapWidget widget) =>
    widget.gestureOptions?.tiltEnable ?? widget.tiltEnable;

bool? _rotateEnable(AMapWidget widget) =>
    widget.gestureOptions?.rotateEnable ?? widget.rotateEnable;

bool? _compassControlEnabled(AMapWidget widget) =>
    widget.uiOptions?.compassControlEnabled ?? widget.compassControlEnabled;

bool? _scaleControlEnabled(AMapWidget widget) =>
    widget.uiOptions?.scaleControlEnabled ?? widget.scaleControlEnabled;

bool? _zoomControlEnabled(AMapWidget widget) =>
    widget.uiOptions?.zoomControlEnabled ?? widget.zoomControlEnabled;

UIControlPosition? _logoPosition(AMapWidget widget) =>
    widget.uiOptions?.logoPosition ?? widget.logoPosition;

UIControlPosition? _compassControlPosition(AMapWidget widget) =>
    widget.uiOptions?.compassControlPosition ?? widget.compassControlPosition;

UIControlPosition? _scaleControlPosition(AMapWidget widget) =>
    widget.uiOptions?.scaleControlPosition ?? widget.scaleControlPosition;

UIControlPosition? _zoomControlPosition(AMapWidget widget) =>
    widget.uiOptions?.zoomControlPosition ?? widget.zoomControlPosition;

bool? _showTraffic(AMapWidget widget) =>
    widget.mapOptions?.showTraffic ?? widget.showTraffic;

bool? _showBuildings(AMapWidget widget) =>
    widget.mapOptions?.showBuildings ?? widget.showBuildings;

bool? _showIndoorMap(AMapWidget widget) =>
    widget.mapOptions?.showIndoorMap ?? widget.showIndoorMap;

bool? _showUserLocation(AMapWidget widget) =>
    widget.locationOptions?.showUserLocation ?? widget.showUserLocation;

bool? _geolocationControlEnabled(AMapWidget widget) =>
    widget.locationOptions?.geolocationControlEnabled ??
    widget.geolocationControlEnabled;

UserLocationStyle? _userLocationStyle(AMapWidget widget) =>
    widget.locationOptions?.userLocationStyle ?? widget.userLocationStyle;

CustomStyleOptions? _customStyleOptions(AMapWidget widget) =>
    widget.mapOptions?.customStyleOptions ?? widget.customStyleOptions;

/// [UserLocationStyle] 未实现 `==`，用于 [AMapWidgetState.didUpdateWidget] 判断是否需要下发定位样式。
bool _userLocationStyleFieldsDiffer(
  UserLocationStyle? a,
  UserLocationStyle? b,
) {
  if (identical(a, b)) {
    return false;
  }
  if (a == null && b == null) {
    return false;
  }
  if (a == null || b == null) {
    return true;
  }
  if (a.userLocationType != b.userLocationType) {
    return true;
  }
  if (a.fillColor != b.fillColor) {
    return true;
  }
  if (a.strokeColor != b.strokeColor) {
    return true;
  }
  if (a.lineWidth != b.lineWidth) {
    return true;
  }
  if (a.showLocationDot != b.showLocationDot) {
    return true;
  }
  if (a.showsAccuracyRing != b.showsAccuracyRing) {
    return true;
  }
  if (a.showsHeadingIndicator != b.showsHeadingIndicator) {
    return true;
  }
  if (a.locationDotBgColor != b.locationDotBgColor) {
    return true;
  }
  if (a.locationDotFillColor != b.locationDotFillColor) {
    return true;
  }
  if (a.enablePulseAnimation != b.enablePulseAnimation) {
    return true;
  }
  if (a.intervalMs != b.intervalMs) {
    return true;
  }
  final List<Object?>? imageA = a.image?.encode() as List<Object?>?;
  final List<Object?>? imageB = b.image?.encode() as List<Object?>?;
  final List<Object?>? anchorA = a.anchor?.encode() as List<Object?>?;
  final List<Object?>? anchorB = b.anchor?.encode() as List<Object?>?;
  return !listEquals(imageA, imageB) || !listEquals(anchorA, anchorB);
}
