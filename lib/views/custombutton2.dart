import 'package:flutter/material.dart';
import 'package:buzdy/views/colors.dart';
import 'package:buzdy/views/customText.dart';

class CustomButtonn extends StatelessWidget {
  double? width;
  var color;
  var child;
  var text;
  var textcolor;
  var weight;
  var fsize;
  var onTap;
  var buttonBorderColor;
  var icon;
  var circleRadius;
  bool? isDisable;
  var heigth;
  CustomButtonn(this.onTap,
      {super.key, this.child,
      this.color,
      this.fsize,
      this.text,
      this.textcolor,
      this.buttonBorderColor,
      this.weight,
      this.isDisable,
      this.icon,
      this.circleRadius,
      this.heigth,
      this.width});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onTap,
      elevation: 10,
      disabledColor: Color(0xff1d1b201f),
      height: heigth ?? 50.0,
      highlightColor: turquishColor,
      hoverColor: greyColor,
      focusColor: Colors.lightGreen,
      shape: RoundedRectangleBorder(
          // side:
          //     BorderSide(width: 2, color: buttonBorderColor ?? primaryColor),
          borderRadius: BorderRadius.circular(circleRadius ?? 10)),
      minWidth: width ?? MediaQuery.of(context).size.width,
      //= height: 45,
      color: color ?? turquishColor,
      child: child ??
          (text == "loading"
              ? CircularProgressIndicator()
              : kText(
                  text: text,
                  tColor: textcolor ?? mainBlackcolor,
                  fWeight: FontWeight.w600,
                  fSize: fsize ?? 14.0)),
    );
  }
}
