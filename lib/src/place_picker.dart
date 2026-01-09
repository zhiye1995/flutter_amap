part of '../amap_flutter.dart';

/// 地点选择器配置
class PlacePickerConfig {
  const PlacePickerConfig({
    this.title,
    this.hintText,
    this.city,
    this.cityLimit = false,
    this.types,
    this.location,
    this.debounceDelay = const Duration(milliseconds: 300),
  });

  /// 标题
  final String? title;

  /// 搜索框提示文字
  final String? hintText;

  /// 搜索城市
  final String? city;

  /// 是否限制在当前城市搜索
  final bool cityLimit;

  /// POI类型限制
  final String? types;

  /// 搜索中心点
  final Position? location;

  /// 输入防抖延迟
  final Duration debounceDelay;
}

/// 高德地图地点选择器底部弹窗
class AMapPlacePicker extends StatefulWidget {
  const AMapPlacePicker({
    super.key,
    this.config = const PlacePickerConfig(),
  });

  /// 配置
  final PlacePickerConfig config;

  /// 显示地点选择器底部弹窗
  ///
  /// 返回选中的 [InputTip]，如果取消则返回 null
  static Future<InputTip?> show(
    BuildContext context, {
    PlacePickerConfig config = const PlacePickerConfig(),
  }) {
    return showModalBottomSheet<InputTip>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AMapPlacePicker(config: config),
    );
  }

  @override
  State<AMapPlacePicker> createState() => _AMapPlacePickerState();
}

class _AMapPlacePickerState extends State<AMapPlacePicker> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<InputTip> _tips = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _debounceTimer;

  PlacePickerConfig get config => widget.config;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // 自动聚焦搜索框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();

    final keywords = _searchController.text.trim();
    if (keywords.isEmpty) {
      setState(() {
        _tips = [];
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _debounceTimer = Timer(config.debounceDelay, () {
      _searchInputTips(keywords);
    });
  }

  Future<void> _searchInputTips(String keywords) async {
    try {
      final tips = await AMapSearch.requestInputTips(
        keywords: keywords,
        city: config.city,
        cityLimit: config.cityLimit,
        types: config.types,
        location: config.location,
      );

      if (mounted && _searchController.text.trim() == keywords) {
        setState(() {
          _tips = tips;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && _searchController.text.trim() == keywords) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _onTipSelected(InputTip tip) {
    Navigator.of(context).pop(tip);
  }

  void _onCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.85,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部拖动指示器
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题栏
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    config.title ?? '选择地点',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _onCancel,
                  icon: Icon(
                    Icons.close,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // 搜索框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: config.hintText ?? '搜索地点',
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: Icon(
                          Icons.clear,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.search,
            ),
          ),

          // 分割线
          Divider(
            height: 1,
            color: colorScheme.outline.withOpacity(0.2),
          ),

          // 结果列表
          Expanded(
            child: _buildResultList(theme, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildResultList(ThemeData theme, ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: colorScheme.error.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              '搜索失败',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 64,
              color: colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '输入关键词搜索地点',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    if (_tips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '未找到相关地点',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _tips.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        indent: 56,
        color: colorScheme.outline.withOpacity(0.1),
      ),
      itemBuilder: (context, index) {
        final tip = _tips[index];
        return _buildTipItem(tip, theme, colorScheme);
      },
    );
  }

  Widget _buildTipItem(InputTip tip, ThemeData theme, ColorScheme colorScheme) {
    // 构建地址显示
    String? subtitle;
    final parts = <String>[];
    if (tip.district != null && tip.district!.isNotEmpty) {
      parts.add(tip.district!);
    }
    if (tip.address != null && tip.address!.isNotEmpty) {
      parts.add(tip.address!);
    }
    if (parts.isNotEmpty) {
      subtitle = parts.join(' · ');
    }

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.location_on,
          color: colorScheme.primary,
          size: 22,
        ),
      ),
      title: Text(
        tip.name,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: tip.position != null
          ? Icon(
              Icons.chevron_right,
              color: colorScheme.onSurface.withOpacity(0.3),
            )
          : null,
      onTap: () => _onTipSelected(tip),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

