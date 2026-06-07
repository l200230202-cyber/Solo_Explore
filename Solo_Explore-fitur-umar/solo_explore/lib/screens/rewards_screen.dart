import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/api_service.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _availableRewards = [];
  List<Map<String, dynamic>> _myRewards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final available = await ApiService().getAvailableRewards();
      final my = await ApiService().getMyRewards();

      if (mounted) {
        setState(() {
          _availableRewards = available;
          _myRewards = my;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _claimReward(int id, String name) async {
    final success = await ApiService().claimReward(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name berhasil diklaim!'), backgroundColor: Colors.green),
      );
      _loadData();
    }
  }

  Future<void> _useReward(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Gunakan Reward', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text('Apakah Anda yakin ingin menggunakan $name?', style: GoogleFonts.beVietnamPro()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.beVietnamPro()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Gunakan', style: GoogleFonts.beVietnamPro()),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService().useReward(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name berhasil digunakan!'), backgroundColor: Colors.green),
        );
        _loadData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Rewards',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.beVietnamPro(),
          tabs: const [
            Tab(text: 'Tersedia'),
            Tab(text: 'Saya'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Available Rewards
                _availableRewards.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada reward tersedia',
                          style: GoogleFonts.beVietnamPro(color: AppColors.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: _availableRewards.length,
                        itemBuilder: (context, index) {
                          final reward = _availableRewards[index];
                          return _RewardCard(
                            name: reward['name'] ?? 'Reward',
                            description: reward['description'] ?? '',
                            points: reward['points_required'] ?? 0,
                            onClaim: () => _claimReward(reward['id'], reward['name']),
                            isAvailable: true,
                          );
                        },
                      ),
                // My Rewards
                _myRewards.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada reward',
                          style: GoogleFonts.beVietnamPro(color: AppColors.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: _myRewards.length,
                        itemBuilder: (context, index) {
                          final reward = _myRewards[index];
                          final isUsed = reward['is_used'] == true;
                          return _RewardCard(
                            name: reward['name'] ?? 'Reward',
                            description: reward['description'] ?? '',
                            points: 0,
                            onClaim: isUsed ? null : () => _useReward(reward['id'], reward['name']),
                            isAvailable: false,
                            isUsed: isUsed,
                          );
                        },
                      ),
              ],
            ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final String name, description;
  final int points;
  final VoidCallback? onClaim;
  final bool isAvailable;
  final bool isUsed;

  const _RewardCard({
    required this.name,
    required this.description,
    required this.points,
    this.onClaim,
    required this.isAvailable,
    this.isUsed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isUsed ? AppColors.surfaceContainer : AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUsed ? Icons.check_circle : Icons.redeem,
              color: isUsed ? AppColors.outline : AppColors.secondary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (isAvailable) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.stars, size: 14, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        '$points poin',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (isUsed) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Sudah digunakan',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onClaim != null)
            ElevatedButton(
              onPressed: onClaim,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                isAvailable ? 'Klaim' : 'Gunakan',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
