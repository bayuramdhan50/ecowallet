import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Splash Screen with EcoWallet branding
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon/Logo
            Icon(Icons.eco, size: 100, color: AppColors.textWhite),
            const SizedBox(height: 20),

            // App Name
            Text(
              'EcoWallet',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 10),

            // Tagline
            Text(
              'Bank Sampah Digital',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textWhite.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 40),

            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textWhite),
            ),
          ],
        ),
      ),
    );
  }
}
