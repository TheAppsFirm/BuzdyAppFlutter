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

class ResetPAsswordScreen extends StatefulWidget {
  const ResetPAsswordScreen({super.key});

  @override
  State<ResetPAsswordScreen> createState() => _ResetPAsswordScreenState();
}

class _ResetPAsswordScreenState extends State<ResetPAsswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool hideNewPassword = true;
  bool hideConfirmPassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      mainWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Forgot Password Header
          UIHelper.verticalSpaceMd40,

          kText(
            text: "Reset Password?",
            fSize: 24.0,
            tColor: mainBlackcolor,
            fWeight: fontWeightSemiBold,
          ),
          UIHelper.verticalSpaceSm15,
          kText(
              text:
                  "Your new password must be different from any passwords you have used before",
              tColor: appblueColor2,
              fSize: 16.0,
              textalign: TextAlign.center,
              height: 1.5),
          UIHelper.verticalSpaceMd35,
          // Input

          Row(
            children: [
              kText(
                text: "Password",
                fSize: 16.0,
                tColor: mainBlackcolor,
                fWeight: fontWeightSemiBold,
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomTextField(
            hint: "*********",
            controller: _newPasswordController,
            prefixIcon: Icon(Icons.lock_outline_rounded),
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
          Row(
            children: [
              kText(
                text: "Confirm Password",
                fSize: 16.0,
                tColor: mainBlackcolor,
                fWeight: fontWeightSemiBold,
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomTextField(
            hint: "*********",
            controller: _confirmPasswordController,
            prefixIcon: Icon(Icons.lock_outline_rounded),
            isObscure: hideConfirmPassword,
            suffixIcon: InkWell(
              onTap: () {
                setState(() {
                  hideConfirmPassword = !hideConfirmPassword;
                });
              },
              child: Icon(
                hideConfirmPassword
                    ? Icons.visibility_off
                    : Icons.remove_red_eye,
              ),
            ),
          ),
          UIHelper.verticalSpaceSm5,

          UIHelper.verticalSpaceMd40,
          // Continue Button
          CustomButton(() {
            UIHelper.showSuccessDialog(
                context: context,
                title: "Password Reset Successful!",
                subtitle:
                    "Your password has been successfully updated. Click below to log in",
                titleimage: Checkbox(
                    value: true,
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return appButtonColor; // Custom color when the checkbox is selected
                      }
                      return appButtonColor; // Custom color when the checkbox is not selected
                    }),
                    onChanged: (b) {}),
                bottomWidget: CustomButton(() {
                  Get.offAll(LoginScreen());
                }, text: "Back to Log In"));
          }, text: "Submit"),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    setState(() {
      _isLoading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.red.shade100,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Completed Successfully!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Success! Your account has been created. Please wait a moment as we prepare everything for you.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            ],
          ),
        );
      },
    );

    // Simulate a delay and close the dialog
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    });
  }
}
