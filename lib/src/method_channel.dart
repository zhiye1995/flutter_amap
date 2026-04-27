part of '../flutter_amap.dart';

/// An implementation of [AMapFlutterPlatformInterface] that uses method channels.
class AMapFlutterMethodChannel extends AMapFlutterPlatformInterface {
  final MethodChannel _initializerChannel = const MethodChannel(
    "plugins.flutter.dev/amap_initializer",
  );

  final Map<int, MethodChannel> _channels = <int, MethodChannel>{};

  /// 导航相关通道
  final MethodChannel _naviChannel = const MethodChannel(
    "plugins.flutter.dev/amap_navi",
  );

  final EventChannel _naviEventChannel = const EventChannel(
    "plugins.flutter.dev/amap_navi_events",
  );

  StreamSubscription<dynamic>? _naviEventSubscription;
  bool _naviEventChannelInitialized = false;

  /// 搜索相关通道
  final MethodChannel _searchChannel = const MethodChannel(
    "plugins.flutter.dev/amap_search",
  );

  /// Accesses the MethodChannel associated to the passed mapId.
  MethodChannel _channel(int mapId) {
    final MethodChannel? channel = _channels[mapId];
    if (channel == null) {
      throw UnknownMapIDError(mapId);
    }
    return channel;
  }

  @override
  Future<void> init(int mapId, AMapWidget? aMapFlutter) async {
    MethodChannel? channel = _channels[mapId];
    if (channel == null) {
      channel = MethodChannel(
        "plugins.flutter.dev/amap_$mapId",
        const StandardMethodCodec(AMapApiCodec()),
      );
      channel.setMethodCallHandler(
        (MethodCall call) => _handleMethodCall(call, mapId),
      );
      _channels[mapId] = channel;
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call, int mapId) async {
    switch (call.method) {
      case "onMapInitCompleted":
        mapEventStreamController.add(MapInitCompleteEvent(mapId));
        break;

      case "onMapCompleted":
        mapEventStreamController.add(MapCompleteEvent(mapId));
        break;

      case "onMapPress":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(MapPressEvent(
          mapId,
          arguments["position"] as Position,
        ));
        break;

      case "onMapDoublePress":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(MapDoublePressEvent(
          mapId,
          arguments["position"] as Position,
        ));
        break;

      case "onMapRightPress":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(MapRightPressEvent(
          mapId,
          arguments["position"] as Position,
        ));
        break;

      case "onMapLongPress":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(MapLongPressEvent(
          mapId,
          arguments["position"] as Position,
        ));
        break;

      case "onCameraChange":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(CameraChangeEvent(
          mapId,
          arguments["camera"] as CameraPosition,
        ));
        break;

      case "onCameraChangeStart":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(CameraChangeStartEvent(
          mapId,
          arguments["camera"] as CameraPosition,
        ));
        break;

      case "onCameraChangeFinish":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(CameraChangeFinishEvent(
          mapId,
          arguments["camera"] as CameraPosition,
        ));
        break;

      case "onMapMoveStart":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(MapMoveStartEvent(
          mapId,
          arguments["position"] as Position,
        ));
        break;

      case "onMapMove":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(MapMoveEvent(
          mapId,
          arguments["position"] as Position,
        ));
        break;

      case "onMapMoveEnd":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(MapMoveEndEvent(
          mapId,
          arguments["position"] as Position,
        ));
        break;

      case "onMapResized":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(MapResizedEvent(
          mapId,
          arguments["size"] as Size,
        ));
        break;

      case "onZoomChange":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(ZoomChangeEvent(
          mapId,
          arguments["zoom"] as double,
        ));
        break;

      case "onZoomChangeStart":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(ZoomChangeStartEvent(
          mapId,
          arguments["zoom"] as double,
        ));
        break;

      case "onZoomChangeEnd":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(ZoomChangeEndEvent(
          mapId,
          arguments["zoom"] as double,
        ));
        break;

      case "onRotateChange":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(RotateChangeEvent(
          mapId,
          arguments["rotate"] as double,
        ));
        break;

      case "onRotateChangeStart":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(RotateChangeStartEvent(
          mapId,
          arguments["rotate"] as double,
        ));
        break;

      case "onRotateChangeEnd":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(RotateChangeEndEvent(
          mapId,
          arguments["rotate"] as double,
        ));
        break;

      case "onMouseMove":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(MouseMoveEvent(
          mapId,
          arguments["position"] as Position,
        ));
        break;

      case "onMouseWheel":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(MouseWheelEvent(
          mapId,
          arguments["zoom"] as double,
        ));
        break;

      case "onMouseOver":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(MouseOverEvent(
          mapId,
          arguments["position"] as Position,
        ));
        break;

      case "onMouseOut":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(MouseOutEvent(
          mapId,
          arguments["position"] as Position,
        ));
        break;

      case "onMouseUp":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(MouseUpEvent(
          mapId,
          arguments["position"] as Position,
        ));
        break;

      case "onMouseDown":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(MouseDownEvent(
          mapId,
          arguments["position"] as Position,
        ));
        break;

      case "onDragStart":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(DragStartEvent(
          mapId,
          arguments["position"] as Position,
        ));
        break;

      case "onDragging":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(DraggingEvent(
          mapId,
          arguments["position"] as Position,
        ));
        break;

      case "onDragEnd":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(DragEndEvent(
          mapId,
          arguments["position"] as Position,
        ));
        break;

      case "onTouchStart":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(TouchStartEvent(
          mapId,
          arguments["position"] as Position,
        ));
        break;

      case "onTouching":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(TouchingEvent(
          mapId,
          arguments["position"] as Position,
        ));
        break;

      case "onTouchEnd":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(TouchEndEvent(
          mapId,
          arguments["position"] as Position,
        ));
        break;

      case "onPoiClick":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(PoiClickEvent(
          mapId,
          arguments["poi"] as Poi,
        ));
        break;

      case "onMarkerClick":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(MarkerClickEvent(
          mapId,
          arguments["markerId"] as String,
        ));
        break;
      case "onMarkerDragStart":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(MarkerDragStartEvent(
          mapId,
          arguments["position"] as Position,
          arguments["markerId"] as String,
        ));
        break;
      case "onMarkerDrag":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(MarkerDragEvent(
          mapId,
          arguments["position"] as Position,
          arguments["markerId"] as String,
        ));
        break;
      case "onMarkerDragEnd":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(MarkerDragEndEvent(
          mapId,
          arguments["position"] as Position,
          arguments["markerId"] as String,
        ));
        break;
      case "onUserLocationChange":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(UserLocationChangeEvent(
          mapId,
          arguments["location"] as Location,
        ));
        break;
      default:
        throw MissingPluginException();
    }
  }

  Map<String, Object?> _getArgumentDictionary(MethodCall call) {
    return (call.arguments as Map<Object?, Object?>).cast<String, Object?>();
  }

  /// 设置SDK Api key，显示地图前必须调用
  @override
  Future<void> setApiKey(ApiKey apiKey) {
    return _initializerChannel.invokeMethod(
      "setApiKey",
      <String, dynamic>{
        "iosKey": apiKey.iosKey,
        "androidKey": apiKey.androidKey,
      },
    );
  }

  /// 同意隐私协议，显示地图前必须调用
  @override
  Future<void> agreePrivacy(bool agree) {
    return _initializerChannel.invokeMethod(
      "agreePrivacy",
      <String, dynamic>{
        "agree": agree,
      },
    );
  }

  /// 设置地图属性
  @override
  Future<void> updateMapConfig(MapUpdateConfig config, {required int mapId}) {
    return _channel(mapId).invokeMethod(
      "updateMapConfig",
      <String, dynamic>{
        "config": config,
      },
    );
  }

  /// 移动地图视野
  @override
  Future<void> moveCamera(
    CameraPosition position,
    int duration, {
    required int mapId,
  }) {
    return _channel(mapId).invokeMethod(
      "moveCamera",
      <String, dynamic>{
        "position": position,
        "duration": duration,
      },
    );
  }

  /// 移动地图视野到某个地图区域
  @override
  Future<void> moveCameraToRegion(
    Region region,
    int duration, {
    required int mapId,
  }) {
    return _channel(mapId).invokeMethod(
      "moveCameraToRegion",
      <String, dynamic>{
        "region": region,
        "duration": duration,
      },
    );
  }

  /// 移动地图视野到包含一组坐标点的某个地图区域
  @override
  Future<void> moveCameraToFitPosition(
    List<Position>? positions,
    EdgePadding padding,
    int duration, {
    required int mapId,
  }) {
    return _channel(mapId).invokeMethod(
      "moveCameraToRegionWithPosition",
      <String, dynamic>{
        "positions": positions,
        "padding": padding,
        "duration": duration,
      },
    );
  }

  /// 限制地图显示区域
  @override
  Future<void> setRestrictRegion(Region region, {required int mapId}) {
    return _channel(mapId).invokeMethod(
      "setRestrictRegion",
      <String, dynamic>{
        "region": region,
      },
    );
  }

  /// 取消地图显示区域限制
  @override
  Future<void> removeRestrictRegion({required int mapId}) {
    return _channel(mapId).invokeMethod("removeRestrictRegion");
  }

  /// 添加标记点
  @override
  Future<void> addMarker(Marker marker, {required int mapId}) {
    return _channel(mapId).invokeMethod(
      "addMarker",
      <String, dynamic>{
        "marker": marker,
      },
    );
  }

  /// 移除标记点
  @override
  Future<void> removeMarker(String id, {required int mapId}) {
    return _channel(mapId).invokeMethod(
      "removeMarker",
      <String, dynamic>{
        "id": id,
      },
    );
  }

  /// 点标记动画
  @override
  Future<void> animateMarker(
    String markerId,
    MarkerAnimationKind kind,
    int durationMs, {
    required int mapId,
  }) {
    return _channel(mapId).invokeMethod(
      "animateMarker",
      <String, dynamic>{
        "markerId": markerId,
        "kind": kind.index,
        "durationMs": durationMs,
      },
    );
  }

  @override
  Future<void> showInfoWindow(String markerId, {required int mapId}) {
    return _channel(mapId).invokeMethod(
      "showInfoWindow",
      <String, dynamic>{"markerId": markerId},
    );
  }

  @override
  Future<void> hideInfoWindow({required int mapId}) {
    return _channel(mapId).invokeMethod("hideInfoWindow");
  }

  /// 获取当前定位信息
  @override
  Future<Location> getUserLocation({required int mapId}) async {
    final result = await _channel(mapId).invokeMethod<Location>("getUserLocation");
    if (result == null) {
      throw StateError(
        "Failed to get user location. "
        "This usually means the native map SDK has not produced a location fix yet, "
        "or location permission was not granted, "
        "or user location display is disabled (showUserLocation/isMyLocationEnabled). "
        "Wait for onUserLocationChange callback/event, and ensure runtime location permission is granted.",
      );
    }
    return result;
  }

  /// 获取当前比例尺（每像素代表多少米）
  @override
  Future<double> getScalePerPixel({required int mapId}) async {
    final result = await _channel(mapId).invokeMethod<double>("getScalePerPixel");
    return result ?? 0.0;
  }

  /// 地图可视区域 PNG 截图
  @override
  Future<Uint8List> takeMapSnapshot({required int mapId}) async {
    final Object? result =
        await _channel(mapId).invokeMethod<Object>("takeMapSnapshot");
    if (result is Uint8List && result.isNotEmpty) {
      return result;
    }
    if (result is List<int>) {
      return Uint8List.fromList(result);
    }
    throw StateError("takeMapSnapshot: unexpected native result");
  }

  @override
  Future<void> stopCameraAnimation({required int mapId}) {
    return _channel(mapId).invokeMethod("stopCameraAnimation");
  }

  /// 开始
  @override
  Future<void> start({required int mapId}) {
    return _channel(mapId).invokeMethod("start");
  }

  /// 暂停
  @override
  Future<void> pause({required int mapId}) {
    return _channel(mapId).invokeMethod("pause");
  }

  /// 恢复
  @override
  Future<void> resume({required int mapId}) {
    return _channel(mapId).invokeMethod("resume");
  }

  /// 销毁
  @override
  Future<void> destroy({required int mapId}) async {
    final MethodChannel? channel = _channels.remove(mapId);
    if (channel == null) {
      // If already disposed (or never initialized), treat as no-op.
      return;
    }
    await channel.invokeMethod("destroy");
  }

  // ==================== 导航相关方法实现 ====================

  /// 初始化导航事件监听
  void _initNaviEventChannel() {
    if (_naviEventChannelInitialized) return;
    _naviEventChannelInitialized = true;

    _naviEventSubscription = _naviEventChannel
        .receiveBroadcastStream()
        .listen(_handleNaviEvent);
  }

  /// 处理导航事件
  void _handleNaviEvent(dynamic event) {
    if (event is! Map) return;
    final Map<String, dynamic> data = Map<String, dynamic>.from(event);
    final String? type = data['type'] as String?;

    switch (type) {
      case 'navInfo':
        naviEventStreamController.add(
          NaviInfoUpdateEvent(NaviInfo.decodeFromMap(data)),
        );
        break;

      case 'initSuccess':
        naviEventStreamController.add(NaviInitSuccessEvent());
        break;

      case 'initFailure':
        // 启动失败，回落到非导航态
        AMapNavi._setIsNavigating(false);
        naviEventStreamController.add(
          NaviInitFailureEvent(data['message'] as String? ?? ''),
        );
        break;

      case 'locationChange':
        naviEventStreamController.add(
          NaviLocationChangeEvent(NaviLocation.decodeFromMap(data)),
        );
        break;

      case 'navigationText':
        naviEventStreamController.add(
          NaviTextEvent(data['text'] as String? ?? ''),
        );
        break;

      case 'arriveDestination':
        // 到达目的地后认为导航结束
        AMapNavi._setIsNavigating(false);
        naviEventStreamController.add(NaviArriveDestinationEvent());
        break;

      case 'startNavi':
        // 导航真正开始（双保险：即使上层没走 startNavigation，也能正确置位）
        AMapNavi._setIsNavigating(true);
        naviEventStreamController.add(
          NaviStartEvent(data['naviType'] as int? ?? 0),
        );
        break;

      case 'calculateRouteSuccess':
        final routeIds = (data['routeIds'] as List?)
            ?.map((e) => e as int)
            .toList() ?? [];
        naviEventStreamController.add(
          NaviRouteCalculateSuccessEvent(routeIds),
        );
        break;

      case 'calculateRouteFailure':
        // 路线计算失败，认为未进入导航态
        AMapNavi._setIsNavigating(false);
        naviEventStreamController.add(
          NaviRouteCalculateFailureEvent(data['errorCode'] as int? ?? -1),
        );
        break;

      case 'reCalculateRouteForYaw':
        naviEventStreamController.add(NaviReCalculateRouteForYawEvent());
        break;

      case 'reCalculateRouteForTrafficJam':
        naviEventStreamController.add(NaviReCalculateRouteForTrafficJamEvent());
        break;

      case 'arrivedWayPoint':
        naviEventStreamController.add(
          NaviArrivedWayPointEvent(data['wayPointIndex'] as int? ?? 0),
        );
        break;

      case 'gpsSignalWeak':
        naviEventStreamController.add(
          NaviGpsSignalEvent(data['isWeak'] as bool? ?? false),
        );
        break;

      case 'trafficStatusUpdate':
        naviEventStreamController.add(NaviTrafficStatusUpdateEvent());
        break;

      case 'endEmulatorNavi':
        // 模拟导航结束
        AMapNavi._setIsNavigating(false);
        naviEventStreamController.add(NaviEndEmulatorEvent());
        break;

      case 'exitPage':
        // 退出导航页
        AMapNavi._setIsNavigating(false);
        naviEventStreamController.add(
          NaviExitEvent(data['exitCode'] as int? ?? 0),
        );
        break;

      case 'cruiseTrafficFacilities':
        final rawList = data['facilities'] as List?;
        final items = <CruiseTrafficFacilityItem>[];
        if (rawList != null) {
          for (final e in rawList) {
            if (e is Map) {
              items.add(
                CruiseTrafficFacilityItem.decodeFromMap(
                  Map<String, dynamic>.from(e),
                ),
              );
            }
          }
        }
        naviEventStreamController.add(CruiseTrafficFacilitiesEvent(items));
        break;

      case 'cruiseStatistics':
        naviEventStreamController.add(
          CruiseStatisticsEvent(
            CruiseStatisticsInfo.decodeFromMap(data),
          ),
        );
        break;

      case 'cruiseCongestion':
        naviEventStreamController.add(
          CruiseCongestionEvent(CruiseCongestionInfo.decodeFromMap(data)),
        );
        break;
    }
  }

  /// 启动导航
  @override
  Future<void> startNavigation(NaviConfig config) async {
    _initNaviEventChannel();
    await _naviChannel.invokeMethod(
      'startNavigation',
      <String, dynamic>{
        'carNumber': config.carNumber,
        'motorcycleCC': config.motorcycleCC,
        'naviType': config.naviType.index,
        'pageType': config.pageType.index,
        'startLat': config.start?.position.latitude,
        'startLng': config.start?.position.longitude,
        'startName': config.start?.name,
        'endLat': config.end?.position.latitude,
        'endLng': config.end?.position.longitude,
        'endName': config.end?.name,
        'wayPoints': config.wayPoints?.map((e) => <String, dynamic>{
          'lat': e.position.latitude,
          'lng': e.position.longitude,
          'name': e.name,
        }).toList(),
      },
    );
  }

  /// 停止导航
  @override
  Future<void> stopNavigation() async {
    await _naviChannel.invokeMethod('stopNavigation');
    _naviEventSubscription?.cancel();
    _naviEventSubscription = null;
    _naviEventChannelInitialized = false;
  }

  @override
  Future<void> startCruiseMode(CruiseBroadcastMode mode) async {
    _initNaviEventChannel();
    await _naviChannel.invokeMethod(
      'startCruiseMode',
      <String, dynamic>{'mode': mode.code},
    );
  }

  @override
  Future<void> stopCruiseMode() async {
    await _naviChannel.invokeMethod('stopCruiseMode');
  }

  // ==================== 搜索相关方法实现 ====================

  /// 请求输入提示
  @override
  Future<List<InputTip>> requestInputTips({
    required String keywords,
    String? city,
    bool cityLimit = false,
    String? types,
    Position? location,
  }) async {
    final result = await _searchChannel.invokeMethod<List<dynamic>>(
      'requestInputTips',
      <String, dynamic>{
        'keywords': keywords,
        'city': city,
        'cityLimit': cityLimit,
        'types': types,
        'latitude': location?.latitude,
        'longitude': location?.longitude,
      },
    );

    if (result == null) {
      return [];
    }

    return result.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return InputTip.decodeFromMap(map);
    }).toList();
  }

  /// 周边 POI 搜索
  @override
  Future<List<PoiItem>> searchPOIAround({
    required Position center,
    String? keywords,
    String? types,
    int? radius,
    int page = 1,
    int pageSize = 20,
    String? city,
  }) async {
    final result = await _searchChannel.invokeMethod<List<dynamic>>(
      'searchPOIAround',
      <String, dynamic>{
        'latitude': center.latitude,
        'longitude': center.longitude,
        'keywords': keywords ?? '',
        'types': types ?? '',
        if (radius != null) 'radius': radius,
        'page': page,
        'pageSize': pageSize,
        'city': city ?? '',
      },
    );

    if (result == null) {
      return [];
    }

    return result.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return PoiItem.decodeFromMap(map);
    }).toList();
  }

  // ==================== 天气相关方法实现 ====================

  /// 查询实时天气
  @override
  Future<LocalWeatherLive> searchWeatherLive({
    required String city,
  }) async {
    final result = await _searchChannel.invokeMethod<Map<dynamic, dynamic>>(
      'searchWeatherLive',
      <String, dynamic>{
        'city': city,
      },
    );

    if (result == null) {
      throw StateError('Failed to get weather live data');
    }

    final map = Map<String, dynamic>.from(result);
    return LocalWeatherLive.decodeFromMap(map);
  }

  /// 查询天气预报
  @override
  Future<LocalWeatherForecast> searchWeatherForecast({
    required String city,
  }) async {
    final result = await _searchChannel.invokeMethod<Map<dynamic, dynamic>>(
      'searchWeatherForecast',
      <String, dynamic>{
        'city': city,
      },
    );

    if (result == null) {
      throw StateError('Failed to get weather forecast data');
    }

    final map = Map<String, dynamic>.from(result);
    return LocalWeatherForecast.decodeFromMap(map);
  }

  /// 根据当前定位查询实时天气
  @override
  Future<LocalWeatherLive> searchWeatherLiveByLocation() async {
    final result = await _searchChannel.invokeMethod<Map<dynamic, dynamic>>(
      'searchWeatherLiveByLocation',
    );

    if (result == null) {
      throw StateError('Failed to get weather live data by location');
    }

    final map = Map<String, dynamic>.from(result);
    return LocalWeatherLive.decodeFromMap(map);
  }

  /// 根据当前定位查询天气预报
  @override
  Future<LocalWeatherForecast> searchWeatherForecastByLocation() async {
    final result = await _searchChannel.invokeMethod<Map<dynamic, dynamic>>(
      'searchWeatherForecastByLocation',
    );

    if (result == null) {
      throw StateError('Failed to get weather forecast data by location');
    }

    final map = Map<String, dynamic>.from(result);
    return LocalWeatherForecast.decodeFromMap(map);
  }
}
