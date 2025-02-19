import 'package:buzdy/screens/auth/login/login.dart';
import 'package:buzdy/screens/provider/UserViewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buzdy/screens/auth/authbackground.dart';
import 'package:buzdy/views/CustomButton.dart';
import 'package:buzdy/views/colors.dart';
import 'package:buzdy/views/customText.dart';
import 'package:buzdy/views/custom_text_field.dart';
import 'package:buzdy/views/text_styles.dart';
import 'package:buzdy/views/ui_helpers.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isChecked = false;
  bool hidePassword = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      skip: true,
      mainWidget: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Consumer<UserViewModel>(builder: (context, pr, c) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UIHelper.verticalSpaceMd40,

                // Header Text
                kText(
                  text: "Join Us: Set Up Your Account",
                  fSize: 24.0,
                  tColor: appblueColor,
                  fWeight: fontWeightExtraBold,
                ),
                UIHelper.verticalSpaceSm15,
                kText(
                  text: "We only need some extra information.",
                  tColor: appblueColor2,
                  fSize: 16.0,
                  textalign: TextAlign.start,
                  height: 1.5,
                ),
                UIHelper.verticalSpaceMd35,
                // Full Name Input
                kText(
                  text: "Full name",
                  fSize: 16.0,
                  tColor: mainBlackcolor,
                  fWeight: fontWeightSemiBold,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                    prefix: Icon(Icons.person_2_outlined),
                    required: false,
                    hint: "Full name",
                    controllerr: _nameController),

                UIHelper.verticalSpaceSm20,
                // Gmail Input
                kText(
                  text: "Email",
                  fSize: 16.0,
                  tColor: mainBlackcolor,
                  fWeight: fontWeightSemiBold,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  prefix: Icon(Icons.email_outlined),
                  required: false,
                  hint: "user@gmail.com",
                  controllerr: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email is required";
                    }
                    // Regular Expression for Valid Email
                    String emailPattern =
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                    RegExp regex = RegExp(emailPattern);
                    if (!regex.hasMatch(value)) {
                      return "Enter a valid email address";
                    }
                    return null;
                  },
                ),
                UIHelper.verticalSpaceSm20,
                // Password Input
                kText(
                  text: "Password",
                  fSize: 16.0,
                  tColor: mainBlackcolor,
                  fWeight: fontWeightSemiBold,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  prefix: Icon(Icons.lock_outline_rounded),
                  required: false,
                  hint: "*********",
                  isHide: hidePassword,
                  label: null,
                  controllerr: _passwordController,
                  suffixIcon: InkWell(
                    onTap: () {
                      hidePassword = !hidePassword;
                      setState(() {});
                    },
                    child: Icon(
                      hidePassword
                          ? Icons.visibility_off
                          : Icons.remove_red_eye,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password is required";
                    }
                    if (value.length < 8) {
                      return "Password must be at least 8 characters long";
                    }
                    if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
                      return "Password must contain at least one uppercase letter";
                    }
                    if (!RegExp(r'^(?=.*\d)').hasMatch(value)) {
                      return "Password must contain at least one number";
                    }
                    if (!RegExp(r'^(?=.*[!@#$%^&*(),.?":{}|<>])')
                        .hasMatch(value)) {
                      return "Password must contain at least one special character";
                    }
                    return null; // ✅ Password is valid
                  },
                ),
                UIHelper.verticalSpaceSm20,
                // Terms and Conditions
                Row(
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: (value) {
                        setState(() {
                          _isChecked = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: "By Signing up, you are agree to our ".tr,
                          style: textStyleMontserratMiddle(),
                          children: [
                            TextSpan(
                              text: "Terms & Conditions".tr,
                              style: textStyleMontserratMiddle(
                                  color: appblueColor2,
                                  weight: fontWeightSemiBold),
                            ),
                            TextSpan(
                              text: " and ".tr,
                              style: textStyleMontserratMiddle(),
                            ),
                            TextSpan(
                              text: "privacy policy.".tr,
                              style: textStyleMontserratMiddle(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                UIHelper.verticalSpaceMd35,
                // Submit Button
                CustomButton(
                  () {
                    if (_isChecked) {
                      // Handle Registration Logic
                      var payload = {
                        "firstname": "Johnjskdhf",
                        "lastname": "Doe",
                        "email": "johndoe@example.com",
                        "password": "securepassword",
                        "user_id": "12345",
                        "phone": "9876543210",
                        "phone_country_code": "+1",
                        "userImage": "", // Pass null if no image
                      };

                      if (_formKey.currentState!.validate()) {
                        pr.register(payload: payload);
                      }
                    } else {
                      // Show an error message
                      Get.snackbar(
                        "Error",
                        "Please accept the Terms & Conditions to proceed.",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  text: "Submit",
                ),
                UIHelper.verticalSpaceSm10,
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    kText(
                      text: "Haven't you an account?",
                      fSize: 15.0,
                    ),
                    InkWell(
                      onTap: () {
                        Get.off(LoginScreen());
                      },
                      child: kText(
                          text: " Login",
                          tColor: appButtonColor,
                          fSize: 15.0,
                          fWeight: fontWeightSemiBold),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
