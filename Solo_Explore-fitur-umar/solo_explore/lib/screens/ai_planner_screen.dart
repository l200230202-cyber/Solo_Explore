import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/api_service.dart';

class AIPlannerScreen extends StatefulWidget {
  final int tripPlanId;
  
  const AIPlannerScreen({super.key, required this.tripPlanId});

  @override
  State<AIPlannerScreen> createState() => _AIPlannerScreenState();
}

class _AIPlannerScreenState extends State<AIPlannerScreen> {
  final _budgetController = TextEditingController();
  final _durationController = TextEditingController(text: '3');
  final List<String> _selectedInterests = [];
  bool _isGenerating = false;

  final List<Map<String, dynamic>> _interestOptions = [
    {'slug': 'wisata-alam', 'name': 'Wisata Alam', 'icon': Icons.nature},
    {'slug': 'wisata-sejarah', 'name': 'Wisata Sejarah', 'icon': Icons.museum},
    {'slug': 'wisata-budaya', 'name': 'Wisata Budaya', 'icon': Icons.temple_buddhist},
    {'slug': 'kuliner', 'name': 'Kuliner', 'icon': Icons.restaurant},
  ];

  @override
  void dispose() {
    _budgetController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _generatePlan() async {
    if (_budgetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan budget terlebih dahulu')),
      );
      return;
    }

    if (_selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 minat')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final budget = double.parse(_budgetController.text.replaceAll('.', ''));
      final duration = int.parse(_durationController.text);

      final result = await ApiService().generateAIPlan(
        planId: widget.tripPlanId,
        budget: budget,
        interests: _selectedInterests,
        duration: duration,
      );

      if (mounted) {
        setState(() => _isGenerating = false);

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Rencana AI berhasil dibuat! ${result['data']['total_items']} items'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Gagal generate rencana')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'AI Planner',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Buat Rencana dengan AI',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI akan membuatkan rencana perjalanan berdasarkan budget dan minat Anda',
              style: GoogleFonts.beVietnamPro(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Budget Input
            Text(
              'Budget (Rp)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Contoh: 500000',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Duration Input
            Text(
              'Durasi (Hari)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Contoh: 3',
                suffixText: 'hari',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Interests Selection
            Text(
              'Minat',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih kategori yang Anda minati',
              style: GoogleFonts.beVietnamPro(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _interestOptions.map((interest) {
                final isSelected = _selectedInterests.contains(interest['slug']);
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        interest['icon'] as IconData,
                        size: 18,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(interest['name'] as String),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedInterests.add(interest['slug'] as String);
                      } else {
                        _selectedInterests.remove(interest['slug']);
                      }
                    });
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AI akan membuat itinerary dengan 4 aktivitas per hari (2 destinasi + 2 kuliner)',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 12,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generatePlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isGenerating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Generate Rencana AI',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
