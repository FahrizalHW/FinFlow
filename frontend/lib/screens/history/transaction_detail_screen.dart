import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../models/transaction_model.dart';
import '../../state/app_state.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_button.dart';
import '../transaction/add_transaction_screen.dart';

class TransactionDetailScreen extends StatefulWidget {
  final int transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  // Disimpan agar layar tidak kosong sesaat ketika data dimuat ulang.
  TransactionModel? _lastTx;
  bool _isDeleting = false;

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

  Future<void> _delete(TransactionModel tx) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Hapus Transaksi?',
      message: 'Transaksi "${tx.title}" akan dihapus.',
      confirmText: 'Hapus',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    final state = AppStateScope.of(context);
    final error = await state.deleteTransaction(tx.id);
    if (!mounted) return;
    setState(() => _isDeleting = false);

    if (error != null) {
      _showMessage(error);
      return;
    }
    _showMessage('Transaksi berhasil dihapus', isError: false);
    Navigator.of(context).pop();
  }

  void _edit(TransactionModel tx) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddTransactionScreen(transaction: tx)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final tx = state.findTransaction(widget.transactionId) ?? _lastTx;
    if (tx != null) _lastTx = tx;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: tx == null
          ? const Center(child: Text('Transaksi tidak ditemukan'))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAmountCard(tx),
                    const SizedBox(height: 16),
                    _buildInfoCard(tx),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Edit Transaksi',
                      variant: ButtonVariant.primary,
                      height: 48,
                      onPressed: _isDeleting ? null : () => _edit(tx),
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      text: 'Hapus Transaksi',
                      variant: ButtonVariant.danger,
                      height: 48,
                      isLoading: _isDeleting,
                      onPressed: _isDeleting ? null : () => _delete(tx),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAmountCard(TransactionModel tx) {
    final color = tx.isIncome ? AppColors.income : AppColors.expense;
    final bg = tx.isIncome ? AppColors.incomeBg : AppColors.expenseBg;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
      ),
      child: Column(
        children: [
          Text(
            tx.isIncome ? 'Pemasukan' : 'Pengeluaran',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStyles.formatRupiah(tx.amount,
                showSign: true, isIncome: tx.isIncome),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(TransactionModel tx) {
    final notes = (tx.notes == null || tx.notes!.trim().isEmpty)
        ? '-'
        : tx.notes!.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        children: [
          _row('Nama Transaksi', tx.title),
          _divider(),
          _row('Kategori', tx.categoryName.isEmpty ? '-' : tx.categoryName),
          _divider(),
          _row('Tanggal', AppStyles.formatDate(tx.date)),
          _divider(),
          _row('Waktu', AppStyles.formatTime(tx.date)),
          _divider(),
          _row('Catatan', notes),
        ],
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, thickness: 1, color: AppColors.borderLight);

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
