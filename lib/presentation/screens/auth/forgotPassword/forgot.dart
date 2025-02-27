import 'package:buzdy/presentation/screens/auth/forgotPassword/resetPasswrod.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buzdy/presentation/screens/auth/authbackground.dart';
import 'package:buzdy/presentation/widgets/CustomButton.dart';
import 'package:buzdy/core/colors.dart';
import 'package:buzdy/presentation/widgets/customText.dart';
import 'package:buzdy/presentation/widgets/custom_text_field.dart';
import 'package:buzdy/core/text_styles.dart';
import 'package:buzdy/core/ui_helpers.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      mainWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Forgot Password Header
          UIHelper.verticalSpaceMd40,

          kText(
            text: "Forgot Password",
            fSize: 24.0,
            tColor: mainBlackcolor,
            fWeight: fontWeightSemiBold,
          ),
          UIHelper.verticalSpaceSm15,
          kText(
              text:
                  "Please provide your email address. We'll Check Verification.",
              tColor: appblueColor2,
              fSize: 16.0,
              textalign: TextAlign.start,
              height: 1.5),
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
            hint: "user@gmail.com",
            controller: _emailController,
            prefixIcon: Icon(Icons.lock_outline_rounded),
          ),
          UIHelper.verticalSpaceMd35,
          // Continue Button
          CustomButton(
            () {
              // Handle OTP submission logic here
              Get.to(ResetPAsswordScreen());
              print("Email: ${_emailController.text}");
            },
            text: "Continue",
          ),
        ],
      ),
    );
  }
}
