# 折线、导航箭头和弧线

## 更新与错误处理

`addPolyline` 和 `updatePolyline` 都按业务 ID 创建或更新完整配置；`removePolyline` 才删除对象。
Android 使用已有对象的 setter / `setOptions`；iOS 保留相同类型的 overlay 和 renderer，只有普通线、多彩线、分段纹理线、大地线之间转换时重建该对象。iOS 层级调整只重新插入受影响的折线，保证折线之间的相对层级。

宽度单位为物理像素；iOS 在渲染前除以屏幕缩放倍数。隐藏使用 `visible: false`，不会丢弃配置。

```dart
await controller.updatePolyline(line.copyWith(width: 18));
await controller.updatePolyline(line.copyWith(visible: false));
```

每次更新提交完整配置；调用方应保留最新模型，不要用旧模型覆盖其他已更新属性。模型校验失败抛出 `ArgumentError`，纹理解码失败返回 `PlatformException`。在校验/解码失败前不会删除原折线。示例保留期望配置并显示“更新未完成”，重试重新提交期望配置，不会再执行一次切换。多条折线更新不是原子事务，失败时已成功的部分保留，重试补齐剩余部分。

`waitForMapCompleted(throwOnTimeout: true)` 可区分超时；默认值仍为 false，兼容既有调用。
相机适配、标记添加/移除现在返回 `Future<void>`，支持等待和捕获通道错误；Future 完成表示原生命令处理完成，不表示地图像素已经绘制完毕。

## 分段纹理迁移

`textureIndexes` 统一为每一段使用的图片编号，编号从 0 开始。非空时长度必须为 `points.length - 1`，每项必须小于 `textures.length`。为空时全部使用第一张图片。

```dart
Polyline(
  id: 'texture-line', points: points, // 五个点，四段
  useTexture: true,
  textures: [Bitmap(asset: 'assets/a.png'), Bitmap(asset: 'assets/b.png')],
  textureIndexes: [0, 1, 0, 1],
);
```

Android 直接传给 `setCustomTextureIndex`。iOS 合并相邻相同编号的区间，生成 `drawStyleIndexes` 和按区间排列的图片数组。例如 `[0,0,1,1]` 对应两个区间，终点索引 `[2,4]`、图片 `[a,b]`；`[0,1,0,1]` 对应 `[1,2,3,4]`、图片 `[a,b,a,b]`。

旧 iOS 调用如果把坐标点分段边界传入 `textureIndexes`，必须改成逐段图片编号，不能继续复用旧含义。关闭纹理时清空 `textureIndexes`；`copyWith(clearTexture: true)` 可以移除单纹理引用。

## 多彩与渐变

- 普通分段模式：`colors` 每段一个颜色；或使用颜色表加 `colorIndexes`，每段一个颜色编号。颜色索引与纹理索引完全独立。
- 渐变模式：`gradient: true`，`colors` 每个坐标点一个颜色锚点，不设置 `colorIndexes`。例如五个点需要五种锚点颜色。
- iOS 普通分段合并相邻相同编号的区间，避免不必要的样式边界；渐变保留每个锚点。
- 两端使用各自 SDK 的渐变渲染，不承诺逐像素相同；需要按相同坐标及锚点在设备上验收端点颜色、过渡和拐角。

旧调用中颜色数量不足、索引越界、重复连续点等输入现在会明确报错。请先修正输入，不要依赖 SDK 静默回退。`addPolyline` / `updatePolyline` 会先折叠相邻重复坐标（零长度段），并同步缩短分段颜色和纹理索引；折叠后不足两个点仍会报错。

## 样式和交互

| Dart 参数 | Android | iOS |
| --- | --- | --- |
| `lineCap` | butt / square / round | 对应端点类型 |
| `lineJoin` | bevel / miter / round | 对应连接类型 |
| `dottedLine` + `dashType` | 方块 / 圆点虚线 | square / dot |
| `clickable` + `onPolylineClick` | SDK 折线点击监听 | 使用 SDK 覆盖物几何做屏幕空间命中检测 |
| `geodesic` | geodesic | MAGeodesicPolyline |
| NavigateArrow | NavigateArrow | MAPolylineRenderer.is3DArrowLine |
| Arc | ArcOptions | MAArc |

点击事件返回业务 ID，默认关闭。iOS 命中范围至少为 8 屏幕点，多个可点击折线重叠时选取层级最高者；虚线空隙也计入路径命中区域。Android 使用 SDK 命中规则。
纹理图片本身决定视觉颜色/边缘；端点、连接类型等在纹理模式下受原生 SDK 限制。

大地线不能与多彩、渐变、纹理组合；纹理不能与多彩、渐变、虚线组合，避免不同平台静默忽略设置。只允许一个启用的纹理来源。宽度必须为正且有限，坐标必须有效。提交到原生前会折叠相邻重复点；折叠后不足两个点仍会报错。Arc 还拒绝三点重合或投影后共线。

## 示例与验收

联合示例 `example/lib/features/map_3d/map_overlay/polyline_pages.dart` 提供普通线编辑/隐藏/点击、多彩/渐变、纹理与层级、导航箭头、大地线和弧线。操作执行期间禁止竞争更新，线宽预览延迟合并；面板在矮屏幕内可滚动。

- 普通线：追加、撤销、清空、重置、隐藏/显示、删除/添加、适配视野。
- 样式：四段纹理应依次为 a/b/a/b；切换层级只更新相交两线。
- 多彩：分段颜色编号与渐变节点颜色分别验收。
- 大地线：切换北京—伦敦两点与多点路线，用沿大圆插值的采样点适配整条曲线。采样仅用于视野，真实线条仍由 SDK 绘制。
- 故障：纹理资源不存在、地图超时、连续点击、绘制中退出页面；错误应可见且可重试。
- 长轨迹：在设备上检查更新耗时、纹理加载次数与闪烁，Dart 模型/通道测试不代替原生性能和视觉验收。

## 官方 API

- [Android PolylineOptions](https://a.amap.com/lbs/static/unzip/Android_Map_Doc/3D/com/amap/api/maps/model/PolylineOptions.html)
- [Android Polyline](https://a.amap.com/lbs/static/unzip/Android_Map_Doc/3D/com/amap/api/maps/model/Polyline.html)
- [iOS MAMultiPolyline](https://a.amap.com/lbs/static/unzip/iOS_Map_Doc/AMap_iOS_API_Doc_3D/interface_m_a_multi_polyline.html)
- [iOS MAPolylineRenderer](https://a.amap.com/lbs/static/unzip/iOS_Map_Doc/AMap_iOS_API_Doc_3D/interface_m_a_polyline_renderer.html)
- [iOS MAMultiColoredPolylineRenderer](https://a.amap.com/lbs/static/unzip/iOS_Map_Doc/AMap_iOS_API_Doc_3D/interface_m_a_multi_colored_polyline_renderer.html)

当前依赖的 SDK 为 11.2.100；官网在线参考页可能显示不同的小版本，新增 Android 调用还通过本地依赖 JAR 和编译核对。
