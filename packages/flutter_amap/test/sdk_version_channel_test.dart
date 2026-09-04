import 'package:flutter/services.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const initializerChannel = MethodChannel(
    'plugins.flutter.dev/amap_initializer',
  );

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(initializerChannel, null);
  });

  test('gets the native map SDK version', () async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(initializerChannel, (call) async {
      expect(call.method, 'getSdkVersion');
      return '11.2.100';
    });

    expect(await AMapWidget.sdkVersion, '11.2.100');
  });
}
