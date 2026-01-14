part of '../../../amap_flutter.dart';

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