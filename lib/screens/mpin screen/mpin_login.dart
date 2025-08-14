// lib/screens/auth/mpin_login_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:padel_pro/controllers/auth%20controllers/m_pin_login_controller.dart';

class MPINLoginScreen extends StatefulWidget {
  const MPINLoginScreen({super.key});

  @override
  _MPINLoginScreenState createState() => _MPINLoginScreenState();
}

class _MPINLoginScreenState extends State<MPINLoginScreen> {
  final MPINLoginController mpinController = Get.put(MPINLoginController());

  String enteredPIN = '';
  final int pinLength = 4;
  bool _submittedThisRound = false;

  void _onNumberPressed(String number) async {
    if (mpinController.isLoading.value) return;
    if (enteredPIN.length >= pinLength) return;

    setState(() => enteredPIN += number);

    if (enteredPIN.length == pinLength && !_submittedThisRound) {
      _submittedThisRound = true;
      try {
        await mpinController.loginWithMPIN(enteredPIN);
      } catch (_) {
        setState(() => enteredPIN = '');
      } finally {
        _submittedThisRound = false;
      }
    }
  }

  void _onBackspacePressed() {
    if (mpinController.isLoading.value) return;
    if (enteredPIN.isNotEmpty) {
      setState(() {
        enteredPIN = enteredPIN.substring(0, enteredPIN.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[50],
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 20),
                  child: Column(
                    children: [
                      Image.asset('assets/logo.png', height: 80),
                      const SizedBox(height: 20),
                      Text(
                        'Enter Your MPIN',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF072A40),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your 4 digit Pin',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // PIN dots
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 30),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pinLength, (index) {
                      final filled = index < enteredPIN.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: filled
                              ? const Color(0xFF072A40)
                              : Colors.grey[300],
                          border: Border.all(
                            color: filled
                                ? Colors.transparent
                                : const Color(0xFF072A40),
                            width: 1.5,
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Keypad
                Expanded(
                  child: AbsorbPointer(
                    absorbing: mpinController.isLoading.value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: GridView.count(
                        crossAxisCount: 3,
                        childAspectRatio: 1.3,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (int i = 1; i <= 9; i++)
                            _buildNumberButton(i.toString()),
                          const SizedBox.shrink(),
                          _buildNumberButton('0'),
                          _buildBackspaceButton(),
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: TextButton(
                        onPressed: mpinController.isLoading.value
                            ? null
                            : () => Navigator.pushReplacementNamed(
                            context, '/forget-mpin'),
                        child: Text(
                          'Forgot MPIN?',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF072A40),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: TextButton(
                        onPressed: mpinController.isLoading.value
                            ? null
                            : () => Get.toNamed('/login'),
                        child: Text(
                          'Login with Email',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF072A40),
                            fontWeight: FontWeight.w500,
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

        // Loading overlay
        if (mpinController.isLoading.value)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.25),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Color(0xFF072A40)),
                ),
              ),
            ),
          ),
      ],
    ));
  }

  Widget _buildNumberButton(String number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () => _onNumberPressed(number),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 1),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF072A40),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: _onBackspacePressed,
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 1),
            ],
          ),
          child: const Center(
            child: Icon(Icons.backspace, size: 24, color: Color(0xFF072A40)),
          ),
        ),
      ),
    );
  }
}
