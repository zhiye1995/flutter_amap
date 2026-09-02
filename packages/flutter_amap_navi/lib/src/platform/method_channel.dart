part of '../../flutter_amap_navi.dart';

class AMapNaviMethodChannel extends AMapNaviPlatformInterface {
  final MethodChannel _initializerChannel = const MethodChannel(
    'plugins.flutter.dev/amap_navi_initializer',
  );
  final MethodChannel _naviChannel = const MethodChannel(
    'plugins.flutter.dev/amap_navi',
  );
  final EventChannel _naviEventChannel = const EventChannel(
    'plugins.flutter.dev/amap_navi_events',
  );

  StreamSubscription<dynamic>? _naviEventSubscription;
  bool _naviEventChannelInitialized = false;

  @override
  Future<void> initialize(NaviSdkConfig config) {
    return _initializerChannel
        .invokeMethod<void>('initialize', <String, Object?>{
          'iosKey': config.apiKey.iosKey,
          'androidKey': config.apiKey.androidKey,
          'agreePrivacy': config.agreePrivacy,
        });
  }

  void _initNaviEventChannel() {
    if (_naviEventChannelInitialized) return;
    _naviEventChannelInitialized = true;
    _naviEventSubscription = _naviEventChannel.receiveBroadcastStream().listen(
      _handleNaviEvent,
    );
  }

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
        AMapNavi._setIsNavigating(false);
        naviEventStreamController.add(NaviArriveDestinationEvent());
        break;
      case 'startNavi':
        if (!AMapNavi.isCruising) {
          AMapNavi._setIsNavigating(true);
        }
        naviEventStreamController.add(
          NaviStartEvent(data['naviType'] as int? ?? 0),
        );
        break;
      case 'calculateRouteSuccess':
        final routeIds =
            (data['routeIds'] as List?)?.map((e) => e as int).toList() ?? [];
        naviEventStreamController.add(NaviRouteCalculateSuccessEvent(routeIds));
        break;
      case 'calculateRouteFailure':
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
        AMapNavi._setIsNavigating(false);
        naviEventStreamController.add(NaviEndEmulatorEvent());
        break;
      case 'exitPage':
        AMapNavi._setIsNavigating(false);
        naviEventStreamController.add(
          NaviExitEvent(data['exitCode'] as int? ?? 0),
        );
        break;
      case 'cruiseTrafficFacilities':
        final items = _decodeFacilities(data['facilities']);
        naviEventStreamController.add(CruiseTrafficFacilityEvent(items));
        naviEventStreamController.add(CruiseTrafficFacilitiesEvent(items));
        break;
      case 'cruiseElecCameraInfo':
        final items = _decodeFacilities(data['facilities']);
        naviEventStreamController.add(CruiseElecCameraInfoEvent(items));
        naviEventStreamController.add(CruiseTrafficFacilitiesEvent(items));
        break;
      case 'cruiseStatistics':
        naviEventStreamController.add(
          CruiseStatisticsEvent(CruiseStatisticsInfo.decodeFromMap(data)),
        );
        break;
      case 'cruiseCongestion':
        naviEventStreamController.add(
          CruiseCongestionEvent(CruiseCongestionInfo.decodeFromMap(data)),
        );
        break;
    }
  }

  List<CruiseTrafficFacilityItem> _decodeFacilities(Object? rawValue) {
    final items = <CruiseTrafficFacilityItem>[];
    if (rawValue is List) {
      for (final item in rawValue) {
        if (item is Map) {
          items.add(
            CruiseTrafficFacilityItem.decodeFromMap(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }
    return items;
  }

  @override
  Future<void> startNavigation(NaviConfig config) async {
    _initNaviEventChannel();
    await _naviChannel.invokeMethod<void>('startNavigation', <String, dynamic>{
      'carNumber': config.carNumber,
      'motorcycleCC': config.motorcycleCC,
      'naviType': config.naviType.index,
      'pageType': config.pageType.index,
      'drivingStrategy': config.drivingStrategy.id,
      'travelStrategy': config.travelStrategy,
      'multipleRoute': config.multipleRoute,
      'startNaviDirectly': config.startNaviDirectly,
      'vehicleInfo': config.vehicleInfo?.toMap(),
      'startLat': config.start?.position.latitude,
      'startLng': config.start?.position.longitude,
      'startName': config.start?.name,
      'startPoiId': config.start?.poiId,
      'startAngle': config.start?.startAngle,
      'endLat': config.end?.position.latitude,
      'endLng': config.end?.position.longitude,
      'endName': config.end?.name,
      'endPoiId': config.end?.poiId,
      'endAngle': config.end?.startAngle,
      'wayPoints': config.wayPoints
          ?.map(
            (point) => <String, dynamic>{
              'lat': point.position.latitude,
              'lng': point.position.longitude,
              'name': point.name,
              'poiId': point.poiId,
              'startAngle': point.startAngle,
            },
          )
          .toList(),
    });
  }

  @override
  Future<void> stopNavigation() async {
    await _naviChannel.invokeMethod<void>('stopNavigation');
    await _naviEventSubscription?.cancel();
    _naviEventSubscription = null;
    _naviEventChannelInitialized = false;
  }

  @override
  Future<void> startCruiseMode(CruiseConfig config) async {
    _initNaviEventChannel();
    await _naviChannel.invokeMethod<void>('startCruiseMode', <String, dynamic>{
      'mode': config.mode.code,
      'config': config.encode(),
      'useInnerVoice': config.useInnerVoice,
      'allowsBackgroundLocationUpdates': config.allowsBackgroundLocationUpdates,
      'pausesLocationUpdatesAutomatically':
          config.pausesLocationUpdatesAutomatically,
    });
  }

  @override
  Future<void> stopCruiseMode() {
    return _naviChannel.invokeMethod<void>('stopCruiseMode');
  }
}
