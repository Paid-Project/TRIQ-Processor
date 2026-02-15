import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:manager/resources/app_resources/app_resources.dart';

class CommonCountryPicker extends StatelessWidget {
  final Country? selectedCountry;
  final Function(Country?) onCountryChanged;
  final bool isReadOnly;
  final String? hintText;
  final String? Function(Country?)? validator;

  const CommonCountryPicker({
    Key? key,
    this.selectedCountry,
    required this.onCountryChanged,
    this.isReadOnly = false,
    this.hintText,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormField<Country>(
      initialValue: selectedCountry,
      validator: validator,
      builder: (FormFieldState<Country> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: isReadOnly ? null : () => _showCountryPicker(context, state),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: state.hasError ? AppColors.error : AppColors.lightGrey),
                  borderRadius: BorderRadius.circular(AppSizes.h12),
                  color: isReadOnly
                      ? AppColors.lightGrey.withOpacity(0.3)
                      : AppColors.white,
                ),
                child: Row(
                  children: [
                    if (selectedCountry != null) ...[
                      Text(
                        selectedCountry!.flag,
                        style: TextStyle(fontSize: 22),
                      ),
                      SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        selectedCountry?.name ?? hintText ?? 'Select Country',
                        style: TextStyle(
                          color: selectedCountry != null
                              ? AppColors.black
                              : AppColors.textGrey,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    if (!isReadOnly)
                     Icon(Icons.arrow_drop_down, color: AppColors.textGrey),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _showCountryPicker(BuildContext context, FormFieldState<Country> state) async {
    final Country? selected = await showDialog<Country>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return _CountryPickerDialog(
          selectedCountry: selectedCountry,
          onCountrySelected: (country) {
            Navigator.of(dialogContext).pop(country);
          },
        );
      },
    );

    if (selected != null) {
      state.didChange(selected);
      onCountryChanged(selected);
    }
  }
}

// Internal Country Picker Dialog
class _CountryPickerDialog extends StatefulWidget {
  final Country? selectedCountry;
  final Function(Country) onCountrySelected;

  const _CountryPickerDialog({
    Key? key,
    this.selectedCountry,
    required this.onCountrySelected,
  }) : super(key: key);

  @override
  State<_CountryPickerDialog> createState() => _CountryPickerDialogState();
}

class _CountryPickerDialogState extends State<_CountryPickerDialog> {
  late TextEditingController _searchController;
  List<Country> _filteredCountries = countries.toList();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = countries.toList();
      } else {
        _filteredCountries = countries.where((country) {
          return country.name.toLowerCase().contains(query.toLowerCase()) ||
              country.code.toLowerCase().contains(query.toLowerCase()) ||
              country.dialCode.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            // Header
            // Container(
            //   padding: EdgeInsets.all(10),
            //   decoration: BoxDecoration(
            //     // color: AppColors.primary,
            //     borderRadius: BorderRadius.only(
            //       topLeft: Radius.circular(12),
            //       topRight: Radius.circular(12),
            //     ),
            //   ),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: Text(
            //           'Select Country',
            //           style: TextStyle(
            //             color: Colors.white,
            //             fontSize: 18,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //       ),
            //       IconButton(
            //         icon: Icon(Icons.close, color: Colors.white),
            //         onPressed: () => Navigator.of(context).pop(),
            //         padding: EdgeInsets.zero,
            //         constraints: BoxConstraints(),
            //       ),
            //     ],
            //   ),
            // ),

            // Search Field
            Container(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search country',
                  prefixIcon: Icon(Icons.search, color: AppColors.textGrey),
                  filled: true,
                  fillColor: AppColors.lightGrey.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.lightGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.lightGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: _filterCountries,
              ),
            ),

            // Country List
            Expanded(
              child: ListView.builder(
                itemCount: _filteredCountries.length,
                padding: EdgeInsets.only(bottom: 8),
                itemBuilder: (context, index) {
                  final country = _filteredCountries[index];
                  final isSelected = widget.selectedCountry?.code == country.code;

                  return ListTile(
                    leading: Text(
                      country.flag,
                      style: TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      country.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : AppColors.black,
                      ),
                    ),
                    // subtitle: Text(
                    //   '+${country.dialCode}',
                    //   style: TextStyle(
                    //     color: AppColors.textGrey,
                    //     fontSize: 12,
                    //   ),
                    // ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: AppColors.primary)
                        : null,
                    selected: isSelected,
                    selectedTileColor: AppColors.primary.withOpacity(0.1),
                    onTap: () => widget.onCountrySelected(country),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}