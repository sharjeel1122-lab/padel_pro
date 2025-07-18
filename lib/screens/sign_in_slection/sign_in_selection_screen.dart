import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_pro/screens/vendor/vendor_auth/vendor_signup_screen.dart';

class SignInSelectionScreen extends StatelessWidget {
  const SignInSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome to Sports Click ",
                  style: GoogleFonts.poppins(
                    fontSize: isWide ? 32 : 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF072A40),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Select your role to continue",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                _buildRoleCard(
                  context,
                  icon: Icons.person_outline,
                  title: 'Sign in as User',
                  subtitle: 'Book courts, explore grounds, and more',
                  onTap: () => Get.toNamed('/login'), // User login route
                ),

                const SizedBox(height: 20),

                _buildRoleCard(
                  context,
                  icon: Icons.storefront_outlined,
                  title: 'Sign in as Vendor',
                  subtitle: 'Manage courts and products',
                  onTap: () => Get.toNamed('/vendorLogin'), // Vendor login route
                ),

                const SizedBox(height: 40),
                Text(
                  "Don’t have an account?",
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                TextButton(
                  onPressed: () => Get.to(()=> VendorSignUpScreen()),
                  child: Text(
                    "Create Vendor Account",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xFF072A40),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF072A40).withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 6,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF072A40).withOpacity(0.1),
              radius: 30,
              child: Icon(icon, size: 28, color: const Color(0xFF072A40)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: isWide ? 18 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}
