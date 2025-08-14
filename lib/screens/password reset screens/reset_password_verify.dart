// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'reset_password_new.dart';
//
// class ResetPasswordVerifyScreen extends StatefulWidget {
//   const ResetPasswordVerifyScreen({super.key});
//
//   @override
//   _ResetPasswordVerifyScreenState createState() => _ResetPasswordVerifyScreenState();
// }
//
// class _ResetPasswordVerifyScreenState extends State<ResetPasswordVerifyScreen> {
//   final List<TextEditingController> _codeControllers =
//   List.generate(6, (index) => TextEditingController());
//   final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
//   bool _isLoading = false;
//
//   void _verifyCode() {
//     setState(() => _isLoading = true);
//     Future.delayed(Duration(seconds: 1)).then((_) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => ResetPasswordNewScreen()),
//       );
//     });
//   }
//
//   void _onCodeChanged(String value, int index) {
//     if (value.length == 1 && index < 5) {
//       _focusNodes[index + 1].requestFocus();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: IconThemeData(
//           color: Colors.black
//         ),
//         leading: BackButton(
//
//         ),
//       ),
//       backgroundColor: Colors.grey[50],
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // IconButton(
//               //   icon: Icon(Icons.arrow_back, color: Color(0xFF072A40)),
//               //   onPressed: () => Navigator.pop(context),
//               // ),
//               SizedBox(height: 20),
//               Text(
//                 'Verification',
//                 style: GoogleFonts.poppins(
//                   fontSize: 28,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF072A40),
//                 ),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 'Enter the 6-digit code sent to your email',
//                 style: GoogleFonts.poppins(color: Colors.grey[600]),
//               ),
//               SizedBox(height: 40),
//               Image.asset('assets/logo.png', height: 100),
//               SizedBox(height: 40),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: List.generate(6, (index) => SizedBox(
//                   width: 45,
//                   child: TextField(
//                     controller: _codeControllers[index],
//                     focusNode: _focusNodes[index],
//                     textAlign: TextAlign.center,
//                     keyboardType: TextInputType.number,
//                     maxLength: 1,
//                     decoration: InputDecoration(
//                       counterText: '',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     onChanged: (value) => _onCodeChanged(value, index),
//                   ),
//                 )),
//               ),
//               SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _verifyCode,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFF072A40),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? CircularProgressIndicator(color: Colors.white)
//                       : Text('Verify Code', style: GoogleFonts.poppins(fontSize: 16,color: Colors.white)),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Center(
//                 child: TextButton(
//                   onPressed: () {
//                     // Resend code logic
//                   },
//                   child: Text(
//                     "Didn't receive code? Resend",
//                     style: GoogleFonts.poppins(
//                       color: Color(0xFF072A40),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }