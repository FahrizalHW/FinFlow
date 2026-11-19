import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../state/app_state.dart';
import '../../widgets/load_error_banner.dart';
import '../../widgets/transaction_tile.dart';
import 'filter_bottom_sheet.dart';
import 'transaction_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  void _openFilter(BuildContext context) {
    final state = AppStateScope.of(context);
    FilterBottomSheet.show(
      context: context,
      categories: state.categories,
      initialStartDate: state.filterStartDate,
      initialEndDate: state.filterEndDate,
      initialCategory: state.filterCategory,
      onApply: (start, end, category) {
        state.applyFilter(
          startDate: start,
          endDate: end,
          category: category,
        );
      },
      onReset: () {
        state.resetFilter();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final transactions = state.filteredTransactions;
    final currentTab = state.historyTab;

    // Angka ini dihitung oleh backend sesuai tab dan filter aktif.
    final displayedSum = state.displayedSum;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Blue Summary Card at top of Riwayat (Matches Gambar L5.6)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                  boxShadow: AppStyles.elevatedShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentTab == 'Semua'
                              ? 'Total Saldo'
                              : currentTab == 'Pemasukan'
                                  ? 'Total Pemasukan'
                                  : 'Total Pengeluaran',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStyles.formatRupiah(displayedSum),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tab Filter Bar & Filter Button sejajar di kanan (Matches Gambar L5.6)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Row(
                        children: [
                          _buildTabButton(context, 'Semua', currentTab == 'Semua'),
                          _buildTabButton(context, 'Pemasukan', currentTab == 'Pemasukan'),
                          _buildTabButton(context, 'Pengeluaran', currentTab == 'Pengeluaran'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Filter Icon Button Sejajar di Kanan
                  GestureDetector(
                    onTap: () => _openFilter(context),
                    child: Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: state.isFilterActive ? AppColors.primaryLight : Colors.white,
                        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                        border: Border.all(
                          color: state.isFilterActive ? AppColors.primary : AppColors.borderLight,
                          width: 1.2,
                        ),
                        boxShadow: AppStyles.cardShadow,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.filter_list_rounded,
                            color: state.isFilterActive ? AppColors.primary : AppColors.textSecondary,
                            size: 20,
                          ),
                          if (state.isFilterActive)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Active Indicator
            if (state.isFilterActive)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'Filter aktif diterapkan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => state.resetFilter(),
                        child: const Text(
                          'Hapus Filter',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Error pemuatan data + tombol coba lagi
            if (state.loadError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: LoadErrorBanner(
                  message: state.loadError!,
                  onRetry: state.refreshAll,
                ),
              ),

            // Garis loading tipis saat memuat ulang data yang sudah ada
            if (state.isLoading && transactions.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(minHeight: 2),
              ),

            const SizedBox(height: 8),

            // Transaction List (tarik ke bawah untuk memuat ulang)
            Expanded(
              child: RefreshIndicator(
                onRefresh: state.refreshAll,
                child: transactions.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: 280,
                            child: Center(
                              child: state.isLoading
                                  ? const CircularProgressIndicator()
                                  : state.loadError != null
                                      ? const SizedBox.shrink()
                                      : Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.receipt_long_outlined,
                                              size: 54,
                                              color: AppColors.textMuted.withAlpha(120),
                                            ),
                                            const SizedBox(height: 12),
                                            const Text(
                                              'Tidak ada transaksi yang sesuai',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          return TransactionTile(
                            transaction: tx,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => TransactionDetailScreen(transactionId: tx.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, String tab, bool isSelected) {
    final state = AppStateScope.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => state.setHistoryTab(tab),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            tab,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}