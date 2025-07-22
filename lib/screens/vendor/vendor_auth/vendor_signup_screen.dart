import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/auth_controller.dart';


class VendorSignUpScreen extends StatefulWidget {
  const VendorSignUpScreen({super.key});

  @override
  State<VendorSignUpScreen> createState() => _VendorSignUpScreenState();
}

class _VendorSignUpScreenState extends State<VendorSignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mpinController = TextEditingController();
  final _cnicController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  final authController = Get.put(AuthController());

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mpinController.dispose();
    _cnicController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Vendor Sign Up',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),

                _buildField(
                  controller: _firstNameController,
                  label: 'First Name',
                  icon: Icons.person_outline,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter first name'
                      : null,
                ),

                _buildField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  icon: Icons.person_outline,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter last name'
                      : null,
                ),

                _buildField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter email';
                    if (!GetUtils.isEmail(value.trim())) return 'Enter valid email';
                    return null;
                  },
                ),

                GetBuilder<AuthController>(
                  builder: (_) {
                    return TextFormField(
                      controller: _passwordController,
                      obscureText: authController.obscureText,
                      cursorColor: Colors.black,
                      style: GoogleFonts.poppins(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            authController.obscureText
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.black,
                          ),
                          onPressed: authController.toggleVisibility,
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey, width: 2),
                        ),
                      ),
                      validator: (value) =>
                      value == null || value.length < 6 ? 'Min 6 characters' : null,
                    );
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _mpinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  cursorColor: Colors.black,
                  style: GoogleFonts.poppins(fontSize: 16),
                  decoration: InputDecoration(
                    labelText: '4-digit M-PIN',
                    prefixIcon: const Icon(Icons.pin),
                    counterText: "",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Enter M-PIN';
                    if (value.trim().length != 4 || !RegExp(r'^\d+$').hasMatch(value)) {
                      return 'M-PIN must be 4 digits';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                _buildField(
                  controller: _cnicController,
                  label: 'CNIC',
                  icon: Icons.credit_card,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Enter CNIC';
                    if (value.trim().length != 13) return 'CNIC must be 13 digits';
                    return null;
                  },
                ),

                _buildField(
                  controller: _cityController,
                  label: 'Location',
                  icon: Icons.location_city,
                  validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Enter Location' : null,
                ),

                _buildField(
                  controller: _addressController,
                  label: 'Address',
                  icon: Icons.home,
                  validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Enter address' : null,
                ),

                const SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: () {
                    // if (_formKey.currentState!.validate()) {
                    //   authController.signupVendor(
                    //     firstName: _firstNameController.text.trim(),
                    //     lastName: _lastNameController.text.trim(),
                    //     email: _emailController.text.trim(),
                    //     password: _passwordController.text.trim(),
                    //     mpin: _mpinController.text.trim(),
                    //     cnic: _cnicController.text.trim(),
                    //     city: _cityController.text.trim(),
                    //     address: _addressController.text.trim(),
                    //   );
                    // }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF072A40),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.store_mall_directory, color: Colors.white),
                  label: Text(
                    'REGISTER AS VENDOR',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),


                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment. center,
                  children: [
                    Text("Already registered? ",
                        style: GoogleFonts.poppins(fontSize: 16)),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Text(
                        'Sign in',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFF072A40),
                          fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        cursorColor: Colors.black,
        style: GoogleFonts.poppins(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 2),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
