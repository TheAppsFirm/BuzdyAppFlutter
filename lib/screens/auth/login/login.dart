import 'package:buzdy/screens/auth/forgotPassword/forgot.dart';
import 'package:buzdy/screens/auth/register/register.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool hidePassword = true;

  @override
  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      skip: true,
      mainWidget: Consumer<UserViewModel>(builder: (context, pr, c) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UIHelper.verticalSpaceMd40,
              // Greetings Text
              kText(
                  text: "Welcome!",
                  fSize: 28.0,
                  tColor: mainBlackcolor,
                  fWeight: fontWeightSemiBold),
              UIHelper.verticalSpaceSm15,
              kText(
                text:
                    "Kindly input your email and password to unlock your account.",
                tColor: appblueColor2,
                fSize: 16.0,
                textalign: TextAlign.start,
                height: 1.5,
              ),
              UIHelper.verticalSpaceMd35,
              // Email Input
              Row(
                children: [
                  kText(
                    text: "Email",
                    fSize: 16.0,
                    tColor: mainBlackcolor,
                    fWeight: fontWeightSemiBold,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CustomTextField(
                prefix: Icon(Icons.email_outlined),
                required: false,
                hint: "Enter your email",
                isHide: false,
                // errorMsg: "",
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
                label: null,
                controllerr: _emailController,
                suffixIcon: Icon(Icons.email),
              ),

              UIHelper.verticalSpaceSm20,
              // Password Input
              Row(
                children: [
                  kText(
                      text: "Password",
                      fSize: 16.0,
                      tColor: mainBlackcolor,
                      fWeight: fontWeightSemiBold),
                ],
              ),
              const SizedBox(height: 10),
              CustomTextField(
                prefix: Icon(Icons.lock_outline_rounded),
                required: true,
                hint: "*********",
                isHide: hidePassword,
                //  errorMsg: "",
                label: null,
                controllerr: _passwordController,
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
                suffixIcon: InkWell(
                  onTap: () {
                    hidePassword = !hidePassword;
                    setState(() {});
                  },
                  child: Icon(
                    hidePassword ? Icons.visibility_off : Icons.remove_red_eye,
                  ),
                ),
              ),
              UIHelper.verticalSpaceSm5,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Get.to(ForgotPasswordScreen());
                    },
                    child: kText(
                        text: "Forgot password?",
                        tColor: appButtonColor,
                        fWeight: fontWeightSemiBold,
                        fSize: 15.0),
                  ),
                ],
              ),
              UIHelper.verticalSpaceMd40,
              // Log In Button
              CustomButton(() {
                // "email": "user7345@gmail.com",
                // "password": "A@12abcdef"
                if (_formKey.currentState!.validate()) {
                  pr.login(payload: {
                    "email": _emailController.text,
                    "password": _passwordController.text,
                  });
                }

                // Get.offAll(DashBorad(index: 0));
              }, text: "Log in"),
              UIHelper.verticalSpaceSm10,
              Row(
                children: [
                  kText(
                      text: "Haven't you an account?",
                      fSize: 13.0,
                      tColor: appblueColor2),
                  InkWell(
                    onTap: () {
                      Get.off(RegistrationScreen());
                    },
                    child: kText(
                      text: " Registration",
                      fSize: 13.0,
                      fWeight: fontWeightSemiBold,
                      tColor: appButtonColor,
                    ),
                  ),
                ],
              ),
              UIHelper.verticalSpaceMd30,
            ],
          ),
        );
      }),
    );
  }
}
