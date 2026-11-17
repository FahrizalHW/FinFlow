import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../models/category_model.dart';
import '../../widgets/custom_button.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<CategoryModel> categories;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? initialCategory;
  final void Function(DateTime? start, DateTime? end, String? category) onApply;
  final VoidCallback onReset;

  const FilterBottomSheet({
    super.key,
    required this.categories,
    this.initialStartDate,
    this.initialEndDate,
    this.initialCategory,
    required this.onApply,
    required this.onReset,
  });

  static Future<void> show({
    required BuildContext context,
    required List<CategoryModel> categories,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    String? initialCategory,
    required void Function(DateTime? start, DateTime? end, String? category) onApply,
    required VoidCallback onReset,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppStyles.radiusLarge)),
      ),
      builder: (ctx) => FilterBottomSheet(
        categories: categories,
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
        initialCategory: initialCategory,
        onApply: onApply,
        onReset: onReset,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _selectedCategory = widget.initialCategory ?? 'Semua Kategori';
  }

  Future<void> _selectDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_startDate != null && _startDate!.isAfter(_endDate!)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Unique category names
    final categoryNames = <String>['Semua Kategori'];
    for (final c in widget.categories) {
      if (!categoryNames.contains(c.name)) {
        categoryNames.add(c.name);
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Transaksi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(height: 16, color: AppColors.borderLight),
          const SizedBox(height: 12),

          // Rentang Tanggal (Matches Gambar L5.7)
          const Text(
            'Rentang Tanggal',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Dari Tanggal
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(true),
                  borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                      border: Border.all(color: AppColors.borderLight, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _startDate != null ? AppStyles.formatDate(_startDate!) : 'Dari Tanggal',
                            style: TextStyle(
                              fontSize: 12,
                              color: _startDate != null ? AppColors.textPrimary : AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Sampai Tanggal
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(false),
                  borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                      border: Border.all(color: AppColors.borderLight, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _endDate != null ? AppStyles.formatDate(_endDate!) : 'Sampai Tanggal',
                            style: TextStyle(
                              fontSize: 12,
                              color: _endDate != null ? AppColors.textPrimary : AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Kategori (Matches Gambar L5.7)
          const Text(
            'Kategori',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
              border: Border.all(color: AppColors.borderLight, width: 1.2),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: categoryNames.contains(_selectedCategory) ? _selectedCategory : 'Semua Kategori',
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                items: categoryNames.map((name) {
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Action Buttons: Reset & Terapkan Filter (Gambar L5.7)
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Reset',
                  variant: ButtonVariant.outline,
                  onPressed: () {
                    widget.onReset();
                    Navigator.of(context).pop();
                  },
                  height: 46,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Terapkan Filter',
                  variant: ButtonVariant.primary,
                  onPressed: () {
                    widget.onApply(_startDate, _endDate, _selectedCategory);
                    Navigator.of(context).pop();
                  },
                  height: 46,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

