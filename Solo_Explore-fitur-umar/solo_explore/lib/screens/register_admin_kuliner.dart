import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/app_router.dart';
import '../core/theme.dart';

class RegisterAdminKuliner extends StatefulWidget {
  const RegisterAdminKuliner({super.key});

  @override
  State<RegisterAdminKuliner> createState() => _RegisterAdminKulinerState();
}

class _RegisterAdminKulinerState extends State<RegisterAdminKuliner> {
  final _nameController = TextEditingController();
  final _usahaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // State untuk visibilitas password
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _usahaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerMitra() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('http://localhost:8000/api/auth/register-mitra'); 
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'nama_usaha': _usahaController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'password_confirmation': _confirmPasswordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || (data is Map && data['success'] == true)) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text(
                'Registrasi Berhasil!',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
              ),
              content: const Text(
                'Akun Mitra Kuliner Anda berhasil dibuat. Silakan buka dashboard web SoloExplore untuk mulai mengelola bisnis kuliner Anda.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, AppRouter.login);
                  },
                  child: const Text('OK'),
                )
              ],
            ),
          );
        }
      } else {
        String errorMsg = 'Gagal mendaftarkan mitra.';
        if (data is Map && data['message'] != null) {
          errorMsg = data['message'];
        } else if (data is Map && data['errors'] != null) {
          errorMsg = data['errors'].toString();
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal Terhubung: $e'), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Mitra SoloExplore', 
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.green[800],
                      ),
                    ),
                    Text(
                      'Daftarkan bisnis kulinermu sekarang', 
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 14, 
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    _buildField(
                      label: 'Nama Lengkap Pemilik', 
                      icon: Icons.person_outline, 
                      controller: _nameController,
                      validator: (v) => v!.isEmpty ? 'Nama lengkap wajib diisi' : null,
                    ),
                    _buildField(
                      label: 'Nama Usaha Kuliner', 
                      icon: Icons.storefront_outlined, 
                      controller: _usahaController,
                      validator: (v) => v!.isEmpty ? 'Nama usaha wajib diisi' : null,
                    ),
                    _buildField(
                      label: 'Email Bisnis', 
                      icon: Icons.email_outlined, 
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty ? 'Email bisnis wajib diisi' : null,
                    ),
                    _buildField(
                      label: 'Password', 
                      icon: Icons.lock_outline, 
                      controller: _passwordController,
                      isPassword: _obscurePassword,
                      onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                      validator: (v) => v!.length < 8 ? 'Password minimal 8 karakter' : null,
                    ),
                    _buildField(
                      label: 'Konfirmasi Password', 
                      icon: Icons.lock_outline, 
                      controller: _confirmPasswordController,
                      isPassword: _obscureConfirmPassword,
                      onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      validator: (v) => v != _passwordController.text ? 'Password tidak cocok' : null,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registerMitra,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          disabledBackgroundColor: Colors.green[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading 
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Daftar Sebagai Mitra', 
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.white,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: GoogleFonts.beVietnamPro(fontSize: 14, color: Colors.grey[600]),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, AppRouter.login),
                          child: Text(
                            'Masuk',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
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

  Widget _buildField({
    required String label, 
    required IconData icon, 
    required TextEditingController controller,
    bool isPassword = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.beVietnamPro(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.beVietnamPro(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.green[700]),
          suffixIcon: onToggleVisibility != null
              ? IconButton(
                  icon: Icon(isPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15), 
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15), 
            borderSide: BorderSide(color: Colors.green[700]!, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15), 
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15), 
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}