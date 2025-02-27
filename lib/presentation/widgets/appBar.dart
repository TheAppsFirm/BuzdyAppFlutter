import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:buzdy/core/colors.dart';
import 'package:buzdy/core/text_styles.dart';

AppBar appBarrWitoutAction(
    {actionWidget,
    String? title,
    actionIcon,
    context,
    backgroundColor,
    centerTitle,
    leadinIconColor,
    leadinBorderColor,
    leadingWidget,
    titleColor,
    fontSize,
    isBlockBack}) {
  return AppBar(
    titleSpacing: 0.0,
    leadingWidth: 70,
    backgroundColor: backgroundColor ?? Colors.transparent,
    leading: leadingWidget ??
        GestureDetector(onTap: () {
          Get.back();
        }, child: Consumer<UserViewModel>(builder: (context, pr, c) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Container(
                child: Padding(
              padding:
                  const EdgeInsets.only(right: 5, left: 2, top: 5, bottom: 5),
              child: Image.asset(
                'images/backlogo.png',
                color: leadinIconColor ?? whiteColor,
              ),
            )),
          );
        })),
    elevation: 0,
    centerTitle: centerTitle ?? false,
    title: Text(
      title!.tr ?? "title",
      style: textStyleMontserratBold(
        color: titleColor ?? mainBlackcolor,
        fontSize: fontSize ?? 22,
      ),
    ),
  );
}

Widget appBarrWitoutActionWidget(
    {actionWidget,
    String? title,
    actionIcon,
    context,
    backgroundColor,
    centerTitle,
    leadinIconColor,
    leadinBorderColor,
    leadingWidget,
    titleColor,
    isBlockBack}) {
  return leadingWidget ??
      Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            height: 60,
            width: 60,
            child: Consumer<UserViewModel>(builder: (context, pr, c) {
              return InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                width: 2,
                                color: leadinBorderColor ?? appButtonColor)),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 6, bottom: 6, top: 6),
                          child: Image.asset(
                            'images/backlogo.png',
                            color: whiteColor,
                          ),
                        )),
                  ));
            }),
          ));
}

AppBar appBarrWitAction(
    {title,
    context,
    actionwidget,
    backgroundColor,
    elevation,
    leadinIconColor,
    centerTitle,
    leadingWidget,
    titleColor}) {
  return AppBar(
    backgroundColor: backgroundColor ?? Colors.transparent,
    leading: leadingWidget ??
        GestureDetector(onTap: () {
          Get.back();
        }, child: Consumer<UserViewModel>(builder: (context, pr, c) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Container(
                child: Padding(
              padding:
                  const EdgeInsets.only(right: 5, left: 2, top: 5, bottom: 5),
              child: Image.asset(
                'images/backlogo.png',
                color: leadinIconColor ?? whiteColor,
              ),
            )),
          );
        })),
    elevation: elevation ?? 0,
    centerTitle: centerTitle ?? true,
    title: Text(
      title ?? "title",
      style: textStyleMontserratRegular(
          color: titleColor ?? mainBlackcolor, fontSize: 22),
    ),
    actions: [
      Consumer<UserViewModel>(builder: (context, vm, child) {
        return Padding(
          padding: EdgeInsets.only(right: 12),
          child: actionwidget,
        );
      })
    ],
  );
}

Widget verticaldivider({verticalPadding, horizontalPadding, height, color}) {
  return Padding(
    padding: EdgeInsets.symmetric(
        vertical: verticalPadding ?? 12, horizontal: horizontalPadding ?? 0),
    child: Container(
      height: height ?? Get.height,
      width: 1,
      color: color ?? greyColor,
    ),
  );
}

Widget horizontaldivider({verticalPadding, horizontalPadding, color}) {
  return Padding(
    padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding ?? 10, vertical: verticalPadding ?? 15),
    child: Container(
      height: 1,
      width: Get.width,
      color: color ?? greyColor,
    ),
  );
}
