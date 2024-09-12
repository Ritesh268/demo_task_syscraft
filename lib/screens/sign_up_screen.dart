import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_task_syscraft/config/theme/app_colors.dart';
import 'package:demo_task_syscraft/config/theme/app_text_style.dart';
import 'package:demo_task_syscraft/constants/app_const_text.dart';
import 'package:demo_task_syscraft/constants/app_sizes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fNmaeController = TextEditingController();
  final TextEditingController lNameController = TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cnfPasswordController = TextEditingController();
  bool showPassword = true;
  bool showCnfPassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        var snapshot = await _firestore
            .collection('client')
            .where('email', isEqualTo: emailController.text)
            .get();

        if (snapshot.docs.isNotEmpty) {
          showFailureScreen(AppConstString.emailAlredyinUse);
          return;
        }

        snapshot = await _firestore
            .collection('client')
            .where('mobile', isEqualTo: mobileNoController.text)
            .get();

        if (snapshot.docs.isNotEmpty) {
          showFailureScreen(AppConstString.mobileNoAlredyinUse);
          return;
        }

        String encryptedPassword =
            EncryptionHelper.encryptPassword(passwordController.text);

        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        await _firestore
            .collection('client')
            .doc(userCredential.user!.uid)
            .set({
          'firstName': fNmaeController.text,
          'lastName': lNameController.text,
          'email': emailController.text,
          'mobile': mobileNoController.text,
          'dob': dobController.text,
          'password': encryptedPassword
        });

        showSuccessScreen();
      } catch (e) {
        showFailureScreen(
            '${AppConstString.registrationFailed} ${e.toString()}');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showSuccessScreen() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppConstString.registrationSuccessfully)));
    Navigator.pop(context);
  }

  void showFailureScreen(String errorMessage) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: AppSizes.size12,
                right: AppSizes.size12,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: AppSizes.size10,
                    ),
                    Text(
                      AppConstString.signUp,
                      style: AppTextStyle.blueColor30Bold,
                    ),
                    const SizedBox(
                      height: AppSizes.size20,
                    ),
                    fNameTxtWidget(),
                    const SizedBox(
                      height: AppSizes.size16,
                    ),
                    lNameTxtWidget(),
                    const SizedBox(
                      height: AppSizes.size16,
                    ),
                    phoneNoTxtWidget(),
                    const SizedBox(
                      height: AppSizes.size16,
                    ),
                    emailTxtWidget(),
                    const SizedBox(
                      height: AppSizes.size16,
                    ),
                    dobTxtWidget(),
                    const SizedBox(
                      height: AppSizes.size16,
                    ),
                    passwordTxtWidget(),
                    const SizedBox(
                      height: AppSizes.size16,
                    ),
                    cnfPasswordTxtWidget(),
                    const SizedBox(
                      height: AppSizes.size16,
                    ),
                    signUpBtnWidget(),
                    const SizedBox(
                      height: AppSizes.size36,
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  width: double.infinity,
                  color: AppColors.black.withOpacity(0.1),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget fNameTxtWidget() {
    return TextFormField(
      controller: fNmaeController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              AppSizes.size12,
            ),
          ),
        ),
        prefixIcon: Icon(Icons.person),
        hintText: AppConstString.enterFname,
      ),
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppConstString.requiredFname;
        }
        return null;
      },
    );
  }

  Widget lNameTxtWidget() {
    return TextFormField(
      controller: lNameController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              AppSizes.size12,
            ),
          ),
        ),
        prefixIcon: Icon(Icons.person),
        hintText: AppConstString.enterLname,
      ),
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppConstString.requiredLname;
        }
        return null;
      },
    );
  }

  Widget dobTxtWidget() {
    return TextFormField(
      controller: dobController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              AppSizes.size12,
            ),
          ),
        ),
        prefixIcon: Icon(Icons.date_range),
        hintText: AppConstString.enterDob,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppConstString.requiredDob;
        }
        return null;
      },
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
      keyboardType: TextInputType.emailAddress,
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

  Widget phoneNoTxtWidget() {
    return TextFormField(
      controller: mobileNoController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              AppSizes.size12,
            ),
          ),
        ),
        prefixIcon: Icon(Icons.contacts_rounded),
        hintText: AppConstString.enterMobileNo,
        counterText: '',
      ),
      maxLength: 10,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == '' || value == null || value.isEmpty == true) {
          return AppConstString.requiredMobileNo;
        } else if (value.length < 9) {
          return AppConstString.rangeOfNumber;
        } else if (value.contains(RegExp(r'[;*+_,#/()]'))) {
          return AppConstString.invalidNumber;
        }
        return null;
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
      validator: (value) {
        const String pattern =
            r'^.*(?=.{8,})((?=.*[!?@#$%^&*()\-_=+{};:,<.>]){1})(?=.*\d)((?=.*[a-z]){1})((?=.*[A-Z]){1}).*$';
        final RegExp regExp = RegExp(pattern);
        if (value == null || value.isEmpty) {
          return AppConstString.requiredPassword;
        } else if (value.length < 8) {
          return AppConstString.passwordLength;
        } else if (!regExp.hasMatch(value)) {
          return AppConstString.passwordMatch;
        } else {
          return null;
        }
      },
    );
  }

  Widget cnfPasswordTxtWidget() {
    return TextFormField(
      controller: cnfPasswordController,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              AppSizes.size12,
            ),
          ),
        ),
        prefixIcon: const Icon(Icons.lock),
        hintText: AppConstString.enterCnfPassword,
        suffixIcon: InkWell(
          onTap: () {
            setState(() {
              showCnfPassword = !showCnfPassword;
            });
          },
          child: Icon(
            showCnfPassword ? Icons.visibility : Icons.visibility_off,
          ),
        ),
      ),
      obscureText: showCnfPassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppConstString.requiredCnfPassword;
        } else if (value != passwordController.text) {
          return AppConstString.passwordNotMatch;
        }
        return null;
      },
    );
  }

  Widget signUpBtnWidget() {
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
        child: Text(
          AppConstString.signUp.toUpperCase(),
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
}

class EncryptionHelper {
  static final _key =
      encrypt.Key.fromLength(32); // AES key size: 32 bytes (256-bit)
  static final _iv = encrypt.IV.fromLength(16); // IV size: 16 bytes

  // Function to encrypt the password
  static String encryptPassword(String password) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encrypt(password, iv: _iv);
    return encrypted.base64; // Return encrypted password in base64 format
  }

  // Function to decrypt the password
  static String decryptPassword(String encryptedPassword) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final decrypted = encrypter.decrypt64(encryptedPassword, iv: _iv);
    return decrypted;
  }
}
