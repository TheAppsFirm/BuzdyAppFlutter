import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
import 'package:buzdy/core/colors.dart';
import 'package:buzdy/presentation/widgets/CustomButton.dart';
import 'package:buzdy/presentation/widgets/custom_text_field.dart';
import 'package:buzdy/presentation/widgets/customText.dart';
import 'package:buzdy/core/ui_helpers.dart';
import 'package:buzdy/presentation/screens/auth/forgotPassword/forgot.dart';
import 'package:buzdy/presentation/screens/auth/register/register.dart';
import 'package:buzdy/presentation/screens/auth/authbackground.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}
  
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool hidePassword = true;
  
  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      skip: true,
      mainWidget: Consumer<UserViewModel>(
        builder: (context, pr, child) {
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
                  fWeight: FontWeight.w600,
                ),
                UIHelper.verticalSpaceSm15,
                kText(
                  text: "Kindly input your email and password to unlock your account.",
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
                      fWeight: FontWeight.w600,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  prefixIcon: Icon(Icons.email_outlined),
                  hint: "Enter your email",
                  isObscure: false,
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email is required";
                    }
                    String emailPattern =
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                    RegExp regex = RegExp(emailPattern);
                    if (!regex.hasMatch(value)) {
                      return "Enter a valid email address";
                    }
                    return null;
                  },
                  label: null,
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
                      fWeight: FontWeight.w600,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                  hint: "*********",
                  isObscure: hidePassword,
                  controller: _passwordController,
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
                    if (!RegExp(r'^(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(value)) {
                      return "Password must contain at least one special character";
                    }
                    return null;
                  },
                  suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
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
                        Get.to(const ForgotPasswordScreen());
                      },
                      child: kText(
                        text: "Forgot password?",
                        tColor: appButtonColor,
                        fWeight: FontWeight.w600,
                        fSize: 15.0,
                      ),
                    ),
                  ],
                ),
                UIHelper.verticalSpaceMd40,
                // Log In Button
                CustomButton(() {
                  if (_formKey.currentState!.validate()) {
                    pr.login(payload: {
                      "email": _emailController.text,
                      "password": _passwordController.text,
                    });
                  }
                }, text: "Log in"),
                UIHelper.verticalSpaceSm10,
                Row(
                  children: [
                    kText(
                      text: "Haven't you an account?",
                      fSize: 13.0,
                      tColor: appblueColor2,
                    ),
                    InkWell(
                      onTap: () {
                        Get.off(const RegistrationScreen());
                      },
                      child: kText(
                        text: " Registration",
                        fSize: 13.0,
                        fWeight: FontWeight.w600,
                        tColor: appButtonColor,
                      ),
                    ),
                  ],
                ),
                UIHelper.verticalSpaceMd30,
              ],
            ),
          );
        }
      ),
    );
  }
}
