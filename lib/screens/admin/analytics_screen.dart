import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/app_colors.dart';
import '../../services/analytics_service.dart';
import 'package:intl/intl.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _userStats = {};
  Map<String, dynamic> _transactionStats = {};
  Map<String, dynamic> _wasteStats = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      final userStats = await AnalyticsService.getUserStats();
      final transactionStats = await AnalyticsService.getTransactionStats();
      final wasteStats = await AnalyticsService.getWasteStats();

      setState(() {
        _userStats = userStats;
        _transactionStats = transactionStats;
        _wasteStats = wasteStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading analytics: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadAnalytics();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Cards
                    _buildStatisticsCards(),
                    const SizedBox(height: 24),

                    // Transaction Status Distribution
                    _buildSectionTitle('Transaction Status'),
                    const SizedBox(height: 12),
                    _buildTransactionStatusChart(),
                    const SizedBox(height: 24),

                    // Waste Type Distribution
                    _buildSectionTitle('Waste Type Distribution'),
                    const SizedBox(height: 12),
                    _buildWasteTypeChart(),
                    const SizedBox(height: 24),

                    // Daily Trends
                    _buildSectionTitle('Daily Trends (Last 7 Days)'),
                    const SizedBox(height: 12),
                    _buildDailyTrendsChart(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatisticsCards() {
    final totals = _transactionStats['totals'] ?? {};
    final totalUsers = _userStats['totalUsers'] ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Users',
          totalUsers.toString(),
          Icons.people,
          AppColors.primary,
        ),
        _buildStatCard(
          'Total Transactions',
          '${totals['total_transactions'] ?? 0}',
          Icons.receipt_long,
          Colors.blue,
        ),
        _buildStatCard(
          'Total Revenue',
          'Rp ${_formatMoney(totals['total_revenue'] ?? 0)}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildStatCard(
          'Avg Transaction',
          'Rp ${_formatMoney(totals['avg_transaction'] ?? 0)}',
          Icons.trending_up,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionStatusChart() {
    final statusStats = (_transactionStats['statusStats'] as List?) ?? [];
    if (statusStats.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: PieChart(
        PieChartData(
          sections: statusStats.map((stat) {
            final status = stat['status'];
            final count = (stat['count'] as num).toInt();
            Color color = AppColors.primary;

            if (status == 'approved')
              color = Colors.green;
            else if (status == 'rejected')
              color = Colors.red;
            else if (status == 'pending')
              color = Colors.orange;

            return PieChartSectionData(
              value: count.toDouble(),
              title: '$count',
              color: color,
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildWasteTypeChart() {
    final wasteDistribution = (_wasteStats['wasteDistribution'] as List?) ?? [];
    if (wasteDistribution.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Take top 5 waste types
    final topWaste = wasteDistribution.take(5).toList();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              topWaste
                  .map((e) => (e['transaction_count'] as num).toDouble())
                  .reduce((a, b) => a > b ? a : b) *
              1.2,
          barGroups: topWaste.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: _parseDouble(entry.value['transaction_count']),
                  color: AppColors.primary,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= topWaste.length) return const Text('');
                  final name = topWaste[value.toInt()]['name'] ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      name,
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildDailyTrendsChart() {
    final dailyTrends = (_transactionStats['dailyTrends'] as List?) ?? [];
    if (dailyTrends.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: dailyTrends.asMap().entries.map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  _parseDouble(entry.value['count']),
                );
              }).toList(),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= dailyTrends.length)
                    return const Text('');
                  final date = dailyTrends[value.toInt()]['date'];
                  final formatted = date != null
                      ? DateFormat('MM/dd').format(DateTime.parse(date))
                      : '';
                  return Text(formatted, style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  String _formatMoney(dynamic amount) {
    if (amount == null) return '0';
    final value = amount is String
        ? double.tryParse(amount) ?? 0.0
        : amount.toDouble();
    return NumberFormat('#,###').format(value);
  }

  // Helper to safely parse numeric values that might be strings from MySQL
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
