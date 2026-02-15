import 'package:flutter/material.dart';

import '../../resources/app_resources/app_resources.dart';

class InlineDropdownFormField extends StatefulWidget {
  final String? value;
  final String label;
  final List<Map<String, String>> items;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final double maxMenuHeight;

  const InlineDropdownFormField({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
    required this.validator,
    this.maxMenuHeight = 150,
  });

  @override
  State<InlineDropdownFormField> createState() =>
      _InlineDropdownFormFieldState();
}

class _InlineDropdownFormFieldState extends State<InlineDropdownFormField>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  String? _displayForValue(String? value) {
    if (value == null) return null;
    for (final item in widget.items) {
      if (item['value'] == value) {
        return item['display'];
      }
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.value,
      validator: widget.validator,
      builder: (fieldState) {
        final selectedDisplay = _displayForValue(fieldState.value);
        final effectiveEnabled = widget.onChanged != null;
        final hasError = fieldState.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dropdown Header
            GestureDetector(
              onTap: effectiveEnabled ? _toggleDropdown : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.v12),
                  border: Border.all(
                    color: hasError
                        ? AppColors.error
                        : _isExpanded
                            ? AppColors.primary
                            : AppColors.lightGrey,
                    width: _isExpanded || hasError ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Label (always visible, smaller when value selected)
                          Text(
                            widget.label,
                            style: TextStyle(
                              fontSize: selectedDisplay != null ? 11 : 14,
                              color: hasError
                                  ? AppColors.error
                                  : _isExpanded
                                      ? AppColors.primary
                                      : AppColors.textGrey,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          // Selected value
                          if (selectedDisplay != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              selectedDisplay,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: effectiveEnabled
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Animated Arrow Icon
                    RotationTransition(
                      turns: _rotateAnimation,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: hasError
                            ? AppColors.error
                            : _isExpanded
                                ? AppColors.primary
                                : AppColors.textGrey,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Error Text
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 6),
                child: Text(
                  fieldState.errorText ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                ),
              ),

            // Dropdown Menu (Animated)
            SizeTransition(
              sizeFactor: _expandAnimation,
              axisAlignment: -1,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  constraints: BoxConstraints(maxHeight: widget.maxMenuHeight),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSizes.v12),
                    border: Border.all(color: AppColors.lightGrey),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.v12),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      shrinkWrap: true,
                      itemCount: widget.items.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        thickness: 0.5,
                        color: AppColors.lightGrey.withOpacity(0.5),
                        indent: 12,
                        endIndent: 12,
                      ),
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        final value = item['value'];
                        final display = item['display'] ?? value ?? '';
                        final isSelected = value == fieldState.value;

                        return InkWell(
                          onTap: effectiveEnabled
                              ? () {
                                  fieldState.didChange(value);
                                  widget.onChanged?.call(value);
                                  _toggleDropdown();
                                }
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.08)
                                : Colors.transparent,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    display,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_rounded,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
