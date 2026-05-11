import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';

/// Markers 功能：地图点击添加、点击 Marker 删除（对齐高德 Android 3D Demo 常见交互）。
class AddRemoveMarkerPage extends StatefulWidget {
  const AddRemoveMarkerPage({super.key});

  static const title = 'Markers功能';

  @override
  State<AddRemoveMarkerPage> createState() => _AddRemoveMarkerPageState();
}

class _AddRemoveMarkerPageState extends State<AddRemoveMarkerPage> {
  AMapController? _controller;
  final markers = <String, Marker>{};
  int _markerIdCounter = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.snackBar('点地图空白处添加标记；点已有标记将其删除。');
    });
  }

  Future<void> _preloadPresetMarkers(AMapController c) async {
    await c.waitForMapCompleted();
    if (!mounted || _controller != c) return;
    final icon = Bitmap(asset: 'assets/map-marker.png');
    final preset = <(String, Position)>[
      ('marker_id_1', Position(latitude: 39.984120, longitude: 116.307484)),
      ('marker_id_2', Position(latitude: 39.98380, longitude: 116.30790)),
    ];
    for (final (id, pos) in preset) {
      final m = Marker(id: id, position: pos, bitmap: icon);
      markers[id] = m;
      c.addMarker(m);
    }
    _markerIdCounter = 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AddRemoveMarkerPage.title)),
      body: AMapWidget(
        initCameraPosition: CameraPosition(
          position: Position(latitude: 39.984120, longitude: 116.307484),
          zoom: 17.2,
        ),
        onMapCreated: (c) {
          setState(() => _controller = c);
          _preloadPresetMarkers(c);
        },
        onMapPress: (position) => onTap(position),
        onMapLongPress: (position) => onTap(position),
        onPoiClick: (poi) => onTap(poi.position),
        onMarkerClick: (markerId) => onMarkerClick(markerId),
        onMarkerDragEnd: (markerId, position) =>
            context.alert('${position.latitude}, ${position.longitude}'),
      ),
    );
  }

  void onTap(Position position) {
    final c = _controller;
    if (c == null) return;
    final String markerId = 'marker_id_${_markerIdCounter++}';
    final marker = Marker(
      id: markerId,
      position: position,
      bitmap: Bitmap(asset: 'assets/map-marker.png'),
    );
    markers[markerId] = marker;
    c.addMarker(marker);
  }

  void onMarkerClick(String markerId) {
    final c = _controller;
    if (c == null) return;
    c.removeMarker(markerId);
    markers.remove(markerId);
  }
}
