import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterAdminKuliner extends StatelessWidget {
  const RegisterAdminKuliner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Text('Mitra SoloExplore', 
              style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green[800])),
            Text('Daftarkan bisnis kulinermu sekarang', 
              style: GoogleFonts.beVietnamPro(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 40),
            
            // FORM INPUT
            _buildField('Nama Lengkap Pemilik', Icons.person_outline),
            _buildField('Nama Usaha Kuliner', Icons.storefront_outlined),
            _buildField('Email Bisnis', Icons.email_outlined),
            _buildField('Password', Icons.lock_outline, isPassword: true),
            
            const SizedBox(height: 30),
            
            // TOMBOL DAFTAR
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Logika Register ke API Laravel
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text('Daftar Sebagai Mitra', 
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[300]!)),
        ),
      ),
    );
  }
}