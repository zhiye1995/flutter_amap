part of '../../../flutter_amap.dart';

// ==================== 标记点和POI相关类型 ====================

/// 点标记动画类型（Android 使用高德 [Marker.setAnimation]；iOS 对 [MAAnnotationView] 做 UIView 动画，语义对齐）。
enum MarkerAnimationKind {
  /// 缩放脉冲（偏官方 Demo「呼吸」：1↔略放大 + REVERSE）。
  pulseScale(0),

  /// 绕锚点旋转一周
  rotateOnce(1),

  /// 透明度起伏
  fadePulse(2),

  /// 生长：一次性从 0 缩放到正常尺寸（对齐官方常用 `ScaleAnimation(0,1,0,1)`）。
  growOnce(3),

  /// 移动：沿经纬度短距离移动再复原（Android [TranslateAnimation]；iOS 对 annotation `coordinate` 插值）。
  moveRoundTrip(4);

  const MarkerAnimationKind(this.code);

  /// 跨端通道使用的稳定编码，不能依赖 enum.index。
  final int code;
}

/// 图片信息
class Bitmap {
  Bitmap({
    this.asset,
    this.bytes,
    this.size,
  });

  /// 图片资源路径
  String? asset;

  /// 图片数据
  Uint8List? bytes;

  /// 图片尺寸
  Size? size;

  Object encode() {
    return <Object?>[
      asset,
      bytes,
      size,
    ];
  }

  static Bitmap decode(List<Object?> result) {
    return Bitmap(
      asset: result[0] as String?,
      bytes: result[1] as Uint8List?,
      size: result[2] as Size?,
    );
  }

  Bitmap copyWith({
    String? asset,
    Uint8List? bytes,
    Size? size,
  }) {
    return Bitmap(
      asset: asset ?? this.asset,
      bytes: bytes ?? this.bytes,
      size: size ?? this.size,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Bitmap &&
        asset == other.asset &&
        listEquals(bytes, other.bytes) &&
        size == other.size;
  }

  @override
  int get hashCode => Object.hash(
        asset,
        bytes == null ? null : Object.hashAll(bytes!),
        size,
      );
}

/// 标记点配置属性
class Marker {
  Marker({
    required this.id,
    required this.position,
    this.bitmap,
    this.title,
    this.snippet,
  });

  /// 标记点ID
  String id;

  /// 标记点的位置
  Position position;

  /// 标记点自定义图标信息
  Bitmap? bitmap;

  /// InfoWindow 标题（Android [MarkerOptions.title]；iOS callout `title`）
  String? title;

  /// InfoWindow 副标题（Android [MarkerOptions.snippet]；iOS callout `subtitle`）
  String? snippet;

  Object encode() {
    return <Object?>[
      id,
      position.encode(),
      bitmap?.encode(),
      title,
      snippet,
    ];
  }

  static Marker decode(List<Object?> result) {
    return Marker(
      id: result[0]! as String,
      position: Position.decode(result[1]! as List<Object?>),
      bitmap:
          result[2] != null ? Bitmap.decode(result[2]! as List<Object?>) : null,
      title: result.length > 3 ? result[3] as String? : null,
      snippet: result.length > 4 ? result[4] as String? : null,
    );
  }

  Marker copyWith({
    String? id,
    Position? position,
    Bitmap? bitmap,
    String? title,
    String? snippet,
  }) {
    return Marker(
      id: id ?? this.id,
      position: position ?? this.position,
      bitmap: bitmap ?? this.bitmap,
      title: title ?? this.title,
      snippet: snippet ?? this.snippet,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Marker &&
        id == other.id &&
        position == other.position &&
        bitmap == other.bitmap &&
        title == other.title &&
        snippet == other.snippet;
  }

  @override
  int get hashCode => Object.hash(id, position, bitmap, title, snippet);
}

/// 折线覆盖物配置。
class Polyline {
  Polyline({
    required this.id,
    required this.points,
    this.color = const Color(0xCC00BFFF),
    this.colors = const <Color>[],
    this.width = 10,
    this.visible = true,
    this.gradient = false,
    this.geodesic = false,
    this.useTexture = false,
    this.texture,
    this.textures = const <Bitmap>[],
    this.textureIndexes = const <int>[],
    this.dottedLine = false,
    this.zIndex = 0,
  });

  /// 折线ID
  String id;

  /// 折线坐标点
  List<Position> points;

  /// 折线颜色
  Color color;

  /// 分段颜色。为空时使用 [color] 绘制单色线。
  ///
  /// Android 使用 `PolylineOptions.colorValues`；iOS 使用
  /// `MAMultiColoredPolylineRenderer.strokeColors`。
  List<Color> colors;

  /// 折线宽度
  double width;

  /// 是否可见
  bool visible;

  /// 多彩线是否使用渐变色。
  bool gradient;

  /// 是否按大地曲线绘制。
  ///
  /// Android 对应 `PolylineOptions.geodesic`；iOS 对应
  /// `MAGeodesicPolyline`。多彩线与大地曲线同时设置时，iOS 优先按多彩线绘制。
  bool geodesic;

  /// 是否启用纹理贴图。
  ///
  /// Android 对应 `PolylineOptions.setUseTexture`；iOS 在 [texture] 不为空时
  /// 调用 `MAPolylineRenderer.loadStrokeTextureImage`。iOS 启用纹理后，
  /// 线颜色、端点类型和连接类型等样式由原生 SDK 忽略。
  bool useTexture;

  /// 单一纹理图片。
  ///
  /// 建议使用正方形且宽高为 2 的整数幂的图片，例如 64x64。iOS 普通
  /// 纹理线仅 3D 地图支持。
  Bitmap? texture;

  /// 分段纹理图片列表。
  ///
  /// Android 对应 `PolylineOptions.setCustomTextureList`；iOS 对应
  /// `MAMultiTexturePolylineRenderer.strokeTextureImages`。
  List<Bitmap> textures;

  /// 分段纹理索引。
  ///
  /// Android 对应 `PolylineOptions.setCustomTextureIndex`；iOS 用作
  /// `MAMultiPolyline.drawStyleIndexes`。
  List<int> textureIndexes;

  /// 是否绘制虚线。
  ///
  /// Android 对应 `PolylineOptions.setDottedLine`；iOS 对应
  /// `MAOverlayPathRenderer.lineDashType`。
  bool dottedLine;

  /// 折线层级。
  ///
  /// Android 对应 `PolylineOptions.zIndex`；iOS 会按该值重排折线覆盖物，
  /// 仅保证折线之间的相对层级。
  double zIndex;

  Object encode() {
    return <Object?>[
      id,
      points.map((position) => position.encode()).toList(),
      color.toARGB32(),
      width,
      visible,
      colors.map((color) => color.toARGB32()).toList(),
      gradient,
      geodesic,
      useTexture,
      texture?.encode(),
      textures.map((texture) => texture.encode()).toList(),
      textureIndexes,
      dottedLine,
      zIndex,
    ];
  }

  static Polyline decode(List<Object?> result) {
    return Polyline(
      id: result[0]! as String,
      points: (result[1]! as List<Object?>)
          .map((position) => Position.decode(position! as List<Object?>))
          .toList(),
      color: Color(result[2]! as int),
      width: result[3]! as double,
      visible: result[4]! as bool,
      colors: result.length > 5 && result[5] != null
          ? (result[5]! as List<Object?>)
              .map((color) => Color(color! as int))
              .toList()
          : const <Color>[],
      gradient: result.length > 6 ? result[6]! as bool : false,
      geodesic: result.length > 7 ? result[7]! as bool : false,
      useTexture: result.length > 8 ? result[8]! as bool : false,
      texture: result.length > 9 && result[9] != null
          ? Bitmap.decode(result[9]! as List<Object?>)
          : null,
      textures: result.length > 10 && result[10] != null
          ? (result[10]! as List<Object?>)
              .map((texture) => Bitmap.decode(texture! as List<Object?>))
              .toList()
          : const <Bitmap>[],
      textureIndexes: result.length > 11 && result[11] != null
          ? (result[11]! as List<Object?>)
              .map((index) => index! as int)
              .toList()
          : const <int>[],
      dottedLine: result.length > 12 ? result[12]! as bool : false,
      zIndex: result.length > 13 ? result[13]! as double : 0,
    );
  }

  Polyline copyWith({
    String? id,
    List<Position>? points,
    Color? color,
    List<Color>? colors,
    double? width,
    bool? visible,
    bool? gradient,
    bool? geodesic,
    bool? useTexture,
    Bitmap? texture,
    List<Bitmap>? textures,
    List<int>? textureIndexes,
    bool? dottedLine,
    double? zIndex,
  }) {
    return Polyline(
      id: id ?? this.id,
      points: points ?? this.points,
      color: color ?? this.color,
      colors: colors ?? this.colors,
      width: width ?? this.width,
      visible: visible ?? this.visible,
      gradient: gradient ?? this.gradient,
      geodesic: geodesic ?? this.geodesic,
      useTexture: useTexture ?? this.useTexture,
      texture: texture ?? this.texture,
      textures: textures ?? this.textures,
      textureIndexes: textureIndexes ?? this.textureIndexes,
      dottedLine: dottedLine ?? this.dottedLine,
      zIndex: zIndex ?? this.zIndex,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Polyline &&
        id == other.id &&
        listEquals(points, other.points) &&
        color == other.color &&
        listEquals(colors, other.colors) &&
        width == other.width &&
        visible == other.visible &&
        gradient == other.gradient &&
        geodesic == other.geodesic &&
        useTexture == other.useTexture &&
        texture == other.texture &&
        listEquals(textures, other.textures) &&
        listEquals(textureIndexes, other.textureIndexes) &&
        dottedLine == other.dottedLine &&
        zIndex == other.zIndex;
  }

  @override
  int get hashCode => Object.hashAll(
        <Object?>[
          id,
          Object.hashAll(points),
          color,
          Object.hashAll(colors),
          width,
          visible,
          gradient,
          geodesic,
          useTexture,
          texture,
          Object.hashAll(textures),
          Object.hashAll(textureIndexes),
          dottedLine,
          zIndex,
        ],
      );
}

/// 导航箭头覆盖物配置。
class NavigateArrow {
  NavigateArrow({
    required this.id,
    required this.points,
    this.color = const Color(0xCC00BFFF),
    this.sideColor = const Color(0x6600BFFF),
    this.width = 10,
    this.visible = true,
  });

  /// 导航箭头ID。
  String id;

  /// 导航箭头轨迹点，至少 2 个点才会绘制。
  List<Position> points;

  /// 导航箭头顶部颜色。
  Color color;

  /// 3D 导航箭头侧边颜色。
  Color sideColor;

  /// 导航箭头宽度。
  double width;

  /// 是否可见。
  bool visible;

  Object encode() {
    return <Object?>[
      id,
      points.map((position) => position.encode()).toList(),
      color.toARGB32(),
      sideColor.toARGB32(),
      width,
      visible,
    ];
  }

  static NavigateArrow decode(List<Object?> result) {
    return NavigateArrow(
      id: result[0]! as String,
      points: (result[1]! as List<Object?>)
          .map((position) => Position.decode(position! as List<Object?>))
          .toList(),
      color: Color(result[2]! as int),
      sideColor: Color(result[3]! as int),
      width: result[4]! as double,
      visible: result[5]! as bool,
    );
  }

  NavigateArrow copyWith({
    String? id,
    List<Position>? points,
    Color? color,
    Color? sideColor,
    double? width,
    bool? visible,
  }) {
    return NavigateArrow(
      id: id ?? this.id,
      points: points ?? this.points,
      color: color ?? this.color,
      sideColor: sideColor ?? this.sideColor,
      width: width ?? this.width,
      visible: visible ?? this.visible,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is NavigateArrow &&
        id == other.id &&
        listEquals(points, other.points) &&
        color == other.color &&
        sideColor == other.sideColor &&
        width == other.width &&
        visible == other.visible;
  }

  @override
  int get hashCode => Object.hash(
        id,
        Object.hashAll(points),
        color,
        sideColor,
        width,
        visible,
      );
}

/// 弧线覆盖物配置。
class Arc {
  Arc({
    required this.id,
    required this.start,
    required this.passed,
    required this.end,
    this.color = const Color(0xCC00BFFF),
    this.width = 10,
    this.visible = true,
  });

  /// 弧线ID
  String id;

  /// 起点
  Position start;

  /// 弧线经过点，用于决定弧线弯曲方向和弧度
  Position passed;

  /// 终点
  Position end;

  /// 弧线颜色
  Color color;

  /// 弧线宽度
  double width;

  /// 是否可见
  bool visible;

  Object encode() {
    return <Object?>[
      id,
      start.encode(),
      passed.encode(),
      end.encode(),
      color.toARGB32(),
      width,
      visible,
    ];
  }

  static Arc decode(List<Object?> result) {
    return Arc(
      id: result[0]! as String,
      start: Position.decode(result[1]! as List<Object?>),
      passed: Position.decode(result[2]! as List<Object?>),
      end: Position.decode(result[3]! as List<Object?>),
      color: Color(result[4]! as int),
      width: result[5]! as double,
      visible: result[6]! as bool,
    );
  }

  Arc copyWith({
    String? id,
    Position? start,
    Position? passed,
    Position? end,
    Color? color,
    double? width,
    bool? visible,
  }) {
    return Arc(
      id: id ?? this.id,
      start: start ?? this.start,
      passed: passed ?? this.passed,
      end: end ?? this.end,
      color: color ?? this.color,
      width: width ?? this.width,
      visible: visible ?? this.visible,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Arc &&
        id == other.id &&
        start == other.start &&
        passed == other.passed &&
        end == other.end &&
        color == other.color &&
        width == other.width &&
        visible == other.visible;
  }

  @override
  int get hashCode =>
      Object.hash(id, start, passed, end, color, width, visible);
}

/// 多边形覆盖物配置。
class Polygon {
  Polygon({
    required this.id,
    required this.points,
    this.strokeWidth = 10,
    this.strokeColor = const Color(0xCC00BFFF),
    this.fillColor = const Color(0xC487CEFA),
    this.visible = true,
  });

  /// 多边形ID
  String id;

  /// 多边形坐标点
  List<Position> points;

  /// 边框宽度
  double strokeWidth;

  /// 边框颜色
  Color strokeColor;

  /// 填充颜色
  Color fillColor;

  /// 是否可见
  bool visible;

  Object encode() {
    return <Object?>[
      id,
      points.map((position) => position.encode()).toList(),
      strokeWidth,
      strokeColor.toARGB32(),
      fillColor.toARGB32(),
      visible,
    ];
  }

  static Polygon decode(List<Object?> result) {
    return Polygon(
      id: result[0]! as String,
      points: (result[1]! as List<Object?>)
          .map((position) => Position.decode(position! as List<Object?>))
          .toList(),
      strokeWidth: result[2]! as double,
      strokeColor: Color(result[3]! as int),
      fillColor: Color(result[4]! as int),
      visible: result[5]! as bool,
    );
  }

  Polygon copyWith({
    String? id,
    List<Position>? points,
    double? strokeWidth,
    Color? strokeColor,
    Color? fillColor,
    bool? visible,
  }) {
    return Polygon(
      id: id ?? this.id,
      points: points ?? this.points,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeColor: strokeColor ?? this.strokeColor,
      fillColor: fillColor ?? this.fillColor,
      visible: visible ?? this.visible,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Polygon &&
        id == other.id &&
        listEquals(points, other.points) &&
        strokeWidth == other.strokeWidth &&
        strokeColor == other.strokeColor &&
        fillColor == other.fillColor &&
        visible == other.visible;
  }

  @override
  int get hashCode => Object.hash(
        id,
        Object.hashAll(points),
        strokeWidth,
        strokeColor,
        fillColor,
        visible,
      );
}

/// 地图兴趣点
class Poi {
  Poi({
    required this.name,
    required this.position,
  });

  /// 兴趣点的名称
  String name;

  /// 兴趣点的位置
  Position position;

  Object encode() {
    return <Object?>[
      name,
      position.encode(),
    ];
  }

  static Poi decode(List<Object?> result) {
    return Poi(
      name: result[0]! as String,
      position: Position.decode(result[1]! as List<Object?>),
    );
  }

  Poi copyWith({
    String? name,
    Position? position,
  }) {
    return Poi(
      name: name ?? this.name,
      position: position ?? this.position,
    );
  }
}
