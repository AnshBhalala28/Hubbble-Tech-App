// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sizer/sizer.dart';
// import 'package:waveee/comman/colors.dart';
// import 'package:waveee/comman/const.dart';
// import 'package:waveee/comman/input_decoration.dart';
//
//
//
// class SignInScreen extends StatefulWidget {
//   const SignInScreen({super.key});
//
//   @override
//   State<SignInScreen> createState() => _SignInScreenState();
// }
//
// class _SignInScreenState extends State<SignInScreen> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool _obscurePassword = true;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   child: Image.asset(
//                     "assets/images/image 2.png",
//                     height: 28.h,
//                     width: 65.w,
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 4.h),
//               Text(
//                 "Create Your Account",
//                 style: TextStyle(
//                   fontSize: 20.sp,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.maincolor,
//                   fontFamily: AppConstants.manrope,
//                 ),
//               ),
//               SizedBox(height: 3.h),
//               Container(
//                 width: MediaQuery.of(context).size.width,
//                 child: TextFormField(
//                   cursorColor: AppColors.black,
//                   controller: nameController,
//                   keyboardType: TextInputType.name,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Please enter your name";
//                     }
//                     // Check if name contains only letters and spaces
//                     bool isValidName = RegExp(r"^[a-zA-Z\s]+$").hasMatch(value);
//                     if (!isValidName) {
//                       return "Please enter a valid name";
//                     }
//                     return null;
//                   },
//                   decoration: inputDecoration(
//                     hintText: 'Enter your Name',
//                     searchIcon: Icon(
//                       Icons.person,
//                       size: 20.sp,
//                       color: AppColors.black,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 2.h),
//               Container(
//                 width: MediaQuery.of(context).size.width,
//                 child: TextFormField(
//                   cursorColor: AppColors.black,
//                   controller: emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Please enter your email";
//                     }
//
//                     // Check if it's a valid email
//                     bool isEmail = RegExp(
//                       r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$",
//                     ).hasMatch(value);
//                     if (!isEmail) {
//                       return "Please enter a valid email";
//                     }
//                     return null;
//                   },
//                   decoration: inputDecoration(
//                     hintText: 'Enter your Email',
//                     searchIcon: Icon(
//                       Icons.contact_mail,
//                       size: 20.sp,
//                       color: AppColors.black,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 2.h),
//               Container(
//                 width: MediaQuery.of(context).size.width,
//                 child: TextFormField(
//                   cursorColor: AppColors.maincolor,
//                   controller: passwordController,
//                   keyboardType: TextInputType.visiblePassword,
//                   validator: (value) {
//                     if (value!.isEmpty) {
//                       return "Please enter your password";
//                     }
//                     return null;
//                   },
//                   obscureText: _obscurePassword,
//                   decoration: inputDecoration(
//                     hintText: 'Enter your Password',
//                     searchIcon: Icon(
//                       Icons.key,
//                       size: 20.sp,
//                       color: AppColors.black,
//                     ),
//                     ico: IconButton(
//                       onPressed: () {
//                         setState(() {
//                           _obscurePassword = !_obscurePassword;
//
//                         });
//                       },
//                       icon: _obscurePassword
//                           ? Icon(
//                               Icons.visibility,
//                               size: 20.sp,
//                               color: AppColors.black,
//                             )
//                           : Icon(
//                               Icons.visibility_off,
//                               size: 20.sp,
//                               color: AppColors.black,
//                             ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 3.h),
//               Container(
//                 width: double.infinity,
//                 height: 7.h,
//                 decoration: BoxDecoration(
//                   color: Colors.blue,
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: TextButton(
//                   onPressed: () {
//                     // Get.to(HomeScreen(selected: 1));
//                   },
//                   child: Text(
//                     "Sign Up",
//                     style: TextStyle(
//                       fontSize: 18.sp,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: AppConstants.manrope,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 2.h),
//               Center(
//                 child: RichText(
//                   text: TextSpan(
//                     text: "Already have an account? ",
//                     style: TextStyle(
//                       fontSize: 17.sp,
//                       color: Colors.black87,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: AppConstants.manrope,
//                     ),
//                     children: [
//                       TextSpan(
//                         text: "Login",
//                         style: TextStyle(
//                           color: Colors.blue,
//                           fontWeight: FontWeight.bold,
//                           fontFamily: AppConstants.manrope,
//                         ),
//                         recognizer: TapGestureRecognizer()
//                           ..onTap = () {
//                             Get.back();
//                           },
//                       ),
//                     ],
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
