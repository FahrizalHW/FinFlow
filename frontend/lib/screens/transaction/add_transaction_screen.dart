import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../../state/app_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../category/category_dropdown.dart';

class AddTransactionScreen extends StatefulWidget {
  /// Diisi saat mengedit transaksi; null berarti tambah transaksi baru.
  final TransactionModel? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'pengeluaran'; // 'pemasukan' or 'pengeluaran'
  final _nominalController = TextEditingController();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  CategoryModel? _selectedCategory;
  int? _pendingCategoryId; // kategori awal saat mode edit

  bool get _isEdit => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    if (tx != null) {
      _selectedType = tx.type.toLowerCase();
      _titleController.text = tx.title;
      _nominalController.text = tx.amount == tx.amount.roundToDouble()
          ? tx.amount.toInt().toString()
          : tx.amount.toString();
      _notesController.text = tx.notes ?? '';
      _selectedDate = tx.date;
      _pendingCategoryId = tx.categoryId;
    }
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
      setState(() => _selectedDate = picked);
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.income,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      _showMessage('Silakan pilih kategori transaksi');
      return;
    }

    final nominal = double.tryParse(
            _nominalController.text.replaceAll('.', '').replaceAll(',', '')) ??
        0;
    if (nominal <= 0) {
      _showMessage('Nominal harus lebih dari 0');
      return;
    }

    final finalDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    final state = AppStateScope.of(context);
    final existing = widget.transaction;
    final error = existing == null
        ? await state.addTransaction(
            title: _titleController.text.trim(),
            amount: nominal,
            type: _selectedType,
            categoryId: _selectedCategory!.id,
            date: finalDateTime,
            notes: _notesController.text.trim(),
          )
        : await state.updateTransaction(
            id: existing.id,
            title: _titleController.text.trim(),
            amount: nominal,
            type: _selectedType,
            categoryId: _selectedCategory!.id,
            date: finalDateTime,
            notes: _notesController.text.trim(),
          );

    if (error != null) {
      _showMessage(error);
      return;
    }

    _showMessage(
      _isEdit ? 'Transaksi berhasil diperbarui' : 'Transaksi berhasil ditambahkan',
      isError: false,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final categories = state.getCategoriesByType(_selectedType);

    // Mode edit: pilih kategori awal milik transaksi (sekali saja).
    if (_pendingCategoryId != null) {
      final match = categories.where((c) => c.id == _pendingCategoryId);
      if (match.isNotEmpty) _selectedCategory = match.first;
      _pendingCategoryId = null;
    }

    // If selectedCategory is no longer in the list (e.g. type changed or deleted)
    if (_selectedCategory != null && !categories.any((c) => c.id == _selectedCategory!.id)) {
      _selectedCategory = categories.isNotEmpty ? categories.first : null;
    } else if (_selectedCategory == null && categories.isNotEmpty) {
      _selectedCategory = categories.first;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Transaksi' : 'Tambah Transaksi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Jenis Transaksi Selector: Pemasukan / Pengeluaran (Matches Gambar L5.11)
                const Text(
                  'Jenis Transaksi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedType = 'pemasukan';
                              _selectedCategory = null;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _selectedType == 'pemasukan' ? AppColors.income : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Pemasukan',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _selectedType == 'pemasukan' ? FontWeight.w700 : FontWeight.w500,
                                color: _selectedType == 'pemasukan' ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedType = 'pengeluaran';
                              _selectedCategory = null;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _selectedType == 'pengeluaran' ? AppColors.expense : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Pengeluaran',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _selectedType == 'pengeluaran' ? FontWeight.w700 : FontWeight.w500,
                                color: _selectedType == 'pengeluaran' ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Nominal Field
                CustomTextField(
                  controller: _nominalController,
                  label: 'Nominal',
                  hintText: 'Contoh: 50000',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.attach_money,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nominal harus diisi';
                    }
                    if (double.tryParse(val) == null) {
                      return 'Masukkan angka nominal yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Nama Transaksi Field
                CustomTextField(
                  controller: _titleController,
                  label: 'Nama Transaksi',
                  hintText: 'Contoh: Makan Siang',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama transaksi harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Dropdown Kategori (Matches Gambar L5.12 & L5.13)
                CategoryDropdown(
                  categories: categories,
                  selectedCategory: _selectedCategory,
                  transactionType: _selectedType,
                  onCategorySelected: (cat) {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                  onAddCategory: (name) async {
                    final error = await state.addCategory(name, _selectedType);
                    if (error != null) _showMessage(error);
                  },
                  onDeleteCategory: (cat) async {
                    final error = await state.deleteCategory(cat.id);
                    if (error != null) _showMessage(error);
                  },
                ),
                const SizedBox(height: 16),

                // Tanggal
                Row(
                  children: [
                    // Tanggal
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tanggal',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                                      AppStyles.formatDate(_selectedDate),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Catatan Tambahan (Opsional)
                CustomTextField(
                  controller: _notesController,
                  label: 'Catatan (Opsional)',
                  hintText: 'Tulis catatan jika diperlukan',
                  maxLines: 3,
                ),
                const SizedBox(height: 28),

                // Action Buttons: Tambah Transaksi & Batal (Matches Gambar L5.11)
                CustomButton(
                  text: _isEdit ? 'Simpan Perubahan' : 'Tambah Transaksi',
                  variant: ButtonVariant.primary,
                  height: 48,
                  onPressed: _saveTransaction,
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Batal',
                  variant: ButtonVariant.outline,
                  height: 48,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}