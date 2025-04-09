import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buzdy/core/colors.dart';
import 'package:buzdy/core/text_styles.dart';
import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
import 'package:buzdy/presentation/widgets/CustomButton.dart';
import 'package:buzdy/presentation/widgets/customText.dart';

class UIHelper {
  // Vertical spacing constants (in pixels)
  static const double _verticalSpaceSm5 = 5.0;
  static const double _verticalSpaceSm10 = 10.0;
  static const double _verticalSpaceSm15 = 15.0;
  static const double _verticalSpaceSm20 = 20.0;
  static const double _verticalSpaceSm25 = 25.0;
  static const double _verticalSpaceMd30 = 30.0; // Medium spacing value
  static const double _verticalSpaceMd35 = 35.0;
  static const double _verticalSpaceMd40 = 40.0;
  static const double _verticalSpaceL45 = 45.0;
  static const double _verticalSpaceL50 = 50.0;
  static const double _verticalSpaceXL55 = 55.0;
  static const double _verticalSpaceXL60 = 60.0;
  static const double _verticalSpaceXL65 = 65.0;
  static const double _verticalSpaceXL70 = 70.0;
  static const double _verticalSpaceXL75 = 75.0;
  static const double _verticalSpaceXL80 = 80.0;
  static const double _verticalSpaceXL85 = 85.0;
  static const double _verticalSpaceXL90 = 90.0;
  static const double _verticalSpaceXL95 = 95.0;
  static const double _verticalSpaceXL100 = 100.0;

  // Horizontal spacing constants (in pixels)
  static const double _horizontalSpaceSm5 = 5.0;
  static const double _horizontalSpaceSm10 = 10.0;
  static const double _horizontalSpaceSm15 = 15.0;
  static const double _horizontalSpaceSm20 = 20.0;
  static const double _horizontalSpaceSm25 = 25.0;
  static const double _horizontalSpaceMd30 = 30.0;
  static const double _horizontalSpaceMd35 = 35.0;
  static const double _horizontalSpaceMd40 = 40.0;
  static const double _horizontalSpaceL45 = 45.0;
  static const double _horizontalSpaceL50 = 50.0;
  static const double _horizontalSpaceXL55 = 55.0;
  static const double _horizontalSpaceXL60 = 60.0;
  static const double _horizontalSpaceXL65 = 65.0;
  static const double _horizontalSpaceXL70 = 70.0;
  static const double _horizontalSpaceXL75 = 75.0;
  static const double _horizontalSpaceXL80 = 80.0;
  static const double _horizontalSpaceXL85 = 85.0;
  static const double _horizontalSpaceXL90 = 90.0;
  static const double _horizontalSpaceXL95 = 95.0;
  static const double _horizontalSpaceXL100 = 100.0;

  // Horizontal SizedBoxes
  static const Widget horizontalSpaceSm5 = SizedBox(width: _horizontalSpaceSm5);
  static const Widget horizontalSpaceSm10 = SizedBox(width: _horizontalSpaceSm10);
  static const Widget horizontalSpaceSm15 = SizedBox(width: _horizontalSpaceSm15);
  static const Widget horizontalSpaceSm20 = SizedBox(width: _horizontalSpaceSm20);
  static const Widget horizontalSpaceSm25 = SizedBox(width: _horizontalSpaceSm25);
  static const Widget horizontalSpaceMd30 = SizedBox(width: _horizontalSpaceMd30);
  static const Widget horizontalSpaceMd35 = SizedBox(width: _horizontalSpaceMd35);
  static const Widget horizontalSpaceMd40 = SizedBox(width: _horizontalSpaceMd40);
  static const Widget horizontalSpaceL45 = SizedBox(width: _horizontalSpaceL45);
  static const Widget horizontalSpaceL50 = SizedBox(width: _horizontalSpaceL50);
  static const Widget horizontalSpaceXL55 = SizedBox(width: _horizontalSpaceXL55);
  static const Widget horizontalSpaceXL60 = SizedBox(width: _horizontalSpaceXL60);
  static const Widget horizontalSpaceXL65 = SizedBox(width: _horizontalSpaceXL65);
  static const Widget horizontalSpaceXL70 = SizedBox(width: _horizontalSpaceXL70);
  static const Widget horizontalSpaceXL75 = SizedBox(width: _horizontalSpaceXL75);
  static const Widget horizontalSpaceXL80 = SizedBox(width: _horizontalSpaceXL80);
  static const Widget horizontalSpaceXL85 = SizedBox(width: _horizontalSpaceXL85);
  static const Widget horizontalSpaceXL90 = SizedBox(width: _horizontalSpaceXL90);
  static const Widget horizontalSpaceXL95 = SizedBox(width: _horizontalSpaceXL95);
  static const Widget horizontalSpaceXL100 = SizedBox(width: _horizontalSpaceXL100);

  // Vertical SizedBoxes
  static const Widget verticalSpaceSm5 = SizedBox(height: _verticalSpaceSm5);
  static const Widget verticalSpaceSm10 = SizedBox(height: _verticalSpaceSm10);
  static const Widget verticalSpaceSm15 = SizedBox(height: _verticalSpaceSm15);
  static const Widget verticalSpaceSm20 = SizedBox(height: _verticalSpaceSm20);
  static const Widget verticalSpaceSm25 = SizedBox(height: _verticalSpaceSm25);
  static const Widget verticalSpaceMd30 = SizedBox(height: _verticalSpaceMd30);
  static const Widget verticalSpaceMd35 = SizedBox(height: _verticalSpaceMd35);
  static const Widget verticalSpaceMd40 = SizedBox(height: _verticalSpaceMd40);
  static const Widget verticalSpaceL45 = SizedBox(height: _verticalSpaceL45);
  static const Widget verticalSpaceL50 = SizedBox(height: _verticalSpaceL50);
  static const Widget verticalSpaceXL55 = SizedBox(height: _verticalSpaceXL55);
  static const Widget verticalSpaceXL60 = SizedBox(height: _verticalSpaceXL60);
  static const Widget verticalSpaceXL65 = SizedBox(height: _verticalSpaceXL65);
  static const Widget verticalSpaceXL70 = SizedBox(height: _verticalSpaceXL70);
  static const Widget verticalSpaceXL75 = SizedBox(height: _verticalSpaceXL75);
  static const Widget verticalSpaceXL80 = SizedBox(height: _verticalSpaceXL80);
  static const Widget verticalSpaceXL85 = SizedBox(height: _verticalSpaceXL85);
  static const Widget verticalSpaceXL90 = SizedBox(height: _verticalSpaceXL90);
  static const Widget verticalSpaceXL95 = SizedBox(height: _verticalSpaceXL95);
  static const Widget verticalSpaceXL100 = SizedBox(height: _verticalSpaceXL100);

  // Additional aliases for common spacing
  static const Widget verticalSpaceMedium = verticalSpaceMd30; // 30.0 height
  static const Widget verticalSpaceLarge = verticalSpaceL50;     // 50.0 height

  // Snackbar utility
  static void showMySnak({
    String title = "",
    String message = "",
    bool isError = false,
  }) {
    Get.snackbar(
      title.tr,
      message.tr,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
    );
  }

  // Returns initials from a given string.
  static String getShortName({required String text}) {
    final buffer = StringBuffer();
    final parts = text.split(' ');
    for (final part in parts) {
      if (part.isNotEmpty) {
        buffer.write(part[0].toUpperCase());
      }
    }
    return buffer.toString();
  }

  static Widget moneyRichText({
    String? text1,
    String? text2,
    Color? t1Color,
    Color? t2Color,
    double? t1FontSize,
    double? t2FontSize,
  }) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text1 ?? '10000',
            style: textStyleMontserratMiddle(
              fontSize: t1FontSize ?? 25,
              color: t1Color ?? whiteColor,
            ),
          ),
          const WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: SizedBox(width: 3),
          ),
          TextSpan(
            text: text2 ?? 'SAR'.tr,
            style: textStyleMontserratMiddle(
              fontSize: t2FontSize ?? 10,
              color: t2Color ?? greyColor,
            ),
          ),
        ],
      ),
    );
  }

  static Widget amountTile({
    Color? leadingColor,
    required String titleText,
    trailingAmont,
    UserViewModel? viewmodel,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      horizontalTitleGap: 8.0,
      minVerticalPadding: 0.0,
      leading: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          color: lightblueBackgroundColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            decoration: BoxDecoration(
              color: leadingColor ?? redColor,
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      ),
      title: Text(
        titleText.tr,
        style: textStyleMontserratMiddle(color: greyColor, fontSize: 17),
      ),
    );
  }

  static Future showDialogue({
    required BuildContext context,
    bool loader = false,
    VoidCallback? onTap,
    String? title,
    String? subTiltle,
  }) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Row(
            children: [
              kText(
                text: title ?? "title".tr,
                fSize: 15.0,
                tColor: appdarkIconColor,
                fWeight: FontWeight.bold,
              ),
              const Spacer(),
              if (loader)
                const Center(
                  child: CircularProgressIndicator(
                    color: turquishColor,
                  ),
                ),
            ],
          ),
          content: kText(
            text: subTiltle ?? 'Are you sure you want to download'.tr,
            fSize: 15.0,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: kText(
                text: 'Cancel'.tr,
                fSize: 15.0,
                fWeight: FontWeight.bold,
                tColor: appdarkIconColor,
              ),
            ),
            TextButton(
              onPressed: onTap ?? () {},
              child: kText(
                text: "Ok".tr,
                fSize: 15.0,
                fWeight: FontWeight.bold,
                tColor: appdarkIconColor,
              ),
            ),
          ],
        );
      },
    );
  }

  static const String mapKey =
      "AIzaSyDVX6dMqw5wbVC1t47hNg3xOEuseEwmA_c";

  static String getShortNameAbbreviation({required String text, int? limitTo}) {
    final buffer = StringBuffer();
    final parts = text.split(' ');
    for (final part in parts) {
      if (part.isNotEmpty) {
        buffer.write(part[0].toUpperCase());
      }
    }
    return buffer.toString();
  }

  static Widget moneyRichTextAlternate({
    String? text1,
    String? text2,
    Color? t1Color,
    Color? t2Color,
    double? t1FontSize,
    double? t2FontSize,
  }) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text1 ?? '10000',
            style: textStyleMontserratMiddle(
              fontSize: t1FontSize ?? 25,
              color: t1Color ?? whiteColor,
            ),
          ),
          const WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: SizedBox(width: 3),
          ),
          TextSpan(
            text: text2 ?? 'SAR'.tr,
            style: textStyleMontserratMiddle(
              fontSize: t2FontSize ?? 10,
              color: t2Color ?? greyColor,
            ),
          ),
        ],
      ),
    );
  }

  static showSuccessDialog({
    required BuildContext context,
    Widget? titleImage,
    String? title,
    String? subtitle,
    Widget? bottomWidget, required Icon titleimage,
  }) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by tapping outside
      builder: (context) {
        return AlertDialog(
          backgroundColor: whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.red.shade100,
                child: titleImage ??
                    const Icon(Icons.person, size: 50, color: appButtonColor2),
              ),
              verticalSpaceSm25,
              kText(
                text: title ?? 'Title',
                fSize: 18.0,
                fWeight: fontWeightBold,
                tColor: appButtonColor,
                textalign: TextAlign.center,
              ),
              verticalSpaceSm25,
              kText(
                text: subtitle ?? 'your dialogue subtitle',
                fSize: 15.0,
                height: 1.5,
                textalign: TextAlign.center,
                tColor: appblueColor2,
              ),
              verticalSpaceMd35,
              bottomWidget ??
                  CustomButton(() {
                    Get.back();
                  }, text: "Button")
            ],
          ),
        );
      },
    );
  }
}
