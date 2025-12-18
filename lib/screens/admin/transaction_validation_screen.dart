import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../models/transaction.dart';
import '../../services/transaction_service.dart';

/// Transaction Validation Screen (SubCPMK 3 - Display Calculation Result)
/// Admin validates deposits and sees bonus calculation
class TransactionValidationScreen extends StatefulWidget {
  const TransactionValidationScreen({super.key});

  @override
  State<TransactionValidationScreen> createState() =>
      _TransactionValidationScreenState();
}

class _TransactionValidationScreenState
    extends State<TransactionValidationScreen> {
  final TransactionService _transactionService = TransactionService();
  List<Transaction> _pendingTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingTransactions();
  }

  Future<void> _loadPendingTransactions() async {
    setState(() => _isLoading = true);

    final transactions = await _transactionService.getPendingTransactions();

    if (mounted) {
      setState(() {
        _pendingTransactions = transactions;
        _isLoading = false;
      });
    }
  }

  void _showValidationDialog(Transaction transaction) {
    final weightController = TextEditingController(
      text: transaction.estimatedWeight.toString(),
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Validate Transaction'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.wasteTypeName ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Actual Weight (kg)',
                    hintText: 'Enter actual weight after weighing',
                    prefixIcon: const Icon(
                      Icons.scale,
                      color: AppColors.primary,
                    ),
                    suffixText: 'kg',
                    helperText: 'Estimated: ${transaction.estimatedWeight} kg',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter actual weight';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight <= 0) {
                      return 'Please enter valid weight';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _rejectTransaction(transaction.id),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final actualWeight = double.parse(weightController.text);
                Navigator.pop(context);
                _approveTransaction(transaction.id, actualWeight);
              }
            },
            child: const Text('Approve & Calculate'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveTransaction(
    int transactionId,
    double actualWeight,
  ) async {
    final result = await _transactionService.validateTransaction(
      transactionId: transactionId,
      action: 'approve',
      actualWeight: actualWeight,
    );

    if (!mounted) return;

    if (result['success']) {
      final data = result['data'];
      _showCalculationResult(data);
      _loadPendingTransactions();
    } else {
      _showError(result['message'] ?? 'Failed to approve');
    }
  }

  Future<void> _rejectTransaction(int transactionId) async {
    Navigator.pop(context); // Close dialog

    final result = await _transactionService.validateTransaction(
      transactionId: transactionId,
      action: 'reject',
    );

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction rejected'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadPendingTransactions();
    } else {
      _showError(result['message'] ?? 'Failed to reject');
    }
  }

  void _showCalculationResult(Map<String, dynamic> data) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            SizedBox(width: 12),
            Text('Calculation Result'),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultRow('Actual Weight:', '${data['actual_weight']} kg'),
              const Divider(),
              _buildResultRow(
                'Base Price:',
                currencyFormat.format(data['base_price_per_kg']) + '/kg',
              ),
              if (data['bonus_applied'] == true) ...[
                _buildResultRow(
                  'Bonus:',
                  '+ ${currencyFormat.format(data['bonus_amount'])}/kg',
                  color: AppColors.success,
                ),
                _buildResultRow(
                  'Effective Price:',
                  currencyFormat.format(data['effective_price_per_kg']) + '/kg',
                  isBold: true,
                ),
              ],
              const Divider(),
              const SizedBox(height: 8),
              _buildResultRow(
                'Total Earning:',
                currencyFormat.format(data['total_earning']),
                isBold: true,
                isLarge: true,
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    String value, {
    bool isBold = false,
    bool isLarge = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isLarge ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Validation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingTransactions,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPendingTransactions,
        color: AppColors.primary,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : _pendingTransactions.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No pending transactions',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _pendingTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = _pendingTransactions[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _showValidationDialog(transaction),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                    color: AppColors.pending.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.pending,
                                    ),
                                  ),
                                  child: const Text(
                                    'Pending',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.pending,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
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
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
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
                    ),
                  );
                },
              ),
      ),
    );
  }
}
