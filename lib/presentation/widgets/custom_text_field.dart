import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:buzdy/core/colors.dart';
import 'package:buzdy/core/text_styles.dart';

class CustomTextField extends StatefulWidget {
  final String? hint;
  final TextEditingController? controller;
  final bool? isObscure;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboard;
  final FocusNode? focusNode;
  final bool? isRequired;
  final int? maxLines;
  final bool? readOnly;
  final double? fontSize;
  final String? label;
  final VoidCallback? onTap;
  final dynamic egText;
  final dynamic border;
  final dynamic fieldWidth;
  final dynamic height;
  final Widget? prefixIcon;
  final dynamic backGroundColor;
  final Color? hintColor;
  final dynamic elevation;
  final bool? autoFocus;
  final Color? cursorColor;
  final FontWeight? weight;
  final double? letterSpacing;
  final TextStyle? placeholder;
  final TextStyle? textStyle;
  final List<TextInputFormatter>? inputFormatters;
  final dynamic borderColor;
  final Widget? suffixIcon;
  final dynamic borderRadius;
  final String? initialValue;
  final String? errorMsg;
  final TextDirection? textDirection;
  final TextAlign? textAlign;
  final TextAlignVertical? textAlignVertical;
  final String? prefixText;
  final bool isMobileNumber;
  final String validationText;

  const CustomTextField({
    Key? key,
    this.hint,
    this.controller,
    this.isObscure,
    this.onChanged,
    this.validator,
    this.keyboard,
    this.focusNode,
    this.isRequired = false,
    this.maxLines,
    this.readOnly,
    this.fontSize,
    this.label,
    this.onTap,
    this.egText,
    this.border,
    this.fieldWidth,
    this.height,
    this.prefixIcon,
    this.backGroundColor,
    this.hintColor,
    this.elevation,
    this.autoFocus,
    this.cursorColor,
    this.weight,
    this.letterSpacing,
    this.placeholder,
    this.textStyle,
    this.inputFormatters,
    this.borderColor,
    this.suffixIcon,
    this.borderRadius,
    this.initialValue,
    this.errorMsg,
    this.textDirection,
    this.textAlign,
    this.textAlignVertical,
    this.prefixText,
    this.isMobileNumber = false,
    this.validationText = "",
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textDirection: widget.textDirection,
      maxLines: widget.maxLines ?? 1,
      obscureText: widget.isObscure ?? false,
      textAlignVertical: widget.textAlignVertical,
      controller: widget.controller,
      cursorHeight: 17,
      cursorRadius: Radius.circular(10),
      validator: widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return widget.validationText;
            }
            return null;
          },
      readOnly: widget.readOnly ?? false,
      keyboardType: widget.keyboard ?? TextInputType.name,
      onTap: widget.onTap ?? () {},
      cursorColor: widget.cursorColor ?? appButtonColor,
      style: widget.textStyle ??
          textStyleMontserratMiddle(
            color: mainBlackcolor,
            fontSize: widget.fontSize ?? 18,
          ),
      onChanged: widget.onChanged,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        prefixText: widget.prefixText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        hintText: widget.hint?.tr ?? "",
        contentPadding: const EdgeInsets.all(10),
        prefixStyle: textStyleMontserratMiddle(color: mainBlackcolor, fontSize: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(color: widget.borderColor ?? appButtonColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(color: widget.borderColor ?? appButtonColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(color: widget.borderColor ?? appButtonColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(color: redColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(color: appButtonColor),
        ),
        errorText: widget.errorMsg?.tr,
        hintStyle: textStyleMontserratMiddle(
          color: widget.hintColor ?? Colors.grey,
          fontSize: 15,
        ),
        alignLabelWithHint: true,
        labelStyle: textStyleMontserratMiddle(color: Colors.grey, fontSize: 15),
      ),
    );
  }
}
