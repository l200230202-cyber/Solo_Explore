import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../core/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final result = await ApiService().login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (result['success']) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Login gagal')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo Section
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 32,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.eco,
                            color: AppColors.primary,
                            size: 48,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SoloExplore',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Headline
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang Kembali',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mulailah petualangan kurasi warisan budaya Anda hari ini.',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Email Field
                    _buildModernTextField(
                      label: 'EMAIL',
                      controller: _emailController,
                      icon: Icons.mail,
                      hint: 'nama@email.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    // Password Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PASSWORD',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 2,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/forgot-password'),
                              child: Text(
                                'LUPA PASSWORD?',
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 14,
                            color: AppColors.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: GoogleFonts.beVietnamPro(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant.withOpacity(0.4),
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceContainerLow,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: AppColors.onSurfaceVariant,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: AppColors.onSurfaceVariant.withOpacity(0.6),
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          validator: (v) => v!.isEmpty ? 'Password harus diisi' : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          elevation: 0,
                          shadowColor: AppColors.primary.withOpacity(0.15),
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
                            : Text(
                                'Masuk',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // KELOMPOK REGISTER
                    Text(
                      'Belum punya akun?',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: Text(
                        'Daftar Sekarang',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                    ),
                    
                    // TOMBOL DAFTAR MITRA KULINER
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Punya usaha kuliner? ',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant.withOpacity(0.8),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRouter.registerAdminKuliner);
                          },
                          child: Text(
                            'Daftar Jadi Mitra',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.green[700],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 🟢 KELOMPOK LOGO SOSIAL & SEPARATOR TELAH DIHAPUS DARI AREA SINI

                    const SizedBox(height: 40),
                    // Decorative Images (Tetap dipertahankan paling bawah)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.rotate(
                          angle: 0.05,
                          child: Container(
                            width: 96,
                            height: 96,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Colors.grey,
                                  BlendMode.saturation,
                                ),
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuByPZk79AzbXNaeQG4lfv8cPXayc0sf4rPzT-bO4nmElhUO7mGBnrTbAJrSdPnCgdWO4ifOZQ3GeZRmrPOWb8FxuZFGFapjOgBBgrpF9b83ChX6CyGqiK8Ki0aUfNnb_dnPy45qpiz0_DjeEZ1F2mDWTNnyC4BDzatApQIsKtDvopuKuPb4mtNJy2BE0l2-KMECe0cd6rrv-Cdf4X9RVbD6BKCucjQ_3noX0jwpS-EkXuCH-lov6LF99gp9Zl6q2BH8zHU5bt6L21s',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    color: AppColors.surfaceContainer,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Transform.rotate(
                          angle: -0.1,
                          child: Container(
                            width: 96,
                            height: 96,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Colors.grey,
                                  BlendMode.saturation,
                                ),
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDmDgPuv1Cvw7Zt_l_AQNr12jZxt-RWjTF-hAXeWgizGVPux6vkgZt4mysEc-KPRD4qgJ2VnyHCrwlCTeT2ifDXhbFCusM58qYO36xzhz20Fi6LuuWbY7ja4bPUh6fr4vyXvXUGR5jP6RfZgP9pcMmbu4vgfG3KSZ1NkfK4e_NdubNVtW2clxJ81y4LkfTP299gjt1MTT-v4wuk4oImgJlF4I28chscqQ1XN4fs0OrkRBHh5u2uVEXXEnLJ5dn8hv1zDMKWm2atyJw',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    color: AppColors.surfaceContainer,
                                  ),
                                ),
                              ),
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
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.beVietnamPro(
            fontSize: 14,
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.beVietnamPro(
              fontSize: 14,
              color: AppColors.onSurfaceVariant.withOpacity(0.4),
            ),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (v) => v!.isEmpty ? 'Email harus diisi' : null,
        ),
      ],
    );
  }
}