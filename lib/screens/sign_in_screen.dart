// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_task_syscraft/config/theme/app_colors.dart';
import 'package:demo_task_syscraft/config/theme/app_text_style.dart';
import 'package:demo_task_syscraft/constants/app_const_text.dart';
import 'package:demo_task_syscraft/constants/app_sizes.dart';
import 'package:demo_task_syscraft/constants/assets_path.dart';
import 'package:demo_task_syscraft/screens/dashboard_screen.dart';
import 'package:demo_task_syscraft/screens/sign_up_screen.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool showPassword = true;
  bool showOtp = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  EmailOTP myauth = EmailOTP();

  Future<void> sendOtp(String email) async {
    myauth.setConfig(
        appName: AppConstString.emailOtp,
        userEmail: emailController.text,
        otpLength: 4,
        otpType: OTPType.digitsOnly);
    if (await myauth.sendOTP() == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(AppConstString.otpSend),
      ));
      showOtp = true;
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(AppConstString.oopsOtpFailed),
      ));
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        String email = '';

        var snapshot = await _firestore
            .collection('client')
            .where('email', isEqualTo: emailController.text)
            .get();

        if (snapshot.docs.isEmpty) {
          _showMessage(AppConstString.noUserFoundWithMobile);
          return;
        }
        email = snapshot.docs.first.data()['email'];

        await sendOtp(email);
      } catch (e) {
        _showMessage('${AppConstString.loginFailed} ${e.toString()}');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> verifyOtp() async {
    if (await myauth.verifyOTP(otp: otpController.text) == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(AppConstString.otpVerified),
      ));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(AppConstString.invalidOtp),
      ));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.only(
          left: AppSizes.size12,
          right: AppSizes.size12,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imageWidget(),
                const SizedBox(
                  height: AppSizes.size30,
                ),
                Text(
                  AppConstString.signIn,
                  style: AppTextStyle.blueColor30Bold,
                ),
                const SizedBox(
                  height: AppSizes.size20,
                ),
                emailTxtWidget(),
                const SizedBox(
                  height: AppSizes.size16,
                ),
                passwordTxtWidget(),
                const SizedBox(
                  height: AppSizes.size16,
                ),
                showOtp ? otpTxtWidget() : const SizedBox(),
                SizedBox(
                  height: showOtp ? AppSizes.size16 : 0,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    AppConstString.forgotPassword,
                    style: AppTextStyle.blueColor14W500,
                  ),
                ),
                const SizedBox(
                  height: AppSizes.size16,
                ),
                showOtp ? otpVerifeyBtnWidget() : signInBtnWidget(),
                const SizedBox(
                  height: AppSizes.size36,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    AppConstString.signInWith,
                    style: AppTextStyle.blueColor14W500,
                  ),
                ),
                const SizedBox(
                  height: AppSizes.size16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildSocialIcon(AssetPath.google),
                    const SizedBox(width: AppSizes.size10),
                    buildSocialIcon(AssetPath.facebook),
                    const SizedBox(width: AppSizes.size10),
                    buildSocialIcon(AssetPath.linkedin),
                    const SizedBox(width: AppSizes.size10),
                    buildSocialIcon(AssetPath.xtrems),
                  ],
                ),
                const SizedBox(
                  height: AppSizes.size16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppConstString.dontHaveAccount,
                      style: AppTextStyle.blueColor14W500,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        AppConstString.signUp,
                        style: AppTextStyle.blueColor14W500
                            .copyWith(color: Colors.purple),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget imageWidget() {
    return Center(
      child: Image.asset(
        AssetPath.logo,
        height: 100,
      ),
    );
  }

  Widget emailTxtWidget() {
    return TextFormField(
      controller: emailController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              AppSizes.size12,
            ),
          ),
        ),
        prefixIcon: Icon(Icons.email_outlined),
        hintText: AppConstString.enterEmailOrmobile,
      ),
      onChanged: (value) {
        setState(() {
          showOtp = false;
        });
      },
      validator: (value) {
        const String pattern =
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
        final RegExp regExp = RegExp(pattern);
        if (value == null || value.isEmpty) {
          return AppConstString.requiredEmail;
        } else if (!regExp.hasMatch(value)) {
          return AppConstString.invalidEmail;
        } else {
          return null;
        }
      },
    );
  }

  Widget passwordTxtWidget() {
    return TextFormField(
      controller: passwordController,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              AppSizes.size12,
            ),
          ),
        ),
        prefixIcon: const Icon(Icons.lock),
        hintText: AppConstString.enterPassword,
        suffixIcon: InkWell(
          onTap: () {
            setState(() {
              showPassword = !showPassword;
            });
          },
          child: Icon(
            showPassword ? Icons.visibility : Icons.visibility_off,
          ),
        ),
      ),
      obscureText: showPassword,
      onChanged: (value) {
        setState(() {
          showOtp = false;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppConstString.requiredPassword;
        }
        return null;
      },
    );
  }

  Widget otpTxtWidget() {
    return TextFormField(
      controller: otpController,
      decoration: const InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                AppSizes.size12,
              ),
            ),
          ),
          hintText: AppConstString.enterOtp,
          counterText: ''),
      maxLength: 4,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppConstString.requiredOtp;
        }
        return null;
      },
    );
  }

  Widget signInBtnWidget() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.white,
          backgroundColor: AppColors.btnColor,
          textStyle:
              AppTextStyle.black12Normal.copyWith(color: AppColors.white),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: submitForm,
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(
                AppConstString.signIn.toUpperCase(),
                style: AppTextStyle.white16Bold,
              ),
      ),
    );
  }

  Widget otpVerifeyBtnWidget() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.white,
          backgroundColor: AppColors.btnColor,
          textStyle:
              AppTextStyle.black12Normal.copyWith(color: AppColors.white),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            verifyOtp();
          }
        },
        child: Text(
          AppConstString.submit.toUpperCase(),
          style: AppTextStyle.white16Bold,
        ),
      ),
    );
  }

  Widget buildSocialIcon(String assetName) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 25,
        child: Image.asset(
          assetName,
          width: 25,
          height: 25,
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.clear();
    passwordController.clear();
    super.dispose();
  }
}
