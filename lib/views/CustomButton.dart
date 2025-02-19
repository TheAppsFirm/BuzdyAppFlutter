import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:buzdy/views/colors.dart';
import 'package:buzdy/views/text_styles.dart';

class CustomButton extends StatelessWidget {
  double? width;
  var color;
  var child;
  String text;
  var textcolor;
  var weight;
  var fsize;
  var onTap;
  var buttonBorderColor;
  var icon;
  var circleRadius;
  bool? isDisable;
  var letterspacing;
  var height;
  var elevation;
  var leadingIcon;
  var textAlign;
  var ownText;
  bool? isLoading;
  var underlineText;

  CustomButton(this.onTap,
      {super.key, this.child,
      this.ownText,
      this.isLoading,
      this.elevation,
      this.textAlign,
      this.leadingIcon,
      this.color,
      this.fsize,
      required this.text,
      this.textcolor,
      this.buttonBorderColor,
      this.underlineText,
      this.weight,
      this.isDisable,
      this.icon,
      this.height,
      this.circleRadius,
      this.letterspacing,
      this.width});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onTap,
      elevation: elevation ?? 0.0,
      padding: EdgeInsets.zero,
      disabledColor: Color(0xff1d1b201f),
      shape: RoundedRectangleBorder(
          side: BorderSide(
              width: 1.5, color: buttonBorderColor ?? Colors.transparent),
          borderRadius: BorderRadius.circular(circleRadius ?? 10)),
      minWidth: width ?? MediaQuery.of(context).size.width,
      height: height ?? 45,
      color: color ?? appButtonColor,
      child: child ?? isLoading ?? false
          ? const Center(child: CircularProgressIndicator())
          : ownText ??
              Text(text.tr,
                  textAlign: textAlign ?? TextAlign.center,
                  style: textStyleMontserratMiddle(
                      color: textcolor ?? whiteColor,
                      fontSize: fsize ?? 16.0,
                      letterSpacing: letterspacing ?? 0,
                      decoration: underlineText ?? false)),

      // trailing:
      //     Icon(Icons.arrow_forward, color: textcolor ?? Colors.black),
    );
  }
}
