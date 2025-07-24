import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MPINLoginScreen extends StatefulWidget {
  const MPINLoginScreen({super.key});

  @override
  _MPINLoginScreenState createState() => _MPINLoginScreenState();
}

class _MPINLoginScreenState extends State<MPINLoginScreen> {
  String enteredPIN = '';
  final int pinLength = 4;

  void _onNumberPressed(String number) {
    if (enteredPIN.length < pinLength) {
      setState(() {
        enteredPIN += number;
      });

      if (enteredPIN.length == pinLength) {
        // Verify PIN logic here
        _verifyPIN();
      }
    }
  }

  void _onBackspacePressed() {
    if (enteredPIN.isNotEmpty) {
      setState(() {
        enteredPIN = enteredPIN.substring(0, enteredPIN.length - 1);
      });
    }
  }

  Future<void> _verifyPIN() async {
    // Replace with your actual PIN verification logic
    await Future.delayed(Duration(milliseconds: 300));

    if (enteredPIN == "1234") {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        enteredPIN = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid PIN. Please try again.'),
          backgroundColor: Color(0xFF072A40),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo.png', // Replace with your logo
                    height: 80,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Enter Your MPIN',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF072A40),
                    ),
                  ),
                  SizedBox(height: 8),
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

            // PIN Dots
            Container(
              margin: EdgeInsets.symmetric(vertical: 30),
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pinLength, (index) {
                  return Container(
                    width: 24,
                    height: 24,
                    margin: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < enteredPIN.length
                          ? Color(0xFF072A40)
                          : Colors.grey[300],
                      border: Border.all(
                        color: index < enteredPIN.length
                            ? Colors.transparent
                            : Color(0xFF072A40),
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Keypad
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 1.3,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    for (int i = 1; i <= 9; i++)
                      _buildNumberButton(i.toString()),
                    Container(), // Empty space
                    _buildNumberButton('0'),
                    _buildBackspaceButton(),
                  ],
                ),
              ),
            ),

            // Forgot PIN option
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/forget-mpin');
                },
                child: Text(
                  'Forgot MPIN?',
                  style: GoogleFonts.poppins(
                    color: Color(0xFF072A40),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Color(0xFF072A40),
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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.backspace,
              size: 24,
              color: Color(0xFF072A40),
            ),
          ),
        ),
      ),
    );
  }
}