import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:buzdy/views/colors.dart';
import 'package:buzdy/views/text_styles.dart';

class CustomTextField extends StatefulWidget {
  final String? hint;

  // final String? text;
  final TextEditingController? controllerr;
  final bool? isHide;
  final Function(String)? onChanged;
  final FormFieldValidator<String>? validator;
  TextInputType? keyboard;
  FocusNode? focusNode;
  bool? isvalid;
  bool? required;
  int? maxLines;
  var readOnly;
  var fontSize;
  String? label;
  var onTap;
  var egText;
  var border;
  var fieldWidth;
  var height;
  var prefix;
  var backGroundcolor;
  var hintColor;
  var elevationn;
  bool? autoFOcus;
  var cursorColor;
  FontWeight? weight;
  var letterSpacing;
  TextStyle? placeholder;
  TextStyle? textstyle;
  TextInputFormatter? formate;
  var borderColor;
  var suffixIcon;
  var borderRadius;
  var initialValue;
  String? errorMsg;
  TextDirection? textDirection;
  var textAlign;
  var textAlignVertical;
  var prefixText;
  bool isMobileNumber;
  String validationText;
  List<TextInputFormatter>? inputFormatters;

  CustomTextField(
      {super.key,
      this.controllerr,
      this.cursorColor,
      this.validationText = "",
      this.isMobileNumber = false,
      this.suffixIcon,
      this.textDirection,
      this.errorMsg,
      this.textAlign,
      this.hint,
      this.isHide,
      this.label,
      this.elevationn,
      this.backGroundcolor,
      this.initialValue,
      //  this.text,
      this.onChanged,
      this.focusNode,
      this.isvalid,
      this.hintColor,
      this.letterSpacing,
      required this.required,
      this.borderRadius,
      this.inputFormatters,
      this.keyboard,
      this.prefixText,
      this.maxLines,
      this.readOnly,
      this.fontSize,
      this.onTap,
      this.egText,
      this.border,
      this.formate,
      this.fieldWidth,
      this.height,
      this.prefix,
      this.weight,
      this.placeholder,
      this.borderColor,
      this.validator,
      this.textstyle,
      this.textAlignVertical});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool iserror = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      //cursorHeight: 25,
      textDirection: widget.textDirection,
      // showCursor: widget.isMobileNumber ? false : true,
      maxLines: widget.maxLines ?? 1,
      obscureText: widget.isHide ?? false,
      textAlignVertical: widget.textAlignVertical,
      //   textAlign: pr.isEnglish! ? TextAlign.left : TextAlign.right,
      controller: widget.controllerr, cursorHeight: 17,
      cursorRadius: Radius.circular(10),
      // initialValue: widget.initialValue,
      validator: widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return widget.validationText;
            }
            return null;
          },
      readOnly: widget.readOnly ?? false,
      keyboardType: widget.keyboard ?? TextInputType.name,
      onTap: widget.onTap ?? () async {},
      cursorColor: appButtonColor,
      style: textStyleMontserratMiddle(color: mainBlackcolor, fontSize: 18),
      onChanged: widget.onChanged,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
          prefixText: widget.prefixText,
          prefixIcon: widget.prefix,
          suffixIcon: widget.suffixIcon,
          focusColor: Colors.white,
          hintText: widget.hint!.tr ?? "",
          contentPadding: const EdgeInsets.all(10),
          prefixStyle:
              textStyleMontserratMiddle(color: mainBlackcolor, fontSize: 15),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: appButtonColor)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: appButtonColor)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: appButtonColor)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: appButtonColor)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: redColor)),
          fillColor: Colors.grey,
          // hintText: "",
          errorText: widget.errorMsg?.tr,
          //make hint text
          hintStyle: textStyleMontserratMiddle(
              color: widget.hintColor ?? Colors.grey, fontSize: 15),

          //create lable
          //  labelText: widget.label!.tr,
          alignLabelWithHint: true,
          // label: kText(
          //   text: "Name",
          //   textalign: TextAlign.center,
          // ),
          //lable style
          labelStyle:
              textStyleMontserratMiddle(color: Colors.grey, fontSize: 15)),
    );
  }

  String? defaultValidator(
    value,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text'.tr;
    }
    return null;
  }
}

// class CustomTextFieldPhone extends StatefulWidget {
//   final String? hint;

//   // final String? text;
//   final TextEditingController? controllerr;
//   final bool? isHide;
//   final bool? isObscure;
//   final Function(String)? onChanged;
//   final FormFieldValidator<String>? validator;
//   TextInputType? keyboard;
//   FocusNode? focusNode;
//   bool? isvalid;
//   bool? required;
//   int? maxLines;
//   var readOnly;
//   var fontSize;
//   var label;
//   var onTap;
//   var egText;
//   var border;
//   var fieldWidth;
//   var height;
//   var prefix;
//   var backGroundcolor;
//   var hintColor;
//   var elevationn;
//   bool? autoFOcus;
//   var cursorColor;
//   FontWeight? weight;
//   var letterSpacing;
//   TextStyle? placeholder;
//   TextStyle? textstyle;
//   TextInputFormatter? formate;
//   var borderColor;
//   var suffixIcon;
//   var borderRadius;
//   var initialValue;
//   String? errorMsg;
//   String? validationText;

//   CustomTextFieldPhone({
//     this.controllerr,
//     this.cursorColor,
//     this.validationText,
//     this.suffixIcon,
//     this.errorMsg,
//     this.hint,
//     this.isHide,
//     this.label,
//     this.elevationn,
//     this.backGroundcolor,
//     this.isObscure,
//     this.initialValue,
//     //  this.text,
//     this.onChanged,
//     this.focusNode,
//     this.isvalid,
//     this.hintColor,
//     this.letterSpacing,
//     required this.required,
//     this.borderRadius,
//     this.keyboard,
//     this.maxLines,
//     this.readOnly,
//     this.fontSize,
//     this.onTap,
//     this.egText,
//     this.border,
//     this.formate,
//     this.fieldWidth,
//     this.height,
//     this.prefix,
//     this.weight,
//     this.placeholder,
//     this.borderColor,
//     this.validator,
//     this.textstyle,
//   });

//   @override
//   State<CustomTextFieldPhone> createState() => _CustomTextFieldPhoneState();
// }

// class _CustomTextFieldPhoneState extends State<CustomTextFieldPhone> {
//   bool iserror = false;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         //  UIHelper.verticalSpaceSmm,
//         Container(
//           // margin: EdgeInsets.all(10),
//           child: TextFormField(
//             //cursorHeight: 25,
//             // textDirection: TextDirection.ltr,
//             obscureText: widget.isHide ?? false,
//             controller: widget.controllerr,
//             initialValue: widget.initialValue,
//             validator: (v) {
//               if (v == null || v.isEmpty) {
//                 return;
//               }
//               return null;
//             },
//             readOnly: widget.isObscure ?? false,
//             keyboardType: widget.keyboard ?? TextInputType.name,
//             onTap: widget.onTap ??
//                 () async {
//                   // Provider.of<UserViewModel>(context, listen: false)
//                   //     .coutriesList()
//                   //     .then((value) {
//                   //   print(
//                   //       value.length.toString() + "      lenght:::::");
//                   // });

//                   //  showBottomSheet(context, viewmodel);
//                 },

//             //controller: ,
//             cursorColor: turquishColor,
//             style: textStyleCairoMiddle(color: mainBlackcolor, fontSize: 18),
//             onChanged: widget.onChanged ??
//                 (value) {
//                   //  userInput.text = value.toString();
//                 },
//             decoration: InputDecoration(
//                 suffixIcon:
//                     widget.suffixIcon != null ? widget.suffixIcon : null,
//                 focusColor: Colors.white,
//                 hintText: widget.hint ?? "hint text",
//                 // prefix: Container(
//                 //   width: 50,
//                 //   child: Center(
//                 //     child: Text(
//                 //       countryModel == null ? "🇦🇪" : countryModel!.flag,
//                 //       textHeightBehavior: TextHeightBehavior(
//                 //           leadingDistribution:
//                 //               TextLeadingDistribution.proportional),
//                 //       style: textStylePopinsBold(fontSize: 20),
//                 //     ),
//                 //   ),
//                 // ),
//                 contentPadding: EdgeInsets.all(18),
//                 prefixStyle:
//                     textStyleCairoMiddle(color: mainBlackcolor, fontSize: 15),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: turquishColor, width: 1.5),
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: greyColor, width: 1.5),
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 focusedErrorBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: redColor, width: 1.5),
//                     borderRadius: BorderRadius.circular(10.0)),
//                 errorBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: redColor, width: 1.5),
//                     borderRadius: BorderRadius.circular(10.0)),
//                 fillColor: Colors.grey,
//                 // hintText: "",
//                 errorText: widget.errorMsg != null ? widget.errorMsg!.tr : null,
//                 //make hint text
//                 hintStyle:
//                     textStyleCairoMiddle(color: Colors.grey, fontSize: 15),

//                 //create lable
//                 labelText: widget.label ?? 'Name'.tr,
//                 //lable style
//                 labelStyle:
//                     textStyleCairoMiddle(color: Colors.grey, fontSize: 15)),
//           ),
//         )

//         // widget.egText != null
//         //     ? Row(
//         //         children: [
//         //           Spacer(),
//         //           Padding(
//         //             padding: const EdgeInsets.symmetric(horizontal: 10.0),
//         //             child: Text(
//         //               widget.egText!,
//         //               style: TextStyle(
//         //                   color: Colors.grey,
//         //                   fontSize: 14.0,
//         //                   fontWeight: FontWeight.normal),
//         //             ),
//         //           ),
//         //         ],
//         //       )
//         //     : Container()
//       ],
//     );
//   }

//   String? defaultValidator(value) {
//     if (value == null || value.isEmpty) {
//       return '$value'.tr;
//     }
//     return null;
//   }
// }
