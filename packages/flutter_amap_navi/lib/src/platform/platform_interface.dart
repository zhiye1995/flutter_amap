part of '../../flutter_amap_navi.dart';

abstract class AMapNaviPlatformInterface extends PlatformInterface {
  AMapNaviPlatformInterface() : super(token: _token);

  static final Object _token = Object();
  static AMapNaviPlatformInterface _instance = AMapNaviMethodChannel();

  static AMapNaviPlatformInterface get instance => _instance;

  static set instance(AMapNaviPlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  final StreamController<NaviEvent<Object?>> naviEventStreamController =
      StreamController<NaviEvent<Object?>>.broadcast();

  Stream<NaviEvent<Object?>> get naviEventStream =>
      naviEventStreamController.stream;

  Stream<NaviInitSuccessEvent> get onNaviInitSuccess =>
      naviEventStream.whereType<NaviInitSuccessEvent>();
  Stream<NaviInitFailureEvent> get onNaviInitFailure =>
      naviEventStream.whereType<NaviInitFailureEvent>();
  Stream<NaviInfoUpdateEvent> get onNaviInfoUpdate =>
      naviEventStream.whereType<NaviInfoUpdateEvent>();
  Stream<NaviLocationChangeEvent> get onNaviLocationChange =>
      naviEventStream.whereType<NaviLocationChangeEvent>();
  Stream<NaviTextEvent> get onNaviText =>
      naviEventStream.whereType<NaviTextEvent>();
  Stream<NaviArriveDestinationEvent> get onNaviArriveDestination =>
      naviEventStream.whereType<NaviArriveDestinationEvent>();
  Stream<NaviStartEvent> get onNaviStart =>
      naviEventStream.whereType<NaviStartEvent>();
  Stream<NaviRouteCalculateSuccessEvent> get onNaviRouteCalculateSuccess =>
      naviEventStream.whereType<NaviRouteCalculateSuccessEvent>();
  Stream<NaviRouteCalculateFailureEvent> get onNaviRouteCalculateFailure =>
      naviEventStream.whereType<NaviRouteCalculateFailureEvent>();
  Stream<NaviReCalculateRouteForYawEvent> get onNaviReCalculateRouteForYaw =>
      naviEventStream.whereType<NaviReCalculateRouteForYawEvent>();
  Stream<NaviReCalculateRouteForTrafficJamEvent>
  get onNaviReCalculateRouteForTrafficJam =>
      naviEventStream.whereType<NaviReCalculateRouteForTrafficJamEvent>();
  Stream<NaviArrivedWayPointEvent> get onNaviArrivedWayPoint =>
      naviEventStream.whereType<NaviArrivedWayPointEvent>();
  Stream<NaviGpsSignalEvent> get onNaviGpsSignal =>
      naviEventStream.whereType<NaviGpsSignalEvent>();
  Stream<NaviTrafficStatusUpdateEvent> get onNaviTrafficStatusUpdate =>
      naviEventStream.whereType<NaviTrafficStatusUpdateEvent>();
  Stream<NaviEndEmulatorEvent> get onNaviEndEmulator =>
      naviEventStream.whereType<NaviEndEmulatorEvent>();
  Stream<NaviExitEvent> get onNaviExit =>
      naviEventStream.whereType<NaviExitEvent>();
  Stream<CruiseTrafficFacilityEvent> get onCruiseTrafficFacility =>
      naviEventStream.whereType<CruiseTrafficFacilityEvent>();
  Stream<CruiseElecCameraInfoEvent> get onCruiseElecCameraInfo =>
      naviEventStream.whereType<CruiseElecCameraInfoEvent>();
  Stream<CruiseTrafficFacilitiesEvent> get onCruiseTrafficFacilities =>
      naviEventStream.whereType<CruiseTrafficFacilitiesEvent>();
  Stream<CruiseStatisticsEvent> get onCruiseStatistics =>
      naviEventStream.whereType<CruiseStatisticsEvent>();
  Stream<CruiseCongestionEvent> get onCruiseCongestion =>
      naviEventStream.whereType<CruiseCongestionEvent>();

  Future<void> initialize(NaviSdkConfig config) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<String> getSdkVersion() {
    throw UnimplementedError('getSdkVersion() has not been implemented.');
  }

  Future<void> startNavigation(NaviConfig config) {
    throw UnimplementedError('startNavigation() has not been implemented.');
  }

  Future<NaviIndependentRouteResult> calculateIndependentRoute(
    NaviIndependentRouteRequest request,
  ) {
    throw UnimplementedError(
      'calculateIndependentRoute() has not been implemented.',
    );
  }

  Future<void> stopNavigation() {
    throw UnimplementedError('stopNavigation() has not been implemented.');
  }

  Future<void> startCruiseMode(CruiseConfig config) {
    throw UnimplementedError('startCruiseMode() has not been implemented.');
  }

  Future<void> stopCruiseMode() {
    throw UnimplementedError('stopCruiseMode() has not been implemented.');
  }
}
