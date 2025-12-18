import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../models/waste_type.dart';
import '../../services/waste_type_service.dart';
import '../../services/transaction_service.dart';
import 'package:intl/intl.dart';

/// Deposit Screen - Submit Waste Deposit Request
class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final WasteTypeService _wasteTypeService = WasteTypeService();
  final TransactionService _transactionService = TransactionService();

  List<WasteType> _wasteTypes = [];
  WasteType? _selectedWasteType;
  File? _selectedImage;
  bool _isLoading = false;
  bool _isLoadingWasteTypes = true;
  double _estimatedEarning = 0.0;

  @override
  void initState() {
    super.initState();
    _loadWasteTypes();
    _weightController.addListener(_calculateEstimate);
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadWasteTypes() async {
    setState(() => _isLoadingWasteTypes = true);

    final types = await _wasteTypeService.getWasteTypes();

    if (mounted) {
      setState(() {
        _wasteTypes = types;
        _isLoadingWasteTypes = false;
      });
    }
  }

  void _calculateEstimate() {
    if (_selectedWasteType == null) return;

    final weight = double.tryParse(_weightController.text) ?? 0.0;
    setState(() {
      _estimatedEarning = _selectedWasteType!.calculateEstimate(weight);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWasteType == null) {
      _showError('Please select waste type');
      return;
    }

    setState(() => _isLoading = true);

    final weight = double.parse(_weightController.text);

    final result = await _transactionService.submitDeposit(
      wasteTypeId: _selectedWasteType!.id,
      estimatedWeight: weight,
      photo: _selectedImage,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      _showSuccessDialog();
    } else {
      _showError(result['message'] ?? 'Failed to submit');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            SizedBox(width: 12),
            Text('Deposit Submitted'),
          ],
        ),
        content: const Text(
          'Your waste deposit request has been submitted. Please wait for admin validation.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to home
            },
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Deposit Waste')),
      body: _isLoadingWasteTypes
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Waste type dropdown
                    DropdownButtonFormField<WasteType>(
                      value: _selectedWasteType,
                      decoration: const InputDecoration(
                        labelText: 'Waste Type',
                        prefixIcon: Icon(
                          Icons.category,
                          color: AppColors.primary,
                        ),
                      ),
                      items: _wasteTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            '${type.name} - ${currencyFormat.format(type.pricePerKg)}/kg',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedWasteType = value;
                          _calculateEstimate();
                        });
                      },
                      validator: (value) {
                        if (value == null) return 'Please select waste type';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Weight input
                    TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Estimated Weight (kg)',
                        hintText: '0.0',
                        prefixIcon: Icon(Icons.scale, color: AppColors.primary),
                        suffixText: 'kg',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter weight';
                        }
                        final weight = double.tryParse(value);
                        if (weight == null || weight <= 0) {
                          return 'Please enter valid weight';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Photo upload
                    InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tap to take photo',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Estimated earning
                    if (_selectedWasteType != null && _estimatedEarning > 0)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Estimated Earning:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(_estimatedEarning),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_selectedWasteType!.bonusThreshold > 0)
                              Text(
                                'Bonus ${currencyFormat.format(_selectedWasteType!.bonusAmount)}/kg for weight > ${_selectedWasteType!.bonusThreshold}kg',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 32),

                    // Submit button
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            child: const Text('Submit Deposit'),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
