import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../models/category_model.dart';
import 'add_category_dialog.dart';
import 'delete_category_dialog.dart';

class CategoryDropdown extends StatefulWidget {
  final List<CategoryModel> categories;
  final CategoryModel? selectedCategory;
  final ValueChanged<CategoryModel> onCategorySelected;
  final void Function(String name) onAddCategory;
  final void Function(CategoryModel category) onDeleteCategory;
  final String transactionType;

  const CategoryDropdown({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onAddCategory,
    required this.onDeleteCategory,
    required this.transactionType,
  });

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  bool _isExpanded = false;

  void _openAddCategory() {
    AddCategoryDialog.show(
      context: context,
      transactionType: widget.transactionType,
      onSave: (name) {
        widget.onAddCategory(name);
      },
    );
  }

  void _confirmDeleteCategory(CategoryModel category) {
    DeleteCategoryDialog.show(
      context: context,
      categoryName: category.name,
      onConfirmDelete: () {
        widget.onDeleteCategory(category);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayText = widget.selectedCategory?.name ?? 'Pilih Kategori';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        // Dropdown Header (Matches Gambar L5.12 & L5.13)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppStyles.radiusMedium),
              topRight: const Radius.circular(AppStyles.radiusMedium),
              bottomLeft: Radius.circular(_isExpanded ? 0 : AppStyles.radiusMedium),
              bottomRight: Radius.circular(_isExpanded ? 0 : AppStyles.radiusMedium),
            ),
            border: Border.all(
              color: _isExpanded ? AppColors.primary : AppColors.borderLight,
              width: _isExpanded ? 1.5 : 1.2,
            ),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: widget.selectedCategory != null
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                  // Add Category "+" Button (Gambar L5.12 & L5.13)
                  InkWell(
                    onTap: _openAddCategory,
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 20, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Expand/Collapse Chevron (Gambar L5.12 & L5.13)
                  Icon(
                    _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    size: 22,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Expanded List (Matches Gambar L5.13)
        if (_isExpanded)
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppStyles.radiusMedium),
                bottomRight: Radius.circular(AppStyles.radiusMedium),
              ),
              border: Border(
                left: BorderSide(color: AppColors.primary, width: 1.5),
                right: BorderSide(color: AppColors.primary, width: 1.5),
                bottom: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            child: widget.categories.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Belum ada kategori. Tekan + untuk menambah.',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: widget.categories.length,
                    separatorBuilder: (ctx, i) => const Divider(
                      height: 1,
                      thickness: 0.8,
                      color: AppColors.borderLight,
                    ),
                    itemBuilder: (context, index) {
                      final category = widget.categories[index];
                      final isSelected = widget.selectedCategory?.id == category.id;

                      return ListTile(
                        dense: true,
                        visualDensity: const VisualDensity(vertical: -2),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        title: Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.textSecondary),
                          onPressed: () => _confirmDeleteCategory(category),
                          tooltip: 'Hapus Kategori',
                        ),
                        onTap: () {
                          widget.onCategorySelected(category);
                          setState(() {
                            _isExpanded = false;
                          });
                        },
                      );
                    },
                  ),
          ),
      ],
    );
  }
}

