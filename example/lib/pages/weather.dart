import 'package:flutter/material.dart';
import 'package:flutter_amap/flutter_amap.dart';

/// 天气查询示例页面
class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  static const title = '天气查询';

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final TextEditingController _cityController =
      TextEditingController(text: '北京市');

  bool _isLoading = false;
  String? _errorMessage;

  LocalWeatherLive? _weatherLive;
  LocalWeatherForecast? _weatherForecast;

  WeatherType _selectedType = WeatherType.live;

  Future<void> _searchWeather() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入城市名称或区域编码')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_selectedType == WeatherType.live) {
        final result = await AMapSearch.searchWeatherLive(city: city);
        setState(() {
          _weatherLive = result;
          _weatherForecast = null;
        });
      } else {
        final result = await AMapSearch.searchWeatherForecast(city: city);
        setState(() {
          _weatherForecast = result;
          _weatherLive = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('查询失败: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchWeatherByLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_selectedType == WeatherType.live) {
        final result = await AMapSearch.searchWeatherLiveByLocation();
        setState(() {
          _weatherLive = result;
          _weatherForecast = null;
          // 更新城市输入框显示当前定位的城市
          _cityController.text = result.city ?? '';
        });
      } else {
        final result = await AMapSearch.searchWeatherForecastByLocation();
        setState(() {
          _weatherForecast = result;
          _weatherLive = null;
          // 更新城市输入框显示当前定位的城市
          _cityController.text = result.city ?? '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('定位天气查询失败: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(WeatherPage.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 输入区域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '城市设置',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: '城市名称或区域编码',
                        hintText: '例如：北京市 或 110000',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '查询类型',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<WeatherType>(
                      segments: const [
                        ButtonSegment(
                          value: WeatherType.live,
                          label: Text('实时天气'),
                          icon: Icon(Icons.wb_sunny),
                        ),
                        ButtonSegment(
                          value: WeatherType.forecast,
                          label: Text('天气预报'),
                          icon: Icon(Icons.calendar_today),
                        ),
                      ],
                      selected: {_selectedType},
                      onSelectionChanged: (values) {
                        setState(() {
                          _selectedType = values.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 查询按钮
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _searchWeather,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isLoading ? '查询中...' : '查询天气'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _searchWeatherByLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('当前位置'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 错误信息
            if (_errorMessage != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 实时天气结果
            if (_weatherLive != null) _buildWeatherLiveCard(_weatherLive!),

            // 天气预报结果
            if (_weatherForecast != null)
              _buildWeatherForecastCard(_weatherForecast!),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherLiveCard(LocalWeatherLive weather) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                weather.icon,
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather.province ?? ''} ${weather.city ?? ''}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '区域编码: ${weather.adCode ?? '未知'}',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('天气', weather.weather ?? '未知'),
            _buildInfoRow('温度', '${weather.temperature ?? '未知'}°C'),
            _buildInfoRow('风向', weather.windDirection ?? '未知'),
            _buildInfoRow('风力', '${weather.windPower ?? '未知'}级'),
            _buildInfoRow('湿度', '${weather.humidity ?? '未知'}%'),
            const Divider(height: 16),
            Text(
              '发布时间: ${weather.reportTime ?? '未知'}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer
                    .withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherForecastCard(LocalWeatherForecast forecast) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 32,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${forecast.province ?? ''} ${forecast.city ?? ''}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '区域编码: ${forecast.adCode ?? '未知'}',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (forecast.casts != null && forecast.casts!.isNotEmpty)
              ...forecast.casts!.map((day) => _buildDayForecastTile(day))
            else
              const Text('暂无预报数据'),
            const Divider(height: 16),
            Text(
              '发布时间: ${forecast.reportTime ?? '未知'}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSecondaryContainer
                    .withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayForecastTile(LocalDayWeatherForecast day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 日期和星期
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.date ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  day.weekName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // 天气图标
          day.icon,
          const SizedBox(width: 12),
          // 温度
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${day.dayTemp ?? '--'}°C / ${day.nightTemp ?? '--'}°C',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${day.dayWeather ?? ''} → ${day.nightWeather ?? ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // 风向风力
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                day.dayWind ?? '',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '${day.dayPower ?? ''}级',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer
                    .withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

// IconData _getWeatherIcon(String? weather) {
//   /// https://lbs.amap.com/api/android-sdk/guide/map-tools/weather-code  天气对照表
//   if (weather == null) return Icons.wb_cloudy;
//
//   if (weather.contains('晴')) {
//     return Icons.wb_sunny;
//   } else if (weather.contains('云') || weather.contains('阴')) {
//     return Icons.cloud;
//   } else if (weather.contains('雨')) {
//     return Icons.umbrella;
//   } else if (weather.contains('雪')) {
//     return Icons.ac_unit;
//   } else if (weather.contains('雾') || weather.contains('霾')) {
//     return Icons.blur_on;
//   } else if (weather.contains('雷')) {
//     return Icons.flash_on;
//   } else if (weather.contains('风')) {
//     return Icons.air;
//   }
//
//   return Icons.wb_cloudy;
// }
}
