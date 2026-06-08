import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../core/app_router.dart';
import '../widgets/notification_badge.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _tripPlans = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTripPlans();
  }

  Future<void> _loadTripPlans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getTripPlans();
      // ✅ PERBAIKAN: Menghapus response != null dan ganti ?[ menjadi [
      if ((response['success'] ?? false) == true) {
        setState(() {
          _tripPlans = response['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              response['message'] ?? 'Gagal memuat rencana perjalanan';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _showCreatePlanDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Buat Rencana Baru',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Rencana',
                    hintText: 'Contoh: Liburan ke Solo',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi (opsional)',
                    hintText: 'Ceritakan tentang rencana perjalananmu',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    'Tanggal Mulai',
                    style: GoogleFonts.beVietnamPro(fontSize: 12),
                  ),
                  subtitle: Text(
                    startDate != null
                        ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                        : 'Pilih tanggal',
                    style: GoogleFonts.beVietnamPro(),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => startDate = date);
                    }
                  },
                ),
                ListTile(
                  title: Text(
                    'Tanggal Selesai',
                    style: GoogleFonts.beVietnamPro(fontSize: 12),
                  ),
                  subtitle: Text(
                    endDate != null
                        ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                        : 'Pilih tanggal',
                    style: GoogleFonts.beVietnamPro(),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: startDate ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => endDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama rencana harus diisi')),
                  );
                  return;
                }
                if (startDate == null || endDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pilih tanggal mulai dan selesai'),
                    ),
                  );
                  return;
                }

                // Langsung pop context dialog sebelum memproses async method
                Navigator.pop(context);

                await _createPlan(
                  nameController.text,
                  descController.text,
                  startDate!,
                  endDate!,
                );
              },
              child: const Text('Buat'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPlan(
    String name,
    String description,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _apiService.createTripPlan(
        name: name,
        description: description,
        startDate: startDate,
        endDate: endDate,
      );

      if (mounted) {
        // ✅ PERBAIKAN: Menghapus response != null dan ganti ?[ menjadi [
        if ((response['success'] ?? false) == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rencana berhasil dibuat')),
          );
          _loadTripPlans();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Gagal membuat rencana'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    }
  }

  Future<void> _deletePlan(int planId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Rencana',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: const Text('Apakah Anda yakin ingin menghapus rencana ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await _apiService.deleteTripPlan(planId);
        if (mounted) {
          // ✅ PERBAIKAN: Menghapus response != null dan ganti ?[ menjadi [
          if ((response['success'] ?? false) == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Rencana berhasil dihapus')),
            );
            _loadTripPlans();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Gagal menghapus rencana'),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
        }
      }
    }
  }

  Future<void> _generateAIPlan() async {
    final budgetController = TextEditingController();
    String selectedInterest = 'budaya';
    int selectedDuration = 1;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Generate Rencana AI',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: budgetController,
                  decoration: const InputDecoration(
                    labelText: 'Budget (Rp)',
                    hintText: 'Contoh: 500000',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                // ✅ MEMAKAI initialValue (Bukan value)
                DropdownButtonFormField<int>(
                  initialValue: selectedDuration,
                  decoration: const InputDecoration(
                    labelText: 'Durasi Perjalanan',
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1 Hari')),
                    DropdownMenuItem(value: 2, child: Text('2 Hari')),
                    DropdownMenuItem(value: 3, child: Text('3 Hari')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedDuration = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                // ✅ MEMAKAI initialValue (Bukan value)
                DropdownButtonFormField<String>(
                  initialValue: selectedInterest,
                  decoration: const InputDecoration(labelText: 'Minat Utama'),
                  items: const [
                    DropdownMenuItem(value: 'budaya', child: Text('Budaya')),
                    DropdownMenuItem(value: 'kuliner', child: Text('Kuliner')),
                    DropdownMenuItem(value: 'alam', child: Text('Alam')),
                    DropdownMenuItem(value: 'sejarah', child: Text('Sejarah')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedInterest = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (budgetController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Budget harus diisi')),
                  );
                  return;
                }
                Navigator.pop(context);
                await _performGenerateAI(
                  budgetController.text,
                  selectedInterest,
                  selectedDuration,
                );
              },
              child: const Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performGenerateAI(
    String budget,
    String interest,
    int duration,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final now = DateTime.now();
      final createResponse = await _apiService.createTripPlan(
        name: 'Rencana AI - ${now.day}/${now.month}/${now.year}',
        description:
            'Rencana perjalanan yang dibuat oleh AI berdasarkan budget dan minat Anda',
        startDate: now,
        endDate: now.add(Duration(days: duration - 1)),
      );

      // ✅ PERBAIKAN: Menggunakan !mounted (State-level check) dan dibungkus kurung kurawal {}
      if (!mounted) {
        return;
      }

      if ((createResponse['success'] ?? false) == false) {
        Navigator.pop(context); // Tutup loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              createResponse['message'] ?? 'Gagal membuat rencana wadah AI',
            ),
          ),
        );
        return;
      }

      final planId = createResponse['data']['id'];
      final budgetValue = double.tryParse(budget) ?? 500000.0;
      final interestsList = [interest];

      final response = await _apiService.generateAIPlan(
        planId: planId,
        budget: budgetValue,
        interests: interestsList,
        duration: duration,
      );

      // ✅ PERBAIKAN: Menggunakan !mounted sebelum memanggil Navigator/ScaffoldMessenger setelah await kedua
      if (!mounted) {
        return;
      }

      Navigator.pop(context); // Tutup loading dialog

      if ((response['success'] ?? false) == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rencana AI berhasil dibuat')),
        );
        _loadTripPlans();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Gagal generate rencana'),
          ),
        );
      }
    } catch (e) {
      // ✅ PERBAIKAN: Menggunakan !mounted di dalam catch block sebelum memanggil context
      if (!mounted) {
        return;
      }

      Navigator.pop(context); // Tutup loading dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: const Color(0xFFF5FAF0).withValues(alpha: 0.9),
            elevation: 0,
            title: Text(
              'SoloExplore',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            leading: const Icon(Icons.menu, color: AppColors.primary),
            actions: const [NotificationBadge()],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Planner Perjalanan',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rancang Ceritamu di Solo',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih destinasi favorit dan biarkan kurasi kami menyusun rute terbaik.',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _showCreatePlanDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add),
                      label: Text(
                        'Buat Rencana Baru',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: _generateAIPlan,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(
                        'Generate Rencana AI',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.beVietnamPro(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadTripPlans,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          else if (_tripPlans.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.map_outlined,
                      size: 64,
                      color: AppColors.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada rencana perjalanan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Buat rencana pertamamu sekarang!',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final plan = _tripPlans[index];
                  return _TripPlanCard(
                    plan: plan,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.tripPlanDetail,
                        arguments: plan['id'],
                      ).then((_) => _loadTripPlans());
                    },
                    onDelete: () => _deletePlan(plan['id']),
                  );
                }, childCount: _tripPlans.length),
              ),
            ),
        ],
      ),
    );
  }
}

class _TripPlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TripPlanCard({
    required this.plan,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = plan['items_count'] ?? 0;
    final startDate = plan['start_date'] ?? '';
    final endDate = plan['end_date'] ?? '';
    final title = plan['title'] ?? plan['name'] ?? 'Rencana Perjalanan';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      onPressed: onDelete,
                    ),
                  ],
                ),
                if (plan['description'] != null &&
                    plan['description'].toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    plan['description'],
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$startDate - $endDate',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        '$itemCount destinasi',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
