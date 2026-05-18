package com.morbit.amap_flutter

import android.graphics.Color

/** 地图类型 */
enum class MapType(val raw: Int) {
  STANDARD(0),
  SATELLITE(1),
  STANDARD_NIGHT(2),
  NAVI(3),
  BUS(4),
  NAVI_NIGHT(5);

  companion object {
    fun ofRaw(raw: Int): MapType? {
      return MapType.values().firstOrNull { it.raw == raw }
    }
  }
}

/** UI控件位置锚点 */
enum class UIControlAnchor(val raw: Int) {
  TOP_LEFT(0),
  TOP_CENTER(1),
  TOP_RIGHT(2),
  CENTER_LEFT(3),
  CENTER(4),
  CENTER_RIGHT(5),
  BOTTOM_LEFT(6),
  BOTTOM_CENTER(7),
  BOTTOM_RIGHT(8);

  companion object {
    fun ofRaw(raw: Int): UIControlAnchor? {
      return UIControlAnchor.values().firstOrNull { it.raw == raw }
    }
  }
}

/** 用户定位类型 */
enum class UserLocationType(val raw: Int) {
  ///只定位一次（Android Only）
  LOCATION_TYPE_SHOW(0),

  ///定位一次，且将视角移动到地图中心点
  LOCATION_TYPE_LOCATE(1),

  ///连续定位、且将视角移动到地图中心点，定位蓝点跟随设备移动。（1秒1次定位）
  LOCATION_TYPE_FOLLOW(2),

  ///连续定位、且将视角移动到地图中心点，地图依照设备方向旋转，定位点会跟随设备移动。（1秒1次定位）
  LOCATION_TYPE_MAP_ROTATE(3),

  ///连续定位、且将视角移动到地图中心点，定位点依照设备方向旋转，并且会跟随设备移动。（1秒1次定位）默认执行此种模式（Android Only）
  LOCATION_TYPE_LOCATION_ROTATE(4),

  ///连续定位、蓝点不会移动到地图中心点，定位点依照设备方向旋转，并且蓝点会跟随设备移动（Android Only）
  LOCATION_TYPE_LOCATION_ROTATE_NO_CENTER(5),

  ///连续定位、蓝点不会移动到地图中心点，并且蓝点会跟随设备移动（Android Only）
  LOCATION_TYPE_FOLLOW_NO_CENTER(6),

  ///连续定位、蓝点不会移动到地图中心点，地图依照设备方向旋转，并且蓝点会跟随设备移动（Android Only）
  LOCATION_TYPE_MAP_ROTATE_NO_CENTER(7);

  companion object {
    fun ofRaw(raw: Int): UserLocationType? {
      return UserLocationType.values().firstOrNull { it.raw == raw }
    }
  }
}

/** 点标记图标锚点 */
data class Anchor(
  /** 点标记图标锚点的X坐标 */
  val x: Double,
  /** 点标记图标锚点的Y坐标 */
  val y: Double
) {
  companion object {
    fun fromList(list: List<Any?>): Anchor {
      val x = list[0] as Double
      val y = list[1] as Double
      return Anchor(x, y)
    }
  }

  fun toList(): List<Any?> {
    return listOf(
      x,
      y,
    )
  }
}

/** 图片信息 */
data class Bitmap(
  /** 图片资源路径 */
  val asset: String? = null,
  /** 图片数据 */
  val bytes: ByteArray? = null,
  /** 图片尺寸 */
  val size: Size? = null,
) {
  companion object {
    fun fromList(list: List<Any?>): Bitmap {
      val asset = list[0] as String?
      val bytes = list[1] as ByteArray?
      val size = list[2] as Size?
      return Bitmap(asset, bytes, size)
    }
  }

  fun toList(): List<Any?> {
    return listOf(
      asset,
      bytes,
      size,
    )
  }

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (javaClass != other?.javaClass) return false

    other as Bitmap

    if (asset != other.asset) return false
    if (bytes != null) {
      if (other.bytes == null) return false
      if (!bytes.contentEquals(other.bytes)) return false
    } else if (other.bytes != null) return false
    if (size != other.size) return false

    return true
  }

  override fun hashCode(): Int {
    var result = asset?.hashCode() ?: 0
    result = 31 * result + (bytes?.contentHashCode() ?: 0)
    result = 31 * result + (size?.hashCode() ?: 0)
    return result
  }
}

/** 地图视野 */
data class CameraPosition(
  /** 地图视野的位置 */
  val position: Position? = null,
  /** 地图视野的旋转角度 */
  val heading: Double? = null,
  /** 地图视野的倾斜角度 */
  val skew: Double? = null,
  /** 地图视野的缩放级别 */
  val zoom: Double? = null
) {
  companion object {
    fun fromList(list: List<Any?>): CameraPosition {
      val position = (list[0] as List<Any?>?)?.let { Position.fromList(it) }
      val heading = list[1] as Double?
      val skew = list[2] as Double?
      val zoom = list[3] as Double?
      return CameraPosition(position, heading, skew, zoom)
    }
  }

  fun toList(): List<Any?> {
    return listOf(
      position?.toList(),
      heading,
      skew,
      zoom,
    )
  }
}

/** 视野边缘宽度 */
data class EdgePadding(
  /** 左边缘宽度 */
  val left: Double,
  /** 上边缘宽度 */
  val top: Double,
  /** 右边缘宽度 */
  val right: Double,
  /** 下边缘宽度 */
  val bottom: Double,
) {
  companion object {
    fun fromList(list: List<Any?>): EdgePadding {
      val left = list[0] as Double
      val top = list[1] as Double
      val right = list[2] as Double
      val bottom = list[3] as Double
      return EdgePadding(left, top, right, bottom)
    }
  }

  fun toList(): List<Any?> {
    return listOf(
      left,
      top,
      right,
      bottom,
    )
  }
}

/** 定位点 */
data class Location(
  /** 定位点的位置 */
  val position: Position? = null,
  /** 定位点的方向 */
  val heading: Double? = null,
  /** 定位点的精确度 */
  val accuracy: Double? = null
) {
  companion object {
    fun fromList(list: List<Any?>): Location {
      val position = (list[0] as List<Any?>?)?.let { Position.fromList(it) }
      val heading = list[1] as Double?
      val accuracy = list[2] as Double?
      return Location(position, heading, accuracy)
    }
  }

  fun toList(): List<Any?> {
    return listOf(
      position?.toList(),
      heading,
      accuracy,
    )
  }
}

/** 离线自定义地图样式（对应 style.data / style_extra.data） */
data class CustomStyleOptions(
  val enabled: Boolean,
  val styleData: ByteArray? = null,
  val styleExtraData: ByteArray? = null,
) {
  companion object {
    fun fromList(list: List<Any?>): CustomStyleOptions {
      val enabled = list[0] as Boolean
      val styleData = list[1] as? ByteArray
      val styleExtraData = list[2] as? ByteArray
      return CustomStyleOptions(enabled, styleData, styleExtraData)
    }
  }

  fun toList(): List<Any?> = listOf(enabled, styleData, styleExtraData)
}

/** 地图初始化属性配置 **/
data class MapInitConfig(
  /** 地图类型 */
  val mapType: MapType?,
  /** 地图视野 */
  val cameraPosition: CameraPosition?,
  /** 地图视野以适应位置 */
  val fitPositions: List<Position>?,
  /** 地图最小缩放等级 */
  val minZoom: Double?,
  /** 地图最大缩放等级 */
  val maxZoom: Double?,
  /** 地图是否允许拖拽 */
  val dragEnable: Boolean?,
  /** 地图是否允许缩放 */
  val zoomEnable: Boolean?,
  /** 地图是否允许俯仰 */
  val tiltEnable: Boolean?,
  /** 地图是否允许旋转 */
  val rotateEnable: Boolean?,
  /** 是否显示指南针控件 */
  val compassControlEnabled: Boolean?,
  /** 是否显示比例尺控件 */
  val scaleControlEnabled: Boolean?,
  /** 是否显示缩放控件(Android Only) */
  val zoomControlEnabled: Boolean?,
  /** Logo位置锚点(Android Only) */
  val logoPosition: UIControlPosition?,
  /** 是否自动展示室内地图，默认是false */
  val showIndoorMap: Boolean?,
  /** 自定义离线样式 */
  val customStyleOptions: CustomStyleOptions? = null,
) {
  companion object {
    fun fromList(list: List<Any?>): MapInitConfig {
      val mapType = (list[0] as Int?)?.let { MapType.ofRaw(it) }
      val cameraPosition = (list[1] as List<Any?>?)?.let { CameraPosition.fromList(it) }
      val fitPositions =
        (list[2] as List<Any?>?)?.map { position -> Position.fromList(position as List<Any?>) }
      val minZoom = list[3] as Double?
      val maxZoom = list[4] as Double?
      val dragEnable = list[5] as Boolean?
      val zoomEnable = list[6] as Boolean?
      val tiltEnable = list[7] as Boolean?
      val rotateEnable = list[8] as Boolean?
      val compassControlEnabled = list[9] as Boolean?
      val scaleControlEnabled = list[10] as Boolean?
      val zoomControlEnabled = list[11] as Boolean?
      val logoPosition = (list[12] as List<Any?>?)?.let { UIControlPosition.fromList(it) }
      val showIndoorMap = list[13] as Boolean?
      val customStyleOptions =
        if (list.size > 14) {
          (list[14] as? List<Any?>)?.let { CustomStyleOptions.fromList(it) }
        } else {
          null
        }
      return MapInitConfig(
        mapType,
        cameraPosition,
        fitPositions,
        minZoom,
        maxZoom,
        dragEnable,
        zoomEnable,
        tiltEnable,
        rotateEnable,
        compassControlEnabled,
        scaleControlEnabled,
        zoomControlEnabled,
        logoPosition,
        showIndoorMap,
        customStyleOptions,
      )
    }
  }

  fun toList(): List<Any?> {
    return listOf(
      mapType?.raw,
      cameraPosition?.toList(),
      fitPositions?.map { it.toList() },
      minZoom,
      maxZoom,
      dragEnable,
      zoomEnable,
      tiltEnable,
      rotateEnable,
      compassControlEnabled,
      scaleControlEnabled,
      zoomControlEnabled,
      logoPosition?.toList(),
      showIndoorMap,
      customStyleOptions?.toList(),
    )
  }
}

/** 地图属性配置 */
data class MapUpdateConfig(
  val mapType: MapType? = null,
  val dragEnable: Boolean? = null,
  val zoomEnable: Boolean? = null,
  val tiltEnable: Boolean? = null,
  val rotateEnable: Boolean? = null,
  val compassControlEnabled: Boolean? = null,
  val scaleControlEnabled: Boolean? = null,
  val zoomControlEnabled: Boolean? = null,
  val logoPosition: UIControlPosition? = null,
  val compassControlPosition: UIControlPosition? = null,
  val scaleControlPosition: UIControlPosition? = null,
  val zoomControlPosition: UIControlPosition? = null,
  val showTraffic: Boolean? = null,
  val showBuildings: Boolean? = null,
  val showIndoorMap: Boolean? = null,
  val userLocationConfig: UserLocationConfig? = null,
  val customStyleOptions: CustomStyleOptions? = null,
  val minZoom: Double? = null,
  val maxZoom: Double? = null,
) {

  companion object {
    fun fromList(list: List<Any?>): MapUpdateConfig {
      val mapType = (list[0] as Int?)?.let { MapType.ofRaw(it) }
      val dragEnable = list[1] as Boolean?
      val zoomEnable = list[2] as Boolean?
      val tiltEnable = list[3] as Boolean?
      val rotateEnable = list[4] as Boolean?
      val compassControlEnabled = list[5] as Boolean?
      val scaleControlEnabled = list[6] as Boolean?
      val zoomControlEnabled = list[7] as Boolean?
      val logoPosition = (list[8] as List<Any?>?)?.let { UIControlPosition.fromList(it) }
      val compassControlPosition =
        (list[9] as List<Any?>?)?.let { UIControlPosition.fromList(it) }
      val scaleControlPosition =
        (list[10] as List<Any?>?)?.let { UIControlPosition.fromList(it) }
      val zoomControlPosition =
        (list[11] as List<Any?>?)?.let { UIControlPosition.fromList(it) }
      val showTraffic = list[12] as Boolean?
      val showBuildings = list[13] as Boolean?
      val showIndoorMap = list[14] as Boolean?
      val userLocationConfig =
        (list[15] as List<Any?>?)?.let { UserLocationConfig.fromList(it) }
      val customStyleOptions =
        if (list.size > 16) {
          (list[16] as? List<Any?>)?.let { CustomStyleOptions.fromList(it) }
        } else {
          null
        }
      val minZoom = if (list.size > 17) (list[17] as Number?)?.toDouble() else null
      val maxZoom = if (list.size > 18) (list[18] as Number?)?.toDouble() else null
      return MapUpdateConfig(
        mapType,
        dragEnable,
        zoomEnable,
        tiltEnable,
        rotateEnable,
        compassControlEnabled,
        scaleControlEnabled,
        zoomControlEnabled,
        logoPosition,
        compassControlPosition,
        scaleControlPosition,
        zoomControlPosition,
        showTraffic,
        showBuildings,
        showIndoorMap,
        userLocationConfig,
        customStyleOptions,
        minZoom,
        maxZoom,
      )
    }
  }

  fun toList(): List<Any?> {
    return listOf(
      mapType?.raw,
      dragEnable,
      zoomEnable,
      tiltEnable,
      rotateEnable,
      compassControlEnabled,
      scaleControlEnabled,
      zoomControlEnabled,
      logoPosition?.toList(),
      compassControlPosition?.toList(),
      scaleControlPosition?.toList(),
      zoomControlPosition?.toList(),
      showTraffic,
      showBuildings,
      showIndoorMap,
      userLocationConfig?.toList(),
      customStyleOptions?.toList(),
      minZoom,
      maxZoom,
    )
  }
}

/** 标记点配置属性 */
data class Marker(
  /** 标记点ID */
  val id: String,
  /** 标记点的位置 */
  val position: Position,
  /** 标记点自定义图标信息 */
  val bitmap: Bitmap?,
  /** InfoWindow 标题 */
  val title: String? = null,
  /** InfoWindow 副标题 */
  val snippet: String? = null,
) {
  companion object {
    fun fromList(list: List<Any?>): Marker {
      val id = list[0] as String
      val position = Position.fromList(list[1] as List<Any?>)
      val bitmap = (list[2] as List<Any?>?)?.let { Bitmap.fromList(it) }
      val title = if (list.size > 3) list[3] as? String else null
      val snippet = if (list.size > 4) list[4] as? String else null
      return Marker(id, position, bitmap, title, snippet)
    }
  }

  fun toList(): List<Any?> {
    return listOf(
      id,
      position.toList(),
      bitmap?.toList(),
      title,
      snippet,
    )
  }
}

/** 折线覆盖物配置 */
data class Polyline(
  val id: String,
  val points: List<Position>,
  val color: Color,
  val colors: List<Color>,
  val width: Double,
  val visible: Boolean,
  val gradient: Boolean,
  val geodesic: Boolean,
  val useTexture: Boolean,
  val texture: Bitmap?,
  val textures: List<Bitmap>,
  val textureIndexes: List<Int>,
  val dottedLine: Boolean,
  val zIndex: Double,
) {
  companion object {
    fun fromList(list: List<Any?>): Polyline {
      val id = list[0] as String
      val points = (list[1] as List<Any?>).map { Position.fromList(it as List<Any?>) }
      val color = colorFromValue(list[2]) ?: Color.valueOf(0xCC00BFFF.toInt())
      val width = (list[3] as Number).toDouble()
      val visible = list[4] as Boolean
      val colors = if (list.size > 5) {
        (list[5] as? List<Any?>)?.mapNotNull { colorFromValue(it) } ?: emptyList()
      } else {
        emptyList()
      }
      val gradient = if (list.size > 6) list[6] as Boolean else false
      val geodesic = if (list.size > 7) list[7] as Boolean else false
      val useTexture = if (list.size > 8) list[8] as Boolean else false
      val texture = if (list.size > 9) (list[9] as List<Any?>?)?.let { Bitmap.fromList(it) } else null
      val textures = if (list.size > 10) {
        (list[10] as? List<Any?>)?.map { Bitmap.fromList(it as List<Any?>) } ?: emptyList()
      } else {
        emptyList()
      }
      val textureIndexes = if (list.size > 11) {
        (list[11] as? List<Any?>)?.map { (it as Number).toInt() } ?: emptyList()
      } else {
        emptyList()
      }
      val dottedLine = if (list.size > 12) list[12] as Boolean else false
      val zIndex = if (list.size > 13) (list[13] as Number).toDouble() else 0.0
      return Polyline(
        id,
        points,
        color,
        colors,
        width,
        visible,
        gradient,
        geodesic,
        useTexture,
        texture,
        textures,
        textureIndexes,
        dottedLine,
        zIndex,
      )
    }
  }

  fun toList(): List<Any?> {
    return listOf(
      id,
      points.map { it.toList() },
      color.toArgb(),
      width,
      visible,
      colors.map { it.toArgb() },
      gradient,
      geodesic,
      useTexture,
      texture?.toList(),
      textures.map { it.toList() },
      textureIndexes,
      dottedLine,
      zIndex,
    )
  }
}

/** 导航箭头覆盖物配置 */
data class NavigateArrow(
  val id: String,
  val points: List<Position>,
  val color: Color,
  val sideColor: Color,
  val width: Double,
  val visible: Boolean,
) {
  companion object {
    fun fromList(list: List<Any?>): NavigateArrow {
      val id = list[0] as String
      val points = (list[1] as List<Any?>).map { Position.fromList(it as List<Any?>) }
      val color = colorFromValue(list[2]) ?: Color.valueOf(0xCC00BFFF.toInt())
      val sideColor = colorFromValue(list[3]) ?: Color.valueOf(0x6600BFFF)
      val width = (list[4] as Number).toDouble()
      val visible = list[5] as Boolean
      return NavigateArrow(id, points, color, sideColor, width, visible)
    }
  }

  fun toList(): List<Any?> {
    return listOf(
      id,
      points.map { it.toList() },
      color.toArgb(),
      sideColor.toArgb(),
      width,
      visible,
    )
  }
}

/** 弧线覆盖物配置 */
data class Arc(
  val id: String,
  val start: Position,
  val passed: Position,
  val end: Position,
  val color: Color,
  val width: Double,
  val visible: Boolean,
) {
  companion object {
    fun fromList(list: List<Any?>): Arc {
      val id = list[0] as String
      val start = Position.fromList(list[1] as List<Any?>)
      val passed = Position.fromList(list[2] as List<Any?>)
      val end = Position.fromList(list[3] as List<Any?>)
      val color = colorFromValue(list[4]) ?: Color.valueOf(0xCC00BFFF.toInt())
      val width = (list[5] as Number).toDouble()
      val visible = list[6] as Boolean
      return Arc(id, start, passed, end, color, width, visible)
    }
  }

  fun toList(): List<Any?> {
    return listOf(
      id,
      start.toList(),
      passed.toList(),
      end.toList(),
      color.toArgb(),
      width,
      visible,
    )
  }
}

/** 多边形覆盖物配置 */
data class Polygon(
  val id: String,
  val points: List<Position>,
  val strokeWidth: Double,
  val strokeColor: Color,
  val fillColor: Color,
  val visible: Boolean,
) {
  companion object {
    fun fromList(list: List<Any?>): Polygon {
      val id = list[0] as String
      val points = (list[1] as List<Any?>).map { Position.fromList(it as List<Any?>) }
      val strokeWidth = (list[2] as Number).toDouble()
      val strokeColor = colorFromValue(list[3]) ?: Color.valueOf(0xCC00BFFF.toInt())
      val fillColor = colorFromValue(list[4]) ?: Color.valueOf(0xC487CEFA.toInt())
      val visible = list[5] as Boolean
      return Polygon(id, points, strokeWidth, strokeColor, fillColor, visible)
    }
  }

  fun toList(): List<Any?> {
    return listOf(
      id,
      points.map { it.toList() },
      strokeWidth,
      strokeColor.toArgb(),
      fillColor.toArgb(),
      visible,
    )
  }
}

/** 地图兴趣点 */
data class Poi(
  /** 兴趣点的名称 */
  val name: String,
  /** 兴趣点的位置 */
  val position: Position
) {
  companion object {
    fun fromList(list: List<Any?>): Poi {
      val name = list[0] as String
      val position = Position.fromList(list[1] as List<Any?>)
      return Poi(name, position)
    }
  }

  fun toList(): List<Any?> {
    return listOf(
      name,
      position.toList(),
    )
  }
}

/** 位置 */
data class Position(
  /** 位置的纬度 */
  val latitude: Double,
  /** 位置的经度 */
  val longitude: Double
) {
  companion object {
    fun fromList(list: List<Any?>): Position {
      val latitude = list[0] as Double
      val longitude = list[1] as Double
      return Position(latitude, longitude)
    }
  }

  fun toList(): List<Any?> {
    return listOf(
      latitude,
      longitude,
    )
  }
}

/** 地图区域 */
data class Region(
  /** 最北的纬度 */
  val north: Double,
  /** 最东的经度 */
  val east: Double,
  /** 最南的纬度 */
  val south: Double,
  /** 最西的经度 */
  val west: Double
) {
  companion object {
    fun fromList(list: List<Any?>): Region {
      val north = list[0] as Double
      val east = list[1] as Double
      val south = list[2] as Double
      val west = list[3] as Double
      return Region(north, east, south, west)
    }
  }

  fun toList(): List<Any?> {
    return listOf(
      north,
      east,
      south,
      west,
    )
  }
}

/** 对象的像素尺寸 **/
data class Size(
  /** 宽度 **/
  val width: Double,
  /** 高度 **/
  val height: Double,
) {
  companion object {
    fun fromList(list: List<Any?>): Size {
      val width = list[0] as Double
      val height = list[1] as Double
      return Size(width, height)
    }
  }

  fun toList(): List<Any?> {
    return listOf(
      width,
      height,
    )
  }
}

/** UI控件位置偏移 */
data class UIControlOffset(
  /** X轴方向的位置偏移 */
  val x: Double,
  /** Y轴方向的位置偏移 */
  val y: Double
) {
  companion object {
    fun fromList(list: List<Any?>): UIControlOffset {
      val x = list[0] as Double
      val y = list[1] as Double
      return UIControlOffset(x, y)
    }
  }

  fun toList(): List<Any?> {
    return listOf(
      x,
      y,
    )
  }
}

/** UI控件位置 */
data class UIControlPosition(
  /** UI控件位置锚点 */
  val anchor: UIControlAnchor,
  /** UI控件位置偏移 */
  val offset: UIControlOffset
) {
  companion object {
    fun fromList(list: List<Any?>): UIControlPosition {
      val anchor = UIControlAnchor.ofRaw(list[0] as Int)!!
      val offset = UIControlOffset.fromList(list[1] as List<Any?>)
      return UIControlPosition(anchor, offset)
    }
  }

  fun toList(): List<Any?> {
    return listOf(
      anchor.raw,
      offset.toList(),
    )
  }
}

/** 用户定位配置 */
data class UserLocationConfig(
  val userLocationButton: Boolean?,
  val showUserLocation: Boolean?,
  val userLocationStyle: UserLocationStyle?
) {
  companion object {
    fun fromList(list: List<Any?>): UserLocationConfig {
      val userLocationButton = list[0] as Boolean?
      val showUserLocation = list[1] as Boolean?
      val userLocationStyle = (list[2] as List<Any?>?)?.let { UserLocationStyle.fromList(it) }
      return UserLocationConfig(
        userLocationButton,
        showUserLocation,
        userLocationStyle,
      )
    }
  }

  fun toList(): List<Any?> {
    return listOf(
      this.userLocationButton,
      this.showUserLocation,
      this.userLocationStyle?.toList(),
    )
  }
}

/** 用户定位样式 */
data class UserLocationStyle(
  val userLocationType: UserLocationType?,
  val fillColor: Color?,
  val strokeColor: Color?,
  val lineWidth: Double?,
  val image: Bitmap?,
  val showLocationDot: Boolean?,
  val anchor: Anchor?,
  val showsAccuracyRing: Boolean?,
  val showsHeadingIndicator: Boolean?,
  val locationDotBgColor: Color?,
  val locationDotFillColor: Color?,
  val enablePulseAnimation: Boolean?,
  val intervalMs: Long?
) {
  companion object {
    fun fromList(list: List<Any?>): UserLocationStyle {
      val userLocationType = (list[0] as Int?)?.let { UserLocationType.ofRaw(it) }
      val fillColor = colorFromValue(list[1])
      val strokeColor = colorFromValue(list[2])
      val lineWidth = list[3] as Double?
      val image = (list[4] as List<Any?>?)?.let { Bitmap.fromList(it) }
      val showLocationDot = if (list.size > 5) list[5] as Boolean? else null
      val anchor = if (list.size > 6) (list[6] as List<Any?>?)?.let { Anchor.fromList(it) } else null
      val showsAccuracyRing = if (list.size > 7) list[7] as Boolean? else null
      val showsHeadingIndicator = if (list.size > 8) list[8] as Boolean? else null
      val locationDotBgColor = if (list.size > 9) colorFromValue(list[9]) else null
      val locationDotFillColor = if (list.size > 10) colorFromValue(list[10]) else null
      val enablePulseAnimation = if (list.size > 11) list[11] as Boolean? else null
      val intervalMs = if (list.size > 12) (list[12] as Number?)?.toLong() else null
      return UserLocationStyle(
        userLocationType,
        fillColor,
        strokeColor,
        lineWidth,
        image,
        showLocationDot,
        anchor,
        showsAccuracyRing,
        showsHeadingIndicator,
        locationDotBgColor,
        locationDotFillColor,
        enablePulseAnimation,
        intervalMs,
      )
    }
  }

  fun toList(): List<Any?> {
    return listOf(
      userLocationType?.raw,
      fillColor?.toArgb(),
      strokeColor?.toArgb(),
      lineWidth,
      image?.toList(),
      showLocationDot,
      anchor?.toList(),
      showsAccuracyRing,
      showsHeadingIndicator,
      locationDotBgColor?.toArgb(),
      locationDotFillColor?.toArgb(),
      enablePulseAnimation,
      intervalMs,
    )
  }
}

private fun colorFromValue(value: Any?): Color? {
  return (value as? Number)?.toInt()?.let { Color.valueOf(it) }
}
