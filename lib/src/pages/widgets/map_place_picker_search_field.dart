part of '../../../../flutter_amap.dart';

class _MapPlacePickerSearchField extends StatelessWidget {
  const _MapPlacePickerSearchField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.active,
    required this.onTapPlaceholder,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool active;
  final VoidCallback onTapPlaceholder;

  @override
  Widget build(BuildContext context) {
    if (!active) {
      return ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final text = value.text.trim();
          return _MapPlacePickerSearchPlaceholder(
            text: text.isEmpty ? hintText : text,
            isHint: text.isEmpty,
            onTap: onTapPlaceholder,
          );
        },
      );
    }

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF999999),
                size: 18,
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      onPressed: () => controller.clear(),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.clear,
                        color: Color(0xFF999999),
                        size: 18,
                      ),
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              filled: true,
              fillColor: const Color(0xFFEAE8E8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            textInputAction: TextInputAction.search,
          ),
        );
      },
    );
  }
}

class _MapPlacePickerSearchPlaceholder extends StatelessWidget {
  const _MapPlacePickerSearchPlaceholder({
    required this.text,
    required this.isHint,
    required this.onTap,
  });

  final String text;
  final bool isHint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEAE8E8),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const Icon(
                Icons.search,
                color: Color(0xFF999999),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isHint
                        ? const Color(0xFF999999)
                        : const Color(0xFF333333),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
