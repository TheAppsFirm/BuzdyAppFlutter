import 'package:flutter/material.dart';
import 'package:buzdy/presentation/screens/auth/authbackground.dart';
import 'package:get/get.dart';
import 'package:buzdy/presentation/screens/auth/login/login.dart';
import 'package:buzdy/presentation/widgets/CustomButton.dart';
import 'package:buzdy/core/colors.dart';
import 'package:buzdy/presentation/widgets/customText.dart';
import 'package:buzdy/presentation/widgets/custom_text_field.dart';
import 'package:buzdy/core/text_styles.dart';
import 'package:buzdy/core/ui_helpers.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool hideNewPassword = true;
  bool hideConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      mainWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header and description spacing
          UIHelper.verticalSpaceMd40,
          kText(
            text: "Reset Password?",
            fSize: 24.0,
            tColor: mainBlackcolor,
            fWeight: fontWeightSemiBold,
          ),
          UIHelper.verticalSpaceSm15,
          kText(
            text: "Your new password must be different from any passwords you have used before",
            tColor: appblueColor2,
            fSize: 16.0,
            textalign: TextAlign.center,
            height: 1.5,
          ),
          UIHelper.verticalSpaceMd35,
          // New Password Input
          Align(
            alignment: Alignment.centerLeft,
            child: kText(
              text: "Password",
              fSize: 16.0,
              tColor: mainBlackcolor,
              fWeight: fontWeightSemiBold,
            ),
          ),
          const SizedBox(height: 10),
          CustomTextField(
            hint: "*********",
            controller: _newPasswordController,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            isObscure: hideNewPassword,
            suffixIcon: InkWell(
              onTap: () {
                setState(() {
                  hideNewPassword = !hideNewPassword;
                });
              },
              child: Icon(
                hideNewPassword ? Icons.visibility_off : Icons.remove_red_eye,
              ),
            ),
          ),
          UIHelper.verticalSpaceSm25,
          // Confirm Password Input
          Align(
            alignment: Alignment.centerLeft,
            child: kText(
              text: "Confirm Password",
              fSize: 16.0,
              tColor: mainBlackcolor,
              fWeight: fontWeightSemiBold,
            ),
          ),
          const SizedBox(height: 10),
          CustomTextField(
            hint: "*********",
            controller: _confirmPasswordController,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            isObscure: hideConfirmPassword,
            suffixIcon: InkWell(
              onTap: () {
                setState(() {
                  hideConfirmPassword = !hideConfirmPassword;
                });
              },
              child: Icon(
                hideConfirmPassword ? Icons.visibility_off : Icons.remove_red_eye,
              ),
            ),
          ),
          UIHelper.verticalSpaceSm5,
          UIHelper.verticalSpaceMd40,
          // Submit Button: Shows success dialog and then navigates to Login screen.
          CustomButton(() {
            UIHelper.showSuccessDialog(
              context: context,
              title: "Password Reset Successful!",
              subtitle: "Your password has been successfully updated. Click below to log in",
              titleimage: const Icon(
                Icons.check_circle,
                size: 50,
                color: appButtonColor2,
              ),
              bottomWidget: CustomButton(
                () {
                  Get.offAll(const LoginScreen());
                },
                text: "Back to Log In",
              ),
            );
          }, text: "Submit"),
        ],
      ),
    );
  }
}
