import 'package:buzdy/views/colors.dart';
import 'package:buzdy/views/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buzdy/views/customText.dart';
import 'package:buzdy/views/text_styles.dart';
import 'package:shimmer/shimmer.dart';

class ButtonShimmerList extends StatelessWidget {
  const ButtonShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey,
        highlightColor: Colors.white,
        child: SizedBox(
          height: Get.height,
          width: Get.width,
          child: GridView.builder(
            itemCount: 30,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        color: shimmerBlack3,
                      ),
                    ),
                    UIHelper.verticalSpaceSm5,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        kText(text: "Button".tr),
                        kText(
                            text: "SR".tr,
                            tColor: splashcolor,
                            fWeight: fontWeightBold)
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ));
  }
}
