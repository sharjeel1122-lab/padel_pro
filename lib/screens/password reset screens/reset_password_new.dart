// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:padel_pro/screens/password%20reset%20screens/reset_controller.dart';
//
// class ResetPasswordNewScreen extends StatelessWidget {
//   ResetPasswordNewScreen({super.key});
//   final _formKey = GlobalKey<FormState>();
//   final c = Get.find<ResetController>();
//
//   final _passwordController = TextEditingController();
//   final _confirmController = TextEditingController();
//   final _mpinController = TextEditingController();
//
//   final _obscurePwd = true.obs;
//   final _obscureConfirm = true.obs;
//
//   @override
//   Widget build(BuildContext context) {
//     final token = (Get.arguments?['token'] ?? '').toString();
//     if (token.isNotEmpty) c.token.value = token;
//
//     return Scaffold(
//       appBar: AppBar(iconTheme: const IconThemeData(color: Colors.black)),
//       backgroundColor: Colors.grey[50],
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 20),
//                 Text('New Password',
//                     style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600, color: const Color(0xFF072A40))),
//                 const SizedBox(height: 8),
//                 Text('Create a new secure password (or set MPIN)',
//                     style: GoogleFonts.poppins(color: Colors.grey[600])),
//                 const SizedBox(height: 40),
//                 Image.asset('assets/logo.png', height: 100),
//                 const SizedBox(height: 40),
//
//                 // Password
//                 Obx(() => TextFormField(
//                   controller: _passwordController,
//                   obscureText: _obscurePwd.value,
//                   decoration: InputDecoration(
//                     labelText: 'New Password',
//                     prefixIcon: const Icon(Icons.lock_outline),
//                     suffixIcon: IconButton(
//                       icon: Icon(_obscurePwd.value ? Icons.visibility_off : Icons.visibility),
//                       onPressed: () => _obscurePwd.value = !_obscurePwd.value,
//                     ),
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   validator: (v) {
//                     if ((v ?? '').isEmpty && _mpinController.text.isEmpty) {
//                       return 'Enter password or MPIN';
//                     }
//                     if ((v ?? '').isNotEmpty) {
//                       return c.validatePassword(v!);
//                     }
//                     return null;
//                   },
//                 )),
//                 const SizedBox(height: 20),
//
//                 // Confirm
//                 Obx(() => TextFormField(
//                   controller: _confirmController,
//                   obscureText: _obscureConfirm.value,
//                   decoration: InputDecoration(
//                     labelText: 'Confirm Password',
//                     prefixIcon: const Icon(Icons.lock_outline),
//                     suffixIcon: IconButton(
//                       icon: Icon(_obscureConfirm.value ? Icons.visibility_off : Icons.visibility),
//                       onPressed: () => _obscureConfirm.value = !_obscureConfirm.value,
//                     ),
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   validator: (v) {
//                     if (_passwordController.text.isEmpty) return null; // no password => no confirm needed
//                     if (v != _passwordController.text) return 'Passwords do not match';
//                     return null;
//                   },
//                 )),
//                 const SizedBox(height: 20),
//
//                 // MPIN (optional)
//                 TextFormField(
//                   controller: _mpinController,
//                   keyboardType: TextInputType.number,
//                   maxLength: 4,
//                   decoration: InputDecoration(
//                     labelText: 'MPIN (optional, 4 digits)',
//                     prefixIcon: const Icon(Icons.pin),
//                     counterText: '',
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   validator: (v) => c.validateMpin(v ?? ''),
//                 ),
//                 const SizedBox(height: 40),
//
//                 Obx(() => SizedBox(
//                   width: double.infinity, height: 50,
//                   child: ElevatedButton(
//                     onPressed: c.loading.value ? null : () async {
//                       if (_formKey.currentState!.validate()) {
//                         c.password.value = _passwordController.text.trim();
//                         c.confirm.value = _confirmController.text.trim();
//                         c.mpin.value = _mpinController.text.trim();
//                         await c.doReset();
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF072A40),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     ),
//                     child: c.loading.value
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : Text('Update', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
//                   ),
//                 )),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
