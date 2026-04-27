import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/api_service.dart';

class TripPlanDetailScreen extends StatefulWidget {
  final int planId;

  const TripPlanDetailScreen({super.key, required this.planId});

  @override
  State<TripPlanDetailScreen> createState() => _TripPlanDetailScreenState();
}

class _TripPlanDetailScreenState extends State<TripPlanDetailScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _plan;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPlanDetail();
  }

  Future<void> _loadPlanDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getTripPlan(widget.planId);
      if (response['success']) {
        setState(() {
          _plan = response['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Gagal memuat detail rencana';
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

  Future<void> _showEditPlanDialog() async {
    if (_plan == null) return;

    final nameController = TextEditingController(text: _plan!['title'] ?? _plan!['name'] ?? '');
    final descController = TextEditingController(text: _plan!['description'] ?? '');
    DateTime? startDate = DateTime.tryParse(_plan!['start_date'] ?? '');
    DateTime? endDate = DateTime.tryParse(_plan!['end_date'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Edit Rencana',
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
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
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
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
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
                      initialDate: endDate ?? startDate ?? DateTime.now(),
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

                Navigator.pop(context);
                await _updatePlan(
                  nameController.text,
                  descController.text,
                  startDate,
                  endDate,
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updatePlan(String name, String description, DateTime? startDate, DateTime? endDate) async {
    try {
      final response = await _apiService.updateTripPlan(
        widget.planId,
        {
          'title': name,  // ✅ FIXED: Backend expects 'title' not 'name'
          'description': description,
          if (startDate != null) 'start_date': startDate.toIso8601String().split('T')[0],
          if (endDate != null) 'end_date': endDate.toIso8601String().split('T')[0],
        },
      );

      if (mounted) {
        if (response['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rencana berhasil diupdate')),
          );
          _loadPlanDetail();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Gagal mengupdate rencana')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  Future<void> _removeItem(int itemId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Item',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: const Text('Apakah Anda yakin ingin menghapus item ini?'),
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
        final success = await _apiService.removeItemFromPlan(widget.planId, itemId);
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item berhasil dihapus')),
            );
            _loadPlanDetail();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gagal menghapus item')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Rencana'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: GoogleFonts.beVietnamPro()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPlanDetail,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_plan == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Rencana'),
        ),
        body: const Center(
          child: Text('Rencana tidak ditemukan'),
        ),
      );
    }

    final items = (_plan!['items'] as List?) ?? [];
    final title = _plan!['title'] ?? _plan!['name'] ?? 'Detail Rencana';  // ✅ FIXED: Support both

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          title,  // ✅ FIXED: Use variable
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditPlanDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),  // ✅ ADDED: Refresh button
            onPressed: _loadPlanDetail,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_plan!['description'] != null && _plan!['description'].toString().isNotEmpty) ...[
                    Text(
                      _plan!['description'],
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        '${_plan!['start_date']} - ${_plan!['end_date']}',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 13,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        '${items.length} destinasi',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 13,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Items List
            Text(
              'Destinasi dalam Rencana',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    const Icon(Icons.map_outlined, size: 64, color: AppColors.outline),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada destinasi',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan destinasi ke rencana Anda',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...items.map((item) {
                final name = item['name'] ?? 'Unknown';  // ✅ FIXED: Get name from item
                final image = item['image'] ?? '';  // ✅ FIXED: Get image from item
                final location = item['location'] ?? '';  // ✅ FIXED: Get location from item
                final dayNumber = item['day_number'] ?? 0;
                final time = item['time'] ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                        child: Image.network(
                          image,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 96,
                            height: 96,
                            color: AppColors.surfaceContainer,
                            child: const Icon(Icons.image, color: AppColors.outline),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (dayNumber > 0) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    'Hari $dayNumber${time.isNotEmpty ? " • $time" : ""}',
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              Text(
                                name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 12, color: AppColors.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      location,
                                      style: GoogleFonts.beVietnamPro(
                                        fontSize: 11,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (item['notes'] != null && item['notes'].toString().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item['notes'],
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 11,
                                    color: AppColors.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () => _removeItem(item['id']),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
