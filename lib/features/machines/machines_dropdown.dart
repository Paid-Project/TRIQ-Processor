//================= Machine DropDown (UPDATED) ==========

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manager/services/language.service.dart';

import '../../core/models/machine.dart';
import '../../resources/app_resources/app_resources.dart';

class MachineDropdownFormField extends FormField<Machine> {
  MachineDropdownFormField({
    Key? key,
    required List<Machine> items,
    required ValueChanged<Machine?> onChanged,
    FormFieldSetter<Machine>? onSaved,
    FormFieldValidator<Machine>? validator,
    Machine? initialValue,
    String hintText = 'Select a machine',
    bool isRequired = true,
    bool hasError = false,
  }) : super(
    key: key,
    onSaved: onSaved,
    initialValue: initialValue,
    validator: validator,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    builder: (FormFieldState<Machine> state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomMachineDropdown(
            items: items,
            hintText: hintText,
            initialSelectedMachine: state.value,
            hasError: state.hasError, // ✨ NEW: Pass error state
            onChanged: (Machine? machine) {
              state.didChange(machine);
              onChanged(machine);
            },
          ),
          // Error text display
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 6.0),
              child: Text(
                state.errorText!,
                style: TextStyle(
                  color: Theme.of(state.context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    },
  );
}

class CustomMachineDropdown extends StatefulWidget {
  final String hintText;
  final List<Machine> items;
  final ValueChanged<Machine?> onChanged;
  final Machine? initialSelectedMachine;
  final bool hasError; // ✨ NEW: Error flag

  const CustomMachineDropdown({
    super.key,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.initialSelectedMachine,
    this.hasError = false, // ✨ NEW: Default false
  });

  @override
  State<CustomMachineDropdown> createState() => _CustomMachineDropdownState();
}

class _CustomMachineDropdownState extends State<CustomMachineDropdown> {
  RxBool _isExpanded = false.obs;
  late List<Machine> _filteredItems;
  Machine? selectedMachine;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.items);

    if (widget.initialSelectedMachine != null) {
      selectedMachine = widget.initialSelectedMachine;
    }

    _searchController.addListener(_filterItems);
  }

  @override
  void didUpdateWidget(CustomMachineDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      setState(() {
        _filteredItems = List.from(widget.items);
      });
    }
    if (oldWidget.initialSelectedMachine != widget.initialSelectedMachine) {
      setState(() {
        selectedMachine = widget.initialSelectedMachine;
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) {
        final nameMatch = item.machineName?.toLowerCase().contains(query) ?? false;
        final serialMatch = item.serialNumber?.toLowerCase().contains(query) ?? false;
        return nameMatch || serialMatch;
      }).toList();
    });
  }

  void _toggleDropdown() {

      _isExpanded.value = !_isExpanded.value;

  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggleDropdown,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: widget.hasError ? AppColors.error : Colors.grey.shade300,
            width: widget.hasError ? 1.0 : 1.0,
          ),
        ),
        child: Obx(()=>Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            if (_isExpanded.value) const Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F1)),
            _isExpanded.value ? _buildContent() : const SizedBox.shrink(),
          ],
        )),
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: _toggleDropdown,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedMachine == null ? widget.hintText : selectedMachine?.machineName ?? '',
              style: TextStyle(
                color: selectedMachine == null ? Colors.grey.shade700 : AppColors.black,
                fontSize: 13,
              ),
            ),
            Obx(()=>Icon(
              _isExpanded.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.grey.shade700,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSearchField(),
        _buildListView(),
      ],
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () {
              _searchController.clear();
            },
          )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 400,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 8),
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) {
          final machine = _filteredItems[index];
          return _buildListItem(machine);
        },
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade200,
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(Machine machine) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedMachine = machine;
        });
        widget.onChanged(machine);
        _toggleDropdown();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: Text(
                  (machine.machine_type ?? 'NA').substring(0, 2).toUpperCase(),
                  style: TextStyle(
                    color: Colors.indigo.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${machine.modelNumber?.toUpperCase()} - ${machine.machineName?.toUpperCase()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    machine.remarks != '' ? '${"add_on".lang}: ${machine.remarks}' : '',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

