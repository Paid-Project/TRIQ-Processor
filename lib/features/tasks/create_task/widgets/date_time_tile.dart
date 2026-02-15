import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/common/custom_date_picker.dart'; // Existing

class DateTimeTile extends StatelessWidget {
  final String title;
  final DateTime? selectedDateTime;
  final Function(DateTime) onDateTimeSelected;

  const DateTimeTile({
    Key? key,
    required this.title,
    this.selectedDateTime,
    required this.onDateTimeSelected,
  }) : super(key: key);

  Future<void> _selectDateTime(BuildContext context) async {
    // 1. Date pick karein (aapke existing picker se)
    final DateTime? date = await showDatePicker( context:context, initialDate: selectedDateTime ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (date == null) return;

    // 2. Time pick karein
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    // 3. Date aur Time ko combine karein
    final newDateTime =
    DateTime(date.year, date.month, date.day, time.hour, time.minute);
    onDateTimeSelected(newDateTime);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isSelected = selectedDateTime != null;

    return InkWell(
      onTap: () => _selectDateTime(context),
      child: Container(
        padding:  EdgeInsets.symmetric(
            horizontal: AppSizes.w12, vertical: AppSizes.h12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppSizes.h8),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
            ),
            AppGaps.h8,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date Text
                Text(
                  isSelected
                      ? DateFormat('EEE, dd MMM yyyy').format(selectedDateTime!)
                      : LanguageService.get('selectDate'),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textDisabled,
                  ),
                ),
                // Time Text
                Text(
                  isSelected
                      ? DateFormat('hh:mm a').format(selectedDateTime!)
                      : LanguageService.get('selectTime'),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}