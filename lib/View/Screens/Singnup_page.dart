// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../Controller/Signup_controller.dart';
// import '../../utils/colers.dart';
// import 'Login_page.dart';
//
// class SingnupPage extends StatefulWidget {
//   const SingnupPage({super.key});
//
//   @override
//   State<SingnupPage> createState() => _SingnupPageState();
// }
//
// class _SingnupPageState extends State<SingnupPage> with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//
//   bool loading = false;
//   bool _isPasswordVisible = false;
//   bool _isConfirmPasswordVisible = false;
//
//   // Move controller initialization outside build method
//   late SignupController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = SignupController(); // Initialize once
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.easeIn,
//       ),
//     );
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0),
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 40),
//
//                   // Header with fixed logo
//                   Center(
//                     child: Column(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(15),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: primary_color.withOpacity(0.2),
//                                 blurRadius: 20,
//                                 spreadRadius: 5,
//                               ),
//                             ],
//                           ),
//                           child: ClipOval(
//                             child: Image.asset(
//                               "assets/images/Employee_logo.png",
//                               width: 120,
//                               height: 130,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 print('Error loading logo: $error');
//                                 return Container(
//                                   width: 120,
//                                   height: 120,
//                                   decoration: BoxDecoration(
//                                     color: primary_color.withOpacity(0.1),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: Icon(
//                                     Icons.person_add_alt_1,
//                                     size: 60,
//                                     color: primary_color,
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         Text(
//                           'Create Account',
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color: primary_color,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Sign up to get started',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 40),
//
//                   // Form
//                   Form(
//                     key: _formKey,
//                     child: Column(
//                       children: [
//                         // Full Name
//                         TextFormField(
//                           controller: _controller.name,
//                           decoration: InputDecoration(
//                             labelText: 'Full Name',
//                             hintText: 'Enter your full name',
//                             prefixIcon: const Icon(Icons.person_outline),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(color: Colors.grey.shade300),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(
//                                 color: primary_color,
//                                 width: 2,
//                               ),
//                             ),
//                             filled: true,
//                             fillColor: Colors.grey.shade50,
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your name';
//                             }
//                             if (value.length < 3) {
//                               return 'Name must be at least 3 characters';
//                             }
//                             return null;
//                           },
//                         ),
//
//                         const SizedBox(height: 16),
//
//                         // Email
//                         TextFormField(
//                           controller: _controller.email,
//                           keyboardType: TextInputType.emailAddress,
//                           decoration: InputDecoration(
//                             labelText: 'Email',
//                             hintText: 'Enter your email',
//                             prefixIcon: const Icon(Icons.email_outlined),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(color: Colors.grey.shade300),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(
//                                 color: primary_color,
//                                 width: 2,
//                               ),
//                             ),
//                             filled: true,
//                             fillColor: Colors.grey.shade50,
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your email';
//                             }
//                             if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//                               return 'Please enter a valid email';
//                             }
//                             return null;
//                           },
//                         ),
//
//                         const SizedBox(height: 16),
//
//                         // Phone Number
//                         TextFormField(
//                           controller: _controller.phoneNumber,
//                           keyboardType: TextInputType.phone,
//                           decoration: InputDecoration(
//                             labelText: 'Phone Number',
//                             hintText: 'Enter your phone number',
//                             prefixIcon: const Icon(Icons.phone_outlined),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(color: Colors.grey.shade300),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(
//                                 color: primary_color,
//                                 width: 2,
//                               ),
//                             ),
//                             filled: true,
//                             fillColor: Colors.grey.shade50,
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your phone number';
//                             }
//                             if (value.length < 10) {
//                               return 'Phone number must be at least 10 digits';
//                             }
//                             return null;
//                           },
//                         ),
//
//                         const SizedBox(height: 16),
//
//                         // Password
//                         TextFormField(
//                           controller: _controller.password,
//                           obscureText: !_isPasswordVisible,
//                           decoration: InputDecoration(
//                             labelText: 'Password',
//                             hintText: 'Create a password',
//                             prefixIcon: const Icon(Icons.lock_outline),
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                                 color: primary_color,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   _isPasswordVisible = !_isPasswordVisible;
//                                   print('Password visibility: $_isPasswordVisible'); // Debug print
//                                 });
//                               },
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(color: Colors.grey.shade300),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(
//                                 color: primary_color,
//                                 width: 2,
//                               ),
//                             ),
//                             filled: true,
//                             fillColor: Colors.grey.shade50,
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter a password';
//                             }
//                             if (value.length < 6) {
//                               return 'Password must be at least 6 characters';
//                             }
//                             return null;
//                           },
//                         ),
//
//                         const SizedBox(height: 16),
//
//                         // Confirm Password
//                         TextFormField(
//                           controller: _controller.cp,
//                           obscureText: !_isConfirmPasswordVisible,
//                           decoration: InputDecoration(
//                             labelText: 'Confirm Password',
//                             hintText: 'Re-enter your password',
//                             prefixIcon: const Icon(Icons.lock_outline),
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                                 color: primary_color,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
//                                   print('Confirm password visibility: $_isConfirmPasswordVisible'); // Debug print
//                                 });
//                               },
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(color: Colors.grey.shade300),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(
//                                 color: primary_color,
//                                 width: 2,
//                               ),
//                             ),
//                             filled: true,
//                             fillColor: Colors.grey.shade50,
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please confirm your password';
//                             }
//                             if (value != _controller.password.text) {
//                               return 'Passwords do not match';
//                             }
//                             return null;
//                           },
//                         ),
//
//                         const SizedBox(height: 24),
//
//                         // Sign Up Button
//                         Container(
//                           width: double.infinity,
//                           height: 55,
//                           decoration: BoxDecoration(
//                             color: primary_color,
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: primary_color.withOpacity(0.3),
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 5),
//                               ),
//                             ],
//                           ),
//                           child: ElevatedButton(
//                             onPressed: () {
//                               if (_formKey.currentState!.validate()) {
//                                 // _controller.sign_up(context);
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.transparent,
//                               shadowColor: Colors.transparent,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             child: const Text(
//                               'Sign Up',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//
//                         const SizedBox(height: 20),
//
//                         // Sign In Link
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'Already have an account? ',
//                               style: TextStyle(
//                                 color: Colors.grey.shade600,
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 Get.to(() => LoginPage());
//                               },
//                               child: Text(
//                                 'Sign In',
//                                 style: TextStyle(
//                                   color: primary_color,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//
//                         const SizedBox(height: 20),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }