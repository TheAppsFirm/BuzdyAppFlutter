import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:buzdy/core/colors.dart';
import 'package:buzdy/core/text_styles.dart';

class kText extends StatefulWidget {
  kText({
    required this.text,
    this.tColor,
    this.fSize,
    this.fWeight,
    this.style,
    this.height,
    this.maxLines,
    this.textoverflow,
    this.textalign,
    this.textUnderLine,
    this.align,
    this.uderlineColor,
    super.key,
  });
  String text;
  Color? tColor;
  var fSize;
  FontWeight? fWeight;
  var style;
  var height;
  int? maxLines;
  TextOverflow? textoverflow;
  TextAlign? textalign;
  var textUnderLine, align;
  Color? uderlineColor;

  @override
  State<kText> createState() => _kTextState();
}

class _kTextState extends State<kText> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(builder: (context, provider, child) {
      return Text(
          overflow: widget.textoverflow ?? TextOverflow.visible,
          maxLines: widget.maxLines,
          widget.text.tr,
          textAlign: widget.textalign,
          style: widget.style ??
              textStyleMontserratMiddle(
                  height: widget.height ?? 1.0,
                  fontSize: widget.fSize,
                  color: widget.tColor,
                  weight: widget.fWeight ?? FontWeight.normal,
                  decoration: widget.textUnderLine ?? false,
                  underlineColor: widget.uderlineColor ?? widget.tColor));
    });
  }
}

class kTextField extends StatelessWidget {
  kTextField(
      {super.key,
      this.t_Controller,
      required this.hint,
      this.validateText,
      this.maxLines,
      this.fillColor,
      this.keyboardType});

  TextEditingController? t_Controller;
  var hint;
  var validateText;
  var maxLines;
  Color? fillColor;
  var keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: t_Controller,
      maxLines: maxLines,
      keyboardType: keyboardType ?? TextInputType.text,
      decoration: InputDecoration(
        labelText: hint,
        border: InputBorder.none,
        //hintText: hint,
        filled: true,
        fillColor: fillColor ?? Colors.white70,
        contentPadding: const EdgeInsets.only(
            left: 14.0, bottom: 6.0, top: 8.0, right: 14.0),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(5.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: turquishColor),
          borderRadius: BorderRadius.circular(4.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: greyColor),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      validator: (String? value) {
        if (value!.isEmpty) {
          return validateText;
        }
        return null;
      },
    );
  }
}
