import 'package:flutter/material.dart';

// SEMENTARA: diganti saat fiturnya dikerjakan.
class TransactionDetailScreen extends StatelessWidget {
  final int transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Detail (sementara)')),
        body: Center(child: Text('Detail transaksi #$transactionId (sementara)')),
      );
}