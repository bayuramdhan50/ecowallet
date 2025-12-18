import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../models/transaction.dart';
import '../../services/transaction_service.dart';

/// Transaction History Screen
class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final TransactionService _transactionService = TransactionService();
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);

    final transactions = await _transactionService.getUserTransactions();

    if (mounted) {
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.approved;
      case 'rejected':
        return AppColors.rejected;
      default:
        return AppColors.pending;
    }
  }

  String _getStatusText(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        color: AppColors.primary,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : _transactions.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No transactions yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final transaction = _transactions[index];
                  final statusColor = _getStatusColor(transaction.status);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                transaction.wasteTypeName ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: statusColor),
                                ),
                                child: Text(
                                  _getStatusText(transaction.status),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Weight info
                          Row(
                            children: [
                              const Icon(
                                Icons.scale,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Estimated: ${transaction.estimatedWeight} kg',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),

                          if (transaction.actualWeight != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.done,
                                  size: 16,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Actual: ${transaction.actualWeight} kg',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 8),

                          // Earning
                          if (transaction.status == 'approved' &&
                              transaction.totalEarning > 0)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Earning:',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    currencyFormat.format(
                                      transaction.totalEarning,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 8),

                          // Date
                          Text(
                            DateFormat(
                              'dd MMM yyyy, HH:mm',
                            ).format(transaction.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
