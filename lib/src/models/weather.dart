part of '../../../flutter_amap.dart';

// ==================== 天气相关类型 ====================

/// 天气查询类型
enum WeatherType {
  /// 实时天气
  live,

  /// 预报天气
  forecast,
}

/// 实时天气信息
class LocalWeatherLive {
  LocalWeatherLive({
    this.city,
    this.adCode,
    this.province,
    this.weather,
    this.temperature,
    this.windDirection,
    this.windPower,
    this.humidity,
    this.reportTime,
  });

  /// 城市名称
  final String? city;

  /// 区域编码
  final String? adCode;

  /// 省份名称
  final String? province;

  /// 天气现象 https://lbs.amap.com/api/android-sdk/guide/map-tools/weather-code  天气对照表
  final String? weather;

  /// 实时温度（单位：摄氏度）
  final String? temperature;

  /// 风向
  final String? windDirection;

  /// 风力等级
  final String? windPower;

  /// 空气湿度（百分比）
  final String? humidity;

  /// 数据发布时间
  final String? reportTime;

  Object encode() {
    return <Object?>[
      city,
      adCode,
      province,
      weather,
      temperature,
      windDirection,
      windPower,
      humidity,
      reportTime,
    ];
  }

  static LocalWeatherLive decode(List<Object?> result) {
    return LocalWeatherLive(
      city: result[0] as String?,
      adCode: result[1] as String?,
      province: result[2] as String?,
      weather: result[3] as String?,
      temperature: result[4] as String?,
      windDirection: result[5] as String?,
      windPower: result[6] as String?,
      humidity: result[7] as String?,
      reportTime: result[8] as String?,
    );
  }

  /// 从 Map 解码（用于 MethodChannel 返回）
  static LocalWeatherLive decodeFromMap(Map<String, dynamic> map) {
    return LocalWeatherLive(
      city: map['city'] as String?,
      adCode: map['adCode'] as String?,
      province: map['province'] as String?,
      weather: map['weather'] as String?,
      temperature: map['temperature'] as String?,
      windDirection: map['windDirection'] as String?,
      windPower: map['windPower'] as String?,
      humidity: map['humidity'] as String?,
      reportTime: map['reportTime'] as String?,
    );
  }

  LocalWeatherLive copyWith({
    String? city,
    String? adCode,
    String? province,
    String? weather,
    String? temperature,
    String? windDirection,
    String? windPower,
    String? humidity,
    String? reportTime,
  }) {
    return LocalWeatherLive(
      city: city ?? this.city,
      adCode: adCode ?? this.adCode,
      province: province ?? this.province,
      weather: weather ?? this.weather,
      temperature: temperature ?? this.temperature,
      windDirection: windDirection ?? this.windDirection,
      windPower: windPower ?? this.windPower,
      humidity: humidity ?? this.humidity,
      reportTime: reportTime ?? this.reportTime,
    );
  }

  Widget get icon => WeatherIcon(weather: weather);

  @override
  String toString() {
    return 'LocalWeatherLive(city: $city, weather: $weather, temperature: $temperature°C, humidity: $humidity%)';
  }
}

/// 每日天气预报
class LocalDayWeatherForecast {
  LocalDayWeatherForecast({
    this.date,
    this.week,
    this.dayWeather,
    this.nightWeather,
    this.dayTemp,
    this.nightTemp,
    this.dayWind,
    this.nightWind,
    this.dayPower,
    this.nightPower,
  });

  /// 日期（格式：yyyy-MM-dd）
  final String? date;

  /// 星期几（1-7，1为周一）
  final String? week;

  /// 白天天气现象
  final String? dayWeather;

  /// 夜间天气现象
  final String? nightWeather;

  /// 白天温度（单位：摄氏度）
  final String? dayTemp;

  /// 夜间温度（单位：摄氏度）
  final String? nightTemp;

  /// 白天风向
  final String? dayWind;

  /// 夜间风向
  final String? nightWind;

  /// 白天风力等级
  final String? dayPower;

  /// 夜间风力等级
  final String? nightPower;

  Object encode() {
    return <Object?>[
      date,
      week,
      dayWeather,
      nightWeather,
      dayTemp,
      nightTemp,
      dayWind,
      nightWind,
      dayPower,
      nightPower,
    ];
  }

  static LocalDayWeatherForecast decode(List<Object?> result) {
    return LocalDayWeatherForecast(
      date: result[0] as String?,
      week: result[1] as String?,
      dayWeather: result[2] as String?,
      nightWeather: result[3] as String?,
      dayTemp: result[4] as String?,
      nightTemp: result[5] as String?,
      dayWind: result[6] as String?,
      nightWind: result[7] as String?,
      dayPower: result[8] as String?,
      nightPower: result[9] as String?,
    );
  }

  /// 从 Map 解码（用于 MethodChannel 返回）
  static LocalDayWeatherForecast decodeFromMap(Map<String, dynamic> map) {
    return LocalDayWeatherForecast(
      date: map['date'] as String?,
      week: map['week'] as String?,
      dayWeather: map['dayWeather'] as String?,
      nightWeather: map['nightWeather'] as String?,
      dayTemp: map['dayTemp'] as String?,
      nightTemp: map['nightTemp'] as String?,
      dayWind: map['dayWind'] as String?,
      nightWind: map['nightWind'] as String?,
      dayPower: map['dayPower'] as String?,
      nightPower: map['nightPower'] as String?,
    );
  }

  LocalDayWeatherForecast copyWith({
    String? date,
    String? week,
    String? dayWeather,
    String? nightWeather,
    String? dayTemp,
    String? nightTemp,
    String? dayWind,
    String? nightWind,
    String? dayPower,
    String? nightPower,
  }) {
    return LocalDayWeatherForecast(
      date: date ?? this.date,
      week: week ?? this.week,
      dayWeather: dayWeather ?? this.dayWeather,
      nightWeather: nightWeather ?? this.nightWeather,
      dayTemp: dayTemp ?? this.dayTemp,
      nightTemp: nightTemp ?? this.nightTemp,
      dayWind: dayWind ?? this.dayWind,
      nightWind: nightWind ?? this.nightWind,
      dayPower: dayPower ?? this.dayPower,
      nightPower: nightPower ?? this.nightPower,
    );
  }

  /// 获取星期几的中文名称
  String get weekName {
    switch (week) {
      case '1':
        return '周一';
      case '2':
        return '周二';
      case '3':
        return '周三';
      case '4':
        return '周四';
      case '5':
        return '周五';
      case '6':
        return '周六';
      case '7':
        return '周日';
      default:
        return '未知';
    }
  }

  Widget get icon => WeatherIcon(weather: dayWeather);


  @override
  String toString() {
    return 'LocalDayWeatherForecast(date: $date, week: $weekName, dayWeather: $dayWeather, dayTemp: $dayTemp°C, nightTemp: $nightTemp°C)';
  }
}

/// 天气预报信息
class LocalWeatherForecast {
  LocalWeatherForecast({
    this.city,
    this.adCode,
    this.province,
    this.reportTime,
    this.casts,
  });

  /// 城市名称
  final String? city;

  /// 区域编码
  final String? adCode;

  /// 省份名称
  final String? province;

  /// 数据发布时间
  final String? reportTime;

  /// 天气预报列表（未来几天）
  final List<LocalDayWeatherForecast>? casts;

  Object encode() {
    return <Object?>[
      city,
      adCode,
      province,
      reportTime,
      casts?.map((e) => e.encode()).toList(),
    ];
  }

  static LocalWeatherForecast decode(List<Object?> result) {
    return LocalWeatherForecast(
      city: result[0] as String?,
      adCode: result[1] as String?,
      province: result[2] as String?,
      reportTime: result[3] as String?,
      casts: result[4] != null
          ? (result[4] as List).map((e) => LocalDayWeatherForecast.decode(e as List<Object?>)).toList()
          : null,
    );
  }

  /// 从 Map 解码（用于 MethodChannel 返回）
  static LocalWeatherForecast decodeFromMap(Map<String, dynamic> map) {
    List<LocalDayWeatherForecast>? casts;
    if (map['casts'] != null) {
      casts = (map['casts'] as List).map((item) {
        return LocalDayWeatherForecast.decodeFromMap(Map<String, dynamic>.from(item as Map));
      }).toList();
    }

    return LocalWeatherForecast(
      city: map['city'] as String?,
      adCode: map['adCode'] as String?,
      province: map['province'] as String?,
      reportTime: map['reportTime'] as String?,
      casts: casts,
    );
  }

  LocalWeatherForecast copyWith({
    String? city,
    String? adCode,
    String? province,
    String? reportTime,
    List<LocalDayWeatherForecast>? casts,
  }) {
    return LocalWeatherForecast(
      city: city ?? this.city,
      adCode: adCode ?? this.adCode,
      province: province ?? this.province,
      reportTime: reportTime ?? this.reportTime,
      casts: casts ?? this.casts,
    );
  }

  @override
  String toString() {
    return 'LocalWeatherForecast(city: $city, reportTime: $reportTime, casts: ${casts?.length ?? 0} days)';
  }
}


class WeatherIcon extends StatelessWidget {
  const WeatherIcon({
    super.key,
    this.weather,
    this.width = 40,
    this.height = 40,
  });

  /// 天气名称
  final String? weather;

  /// 图标宽度
  final double width;

  /// 图标高度
  final double height;

  /// 天气名称到图标ID的映射
  static const Map<String, int> _weatherIconMap = {
    '晴': 1,
    '少云': 2,
    '晴间多云': 3,
    '多云': 4,
    '阴': 5,
    '有风': 6,
    '平静': 7,
    '微风': 8,
    '和风': 9,
    '清风': 10,
    '强风/劲风': 11,
    '疾风': 12,
    '大风': 13,
    '烈风': 14,
    '风暴': 15,
    '狂爆风': 16,
    '飓风': 17,
    '热带风暴': 18,
    '霾': 19,
    '中度霾': 20,
    '重度霾': 21,
    '严重霾': 22,
    '阵雨': 23,
    '雷阵雨': 24,
    '雷阵雨并伴有冰雹': 25,
    '小雨': 26,
    '中雨': 27,
    '大雨': 28,
    '暴雨': 29,
    '大暴雨': 30,
    '特大暴雨': 31,
    '强阵雨': 32,
    '强雷阵雨': 33,
    '极端降雨': 34,
    '毛毛雨/细雨': 35,
    '雨': 36,
    '小雨-中雨': 37,
    '中雨-大雨': 38,
    '大雨-暴雨': 39,
    '暴雨-大暴雨': 40,
    '大暴雨-特大暴雨': 41,
    '雨雪天气': 42,
    '雨夹雪': 43,
    '阵雨夹雪': 44,
    '冻雨': 45,
    '雪': 46,
    '阵雪': 47,
    '小雪': 48,
    '中雪': 49,
    '大雪': 50,
    '暴雪': 51,
    '小雪-中雪': 52,
    '中雪-大雪': 53,
    '大雪-暴雪': 54,
    '浮尘': 55,
    '扬沙': 56,
    '沙尘暴': 57,
    '强沙尘暴': 58,
    '龙卷风': 59,
    '雾': 60,
    '浓雾': 61,
    '强浓雾': 62,
    '轻雾': 63,
    '大雾': 64,
    '特强浓雾': 65,
    '热': 66,
    '冷': 67,
    '未知': 68,
  };

  /// 根据天气名称获取图标ID
  static int _getWeatherIconId(String? weatherName) {
    if (weatherName == null || weatherName.isEmpty) {
      return 68; // 默认使用未知图标
    }
    return _weatherIconMap[weatherName] ?? 68;
  }

  @override
  Widget build(BuildContext context) {
    if (weather == null || weather!.isEmpty) {
      // 如果天气名称为空，加载默认图标
      return SizedBox();
    }
    int iconId = _getWeatherIconId(weather);
    String iconName = 'assets/weather/weather${iconId.toString().padLeft(2, '0')}.png';
    return Image.asset(
      iconName,
      package: 'flutter_amap',
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        // 如果主图标加载失败，尝试加载默认图标
        return Image.asset(
          'assets/weather/weather68.png',
          package: 'flutter_amap',
          width: width,
          height: height,
        );
      },
    );
  }
}
