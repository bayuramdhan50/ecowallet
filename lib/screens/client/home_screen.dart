import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../models/news_article.dart';
import '../../services/news_service.dart';
import '../../widgets/news_card.dart';
import 'deposit_screen.dart';
import 'transaction_history_screen.dart';
import 'about_screen.dart';
import '../auth/login_screen.dart';

/// Client Home Screen - Dashboard with Balance & NewsAPI Integration
/// Features: Balance display, NewsAPI cards (SubCPMK 2), Quick actions
class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final NewsService _newsService = NewsService();
  List<NewsArticle> _newsArticles = [];
  bool _isLoadingNews = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadNews();
    _refreshUserData();
  }

  Future<void> _loadNews() async {
    setState(() => _isLoadingNews = true);

    final articles = await _newsService.fetchEnvironmentNews();

    if (mounted) {
      setState(() {
        _newsArticles = articles;
        _isLoadingNews = false;
      });
    }
  }

  Future<void> _refreshUserData() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.refreshUser();
  }

  Future<void> _handleRefresh() async {
    await Future.wait([_loadNews(), _refreshUserData()]);
  }

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);

    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
      );
    } else if (index == 2) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const AboutScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primary,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildBalanceCard(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 32),
                _buildNewsSection(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello,',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  auth.user?.name ?? 'User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.textSecondary),
              onPressed: () async {
                await auth.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBalanceCard() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final balance = auth.user?.balance ?? 0.0;
        final currencyFormat = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.textWhite.withOpacity(0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total Balance',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textWhite.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                currencyFormat.format(balance),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.recycling,
            label: 'Deposit',
            color: AppColors.primary,
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const DepositScreen()));
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.history,
            label: 'History',
            color: AppColors.secondary,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TransactionHistoryScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Eco News',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: _loadNews,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_isLoadingNews)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          )
        else if (_newsArticles.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.newspaper, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'No news available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          ..._newsArticles.map((article) {
            return NewsCard(
              title: article.title,
              description: article.description,
              imageUrl: article.urlToImage,
              publishedAt: article.publishedAt,
              onTap: () {
                // Could open URL in browser
              },
            );
          }).toList(),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
        ],
      ),
    );
  }
}
