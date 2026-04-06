import 'package:flutter/material.dart';
import 'package:flutter_amap/flutter_amap.dart';

/// 地图ListView页面 — 模仿官方 Android Demo UI
class MapListViewPage extends StatefulWidget {
  const MapListViewPage({super.key});

  static const title = '地图ListView';

  @override
  State<MapListViewPage> createState() => _MapListViewPageState();
}

class _MapListViewPageState extends State<MapListViewPage> {
  final Position posA = Position(latitude: 39.962773, longitude: 116.391544);
  final Position posB = Position(latitude: 39.922773, longitude: 116.401672);
  final Position posC = Position(latitude: 39.913688, longitude: 116.40223);
  final Position posD = Position(latitude: 39.913129, longitude: 116.392445);

  final List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    for (int i = 0; i < 25; i++) {
      if (i == 3) {
        _items.add({
          'type': 'map',
          'id': i,
          'position': posA,
          'zoom': 18.0,
          'points': [posA, Position(latitude: posA.latitude + 0.00015, longitude: posA.longitude)]
        });
      } else if (i == 5) {
        _items.add({
          'type': 'map',
          'id': i,
          'position': posA,
          'zoom': 15.0,
          'points': [posA, posB, posC, posD]
        });
      } else if (i == 17) {
        _items.add({
          'type': 'map',
          'id': i,
          'position': posA,
          'zoom': 15.0,
          'points': [posA, posB]
        });
      } else if (i == 9) {
        _items.add({
          'type': 'map',
          'id': i,
          'position': posC,
          'zoom': 15.0,
          'points': [posC, posD]
        });
      } else {
        _items.add({
          'type': 'text',
          'id': i,
          'text': '我是列表:$i',
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(MapListViewPage.title),
        centerTitle: true,
      ),
      body: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = _items[index];
          if (item['type'] == 'map') {
            return _MapItemTile(item: item);
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
              child: Text(
                item['text'],
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            );
          }
        },
      ),
    );
  }
}

class _MapItemTile extends StatefulWidget {
  final Map<String, dynamic> item;

  const _MapItemTile({Key? key, required this.item}) : super(key: key);

  @override
  State<_MapItemTile> createState() => _MapItemTileState();
}

class _MapItemTileState extends State<_MapItemTile> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // 缓存地图页面以免上下滑动时重复销毁和重新渲染

  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<Position> points = widget.item['points'];
    return Container(
      height: 250,
      // decoration: BoxDecoration(
      //   color: Colors.grey[200],
      //   // borderRadius: BorderRadius.circular(8),
      //   boxShadow: const [
      //     BoxShadow(
      //       color: Colors.black12,
      //       blurRadius: 4,
      //       offset: Offset(0, 2),
      //     ),
      //   ],
      // ),
      // clipBehavior: Clip.antiAlias,
      child: AMapWidget(
        initCameraPosition: CameraPosition(
          position: widget.item['position'],
          zoom: widget.item['zoom'],
        ),
        onMapCreated: (controller) {
          // 由于 flutter_amap 目前主要使用 Marker，将原 Polylines 替换为展示多个 Marker 以便看到效果
          for (int i = 0; i < points.length; i++) {
            // 在 flutter_amap 中 Marker 的 id 需要保持唯一
            controller.addMarker(Marker(
              id: 'marker_${widget.item['id']}_$i',
              position: points[i],
              // 若没有自定义 asset 图标，这里暂时不传，默认会显示内置大头针
            ));
          }
        },
      ),
    );
  }
}
