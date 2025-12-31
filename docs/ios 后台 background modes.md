## iOS Background Modes 详细说明（Markdown 表格）



| Background Mode                        | 中文含义               | 主要作用             | 典型使用场景             | 关键技术 / 框架                 | 审核 & 注意事项               |
| -------------------------------------- | ------------------ | ---------------- | ------------------ | ------------------------- | ----------------------- |
| Audio, AirPlay, and Picture in Picture | 音频 / AirPlay / 画中画 | 后台持续播放音频或视频      | 音乐播放器、播客、电台、视频 PiP | AVAudioSession、AVPlayer   | ❌ 无真实音频输出仅保活会被拒         |
| Location updates                       | 后台定位               | App 后台持续获取位置信息   | 导航、运动轨迹、网约车、电子围栏   | CoreLocation              | ⚠️ 必须说明业务用途，需 Always 权限 |
| Voice over IP                          | 网络语音通话             | 后台接听 VoIP 来电     | 网络电话、实时语音通话        | PushKit、CallKit           | ❌ 已严格限制，禁止用于保活          |
| External accessory communication       | 外部配件通信             | 与 MFi 硬件持续通信     | 工业设备、刷卡器、专业硬件      | ExternalAccessory         | ⚠️ 需 MFi 认证设备           |
| Uses Bluetooth LE accessories          | 使用 BLE 外设          | 后台扫描 / 连接 BLE 外设 | 蓝牙钥匙、手环、传感器        | CoreBluetooth（Central）    | ✔️ 实际使用一般可过审            |
| Acts as a Bluetooth LE accessory       | 作为 BLE 外设          | 手机充当 BLE 外设广播    | 门禁、设备配对            | CoreBluetooth（Peripheral） | ⚠️ 功耗高，使用场景较少           |
| Background fetch                       | 后台拉取数据             | 系统不定期唤醒 App 拉数据  | 新闻、邮件、数据刷新         | UIApplication             | ❌ 不定时、不可靠，iOS 13+ 被弱化   |
| Remote notifications                   | 远程通知               | 静默推送唤醒后台执行任务     | 数据同步、状态更新          | APNs（content-available）   | ✔️ 比 fetch 稳定           |
| Background processing                  | 后台处理任务             | 执行较长后台任务         | 大文件上传、数据同步         | BGTaskScheduler           | ✅ 推荐替代 fetch            |
| Uses Nearby Interaction                | 附近交互（UWB）          | 高精度空间定位          | AirTag 类应用         | NearbyInteraction         | ⚠️ 需 iPhone 11+         |
| Push to Talk                           | 对讲功能               | 即按即说语音通信         | 企业对讲、现场通信          | PushToTalk Framework      | ⚠️ iOS 16+，审核较严格        |

---

## 常见 App 类型推荐勾选组合（表格）

| App 类型    | 推荐 Background Modes                                  |
| --------- | ---------------------------------------------------- |
| 地图 / 导航   | Location updates + Background processing             |
| 蓝牙设备 / 钥匙 | Uses Bluetooth LE accessories + Remote notifications |
| 音乐 / 播放器  | Audio, AirPlay, and Picture in Picture               |
| 普通业务 App  | Remote notifications + Background processing         |
| 即时通信（语音）  | Voice over IP + Push to Talk（慎用）                     |

---

## 审核红线总结（必看）

| 行为                     | 结果      |
| ---------------------- | ------- |
| 为保活乱勾 Background Modes | ❌ 高概率被拒 |
| 后台定位但用户无感知             | ❌ 被拒    |
| VoIP 用于长连接保活           | ❌ 直接拒   |
| 声明后台能力但无实际功能           | ❌ 被拒    |

---

