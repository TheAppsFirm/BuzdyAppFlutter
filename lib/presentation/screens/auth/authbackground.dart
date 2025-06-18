import 'package:buzdy/presentation/screens/dashboard.dart';
import 'package:buzdy/presentation/widgets/appBar.dart';
import 'package:buzdy/core/colors.dart';
import 'package:buzdy/presentation/widgets/customText.dart';
import 'package:buzdy/core/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthBackground extends StatefulWidget {
  var mainWidget, appbar, image, topPadding, skip;
  AuthBackground(
      {super.key,
      this.mainWidget,
      this.appbar,
      this.image,
      this.topPadding,
      this.skip = false});

  @override
  State<AuthBackground> createState() => _AuthBackgroundState();
}

class _AuthBackgroundState extends State<AuthBackground> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          widget.image ??
              Positioned(
                top: 0,
                left: 0,
                child: Image.asset(
                  'images/cornerlogo.png', // Replace with your image path
                  height: 200, // Adjust the height as needed
                  width: 200, // Adjust the width as needed
                  //  fit: BoxFit.cover,
                  color: const Color.fromARGB(255, 111, 186, 248),
                ),
              ),

          Positioned(
              top: 70,
              left: 15,
              child: widget.appbar ??
                  SizedBox(
                    width: Get.width / 1.1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        appBarrWitoutActionWidget(
                            title: "",
                            leadinIconColor: whiteColor,
                            backgroundColor: Colors.transparent),
                        widget.skip
                            ? InkWell(
                                onTap: () {
                                  Get.offAll(DashBoard(index: 0));
                                },
                                child: kText(
                                  text: "Skip",
                                  fSize: 18.0,
                                  fWeight: fontWeightBold,
                                  tColor: appButtonColor,
                                  textUnderLine: true,
                                ),
                              )
                            : Container()
                      ],
                    ),
                  )),
          // Main Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(
                  left: 20.0,
                  right: 20,
                  top: widget.topPadding ?? Get.height / 6),
              child: SingleChildScrollView(child: widget.mainWidget),
            ),
          ),
        ],
      ),
    );
  }
}
