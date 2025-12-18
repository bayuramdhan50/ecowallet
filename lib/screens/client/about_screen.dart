import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_colors.dart';

/// About Screen with App Information and API Credits (SubCPMK 2)
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.eco, size: 50, color: AppColors.primary),
            ),
            const SizedBox(height: 24),

            // App Name
            const Text(
              'EcoWallet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Version
            Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Description
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About EcoWallet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'EcoWallet is a digital waste bank application that helps you manage waste deposits and earn money by recycling. Track your balance, submit waste deposits, and stay updated with environmental news.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Features
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    Icons.account_balance_wallet,
                    'Digital Balance Tracking',
                  ),
                  _buildFeatureItem(
                    Icons.recycling,
                    'Easy Waste Deposit Submission',
                  ),
                  _buildFeatureItem(Icons.history, 'Transaction History'),
                  _buildFeatureItem(
                    Icons.newspaper,
                    'Environmental News Integration',
                  ),
                  _buildFeatureItem(
                    Icons.calculate,
                    'Automatic Earning Calculation',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // API Credits (SubCPMK 2 Requirement)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.public, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Data Sources',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Environmental news powered by:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _launchURL('https://newsapi.org'),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.link,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NewsAPI.org',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  'Breaking news headlines and articles',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.open_in_new,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Footer
            Text(
              '© 2025 EcoWallet. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Made with 💚 for a greener future',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
