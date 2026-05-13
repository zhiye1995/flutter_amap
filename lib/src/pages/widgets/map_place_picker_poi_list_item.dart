part of '../../../../flutter_amap.dart';

class _MapPlacePickerPoiListItem extends StatelessWidget {
  const _MapPlacePickerPoiListItem({
    required this.poi,
    required this.index,
    required this.isSelected,
    required this.subtitle,
    required this.highlightWords,
    required this.onTap,
  });

  final PoiItem poi;
  final int index;
  final bool isSelected;
  final String subtitle;
  final Map<String, HighlightedWord>? highlightWords;
  final void Function(int index) onTap;

  static const TextStyle titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFF333333),
  );
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 12,
    color: Color(0xFF999999),
  );
  static const TextStyle highlightStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFF07C160),
  );

  @override
  Widget build(BuildContext context) {
    final words = highlightWords;

    return InkWell(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFE0E0E0),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (words != null && words.isNotEmpty)
                    TextHighlight(
                      text: poi.name,
                      words: words,
                      textStyle: titleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      poi.name,
                      style: titleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    if (words != null && words.isNotEmpty)
                      TextHighlight(
                        text: subtitle,
                        words: words,
                        textStyle: subtitleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        subtitle,
                        style: subtitleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                color: Color(0xFF07C160),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
