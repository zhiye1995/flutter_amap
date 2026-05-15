part of '../../../../../flutter_amap.dart';

class _LocationPickerSearchBar extends StatelessWidget {
  const _LocationPickerSearchBar({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.currentLocationText,
    required this.includeCurrentLocation,
    required this.onBack,
    required this.onCurrentLocation,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final String currentLocationText;
  final bool includeCurrentLocation;
  final VoidCallback onBack;
  final VoidCallback onCurrentLocation;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: const Color(0x14000000),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.only(left: 4, right: 10),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              ),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: hintText,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF9E9E9E),
                        size: 20,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 34,
                        minHeight: 34,
                      ),
                      suffixIcon: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: controller,
                        builder: (context, value, _) {
                          if (value.text.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return IconButton(
                            onPressed: controller.clear,
                            constraints: const BoxConstraints(
                              minWidth: 34,
                              minHeight: 34,
                            ),
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.cancel,
                              color: Color(0xFFBDBDBD),
                              size: 20,
                            ),
                          );
                        },
                      ),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 34,
                        minHeight: 34,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0F0F0),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              if (includeCurrentLocation) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: onCurrentLocation,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF3478F6),
                          size: 18,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          currentLocationText,
                          style: const TextStyle(
                            color: Color(0xFF3478F6),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
