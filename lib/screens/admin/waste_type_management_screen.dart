import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../models/waste_type.dart';
import '../../services/waste_type_service.dart';

/// Waste Type Management Screen - CRUD for waste types
class WasteTypeManagementScreen extends StatefulWidget {
  const WasteTypeManagementScreen({super.key});

  @override
  State<WasteTypeManagementScreen> createState() =>
      _WasteTypeManagementScreenState();
}

class _WasteTypeManagementScreenState extends State<WasteTypeManagementScreen> {
  final WasteTypeService _wasteTypeService = WasteTypeService();
  List<WasteType> _wasteTypes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWasteTypes();
  }

  Future<void> _loadWasteTypes() async {
    setState(() => _isLoading = true);

    final types = await _wasteTypeService.getWasteTypes();

    if (mounted) {
      setState(() {
        _wasteTypes = types;
        _isLoading = false;
      });
    }
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final thresholdController = TextEditingController();
    final bonusController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Waste Type'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price per kg (Rp)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: thresholdController,
                  decoration: const InputDecoration(
                    labelText: 'Bonus Threshold (kg)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: bonusController,
                  decoration: const InputDecoration(
                    labelText: 'Bonus Amount (Rp/kg)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
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
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final result = await _wasteTypeService.createWasteType(
                  name: nameController.text,
                  pricePerKg: double.parse(priceController.text),
                  bonusThreshold: double.parse(thresholdController.text),
                  bonusAmount: double.parse(bonusController.text),
                );
                if (context.mounted) Navigator.pop(context);
                if (result['success']) {
                  _loadWasteTypes();
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWasteType(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Waste Type'),
        content: Text('Delete $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _wasteTypeService.deleteWasteType(id);
      if (result['success']) {
        _loadWasteTypes();
      }
    }
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
        title: const Text('Waste Type Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWasteTypes,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : _wasteTypes.isEmpty
          ? const Center(child: Text('No waste types'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _wasteTypes.length,
              itemBuilder: (context, index) {
                final type = _wasteTypes[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.secondary.withOpacity(0.2),
                      child: const Icon(
                        Icons.recycling,
                        color: AppColors.secondary,
                      ),
                    ),
                    title: Text(
                      type.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price: ${currencyFormat.format(type.pricePerKg)}/kg',
                        ),
                        if (type.bonusThreshold > 0)
                          Text(
                            'Bonus: ${currencyFormat.format(type.bonusAmount)}/kg for >${type.bonusThreshold}kg',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () => _deleteWasteType(type.id, type.name),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
