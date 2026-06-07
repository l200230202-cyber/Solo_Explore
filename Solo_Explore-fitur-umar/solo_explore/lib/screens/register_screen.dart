import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../models/category.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  List<Category> _categories = [];

  final List<int> _selectedCategoryIds = [];

  bool _isLoadingCategories = true;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final result = await ApiService().register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _phoneController.text.trim(),
        _selectedCategoryIds,
      );

      if (!mounted) return;

      if (result['success']) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registrasi gagal'),
            backgroundColor: Colors.red, // Biar warnanya merah menandakan error
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Detail Error: $e')));
      debugPrint('Error saat registrasi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCategories(); // Ambil data kategori dari API saat halaman dibuka
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ApiService().getCategories();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingCategories = false;
      });

      debugPrint('Gagal memuat kategori: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 448),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Batik pattern decorations
                  Positioned(
                    top: -80,
                    right: -80,
                    child: Container(
                      width: 256,
                      height: 256,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -64,
                    left: -64,
                    child: Container(
                      width: 192,
                      height: 192,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            AppColors.secondary.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.explore,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'SoloExplore',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Registrasi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mulailah petualangan kurasi Anda di Solo.',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Full Name
                          _buildModernTextField(
                            label: 'Full Name',
                            controller: _nameController,
                            icon: Icons.person,
                            hint: 'Nama Lengkap Anda',
                          ),
                          const SizedBox(height: 20),
                          // Email
                          _buildModernTextField(
                            label: 'Email',
                            controller: _emailController,
                            icon: Icons.mail,
                            hint: 'contoh@mail.com',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          // Phone
                          _buildModernTextField(
                            label: 'Nomor Telepon',
                            controller: _phoneController,
                            icon: Icons.phone,
                            hint: '08xxxxxxxxxx',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 20),
                          // Password
                          _buildModernTextField(
                            label: 'Password',
                            controller: _passwordController,
                            icon: Icons.lock,
                            hint: 'Min. 8 karakter',
                            isPassword: true,
                            obscureText: _obscurePassword,
                            onTogglePassword: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Confirm Password
                          _buildModernTextField(
                            label: 'Confirm Password',
                            controller: _confirmPasswordController,
                            icon: Icons.lock_reset,
                            hint: 'Ulangi password',
                            isPassword: true,
                            obscureText: _obscureConfirmPassword,
                            onTogglePassword: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                            validator: (v) {
                              if (v!.isEmpty) {
                                return 'Konfirmasi password harus diisi';
                              }
                              if (v != _passwordController.text) {
                                return 'Password tidak cocok';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Pilih Minat Wisata & Kuliner:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),

                          _isLoadingCategories
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                ) // Loading pas ambil data dari Laravel
                              : Wrap(
                                  spacing: 8.0,
                                  children: _categories.map((category) {
                                    final isSelected = _selectedCategoryIds
                                        .contains(category.id);
                                    return FilterChip(
                                      label: Text(category.name),
                                      selected: isSelected,
                                      onSelected: (bool selected) {
                                        setState(() {
                                          if (selected) {
                                            _selectedCategoryIds.add(
                                              category.id,
                                            );
                                          } else {
                                            _selectedCategoryIds.remove(
                                              category.id,
                                            );
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                          const SizedBox(height: 32),
                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                elevation: 0,
                                shadowColor: AppColors.primary.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Register Now',
                                          style: GoogleFonts.beVietnamPro(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Terms
                          Text(
                            'Dengan mendaftar, Anda menyetujui Terms & Conditions serta Privacy Policy kami.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Divider
                          Container(
                            height: 1,
                            color: AppColors.surfaceContainer,
                          ),
                          const SizedBox(height: 24),
                          // Login Link
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'Sudah punya akun?',
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    'Masuk ke Akun Anda',
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.beVietnamPro(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword ? obscureText : false,
          style: GoogleFonts.beVietnamPro(
            fontSize: 14,
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.beVietnamPro(
              fontSize: 14,
              color: AppColors.outline.withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: onTogglePassword,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (v) {
            if (v!.isEmpty) {
              return '$label harus diisi';
            }

            if (isPassword && v.length < 8) {
              return 'Password minimal 8 karakter';
            }

            return null;
          },
        ),
      ],
    );
  }
}
