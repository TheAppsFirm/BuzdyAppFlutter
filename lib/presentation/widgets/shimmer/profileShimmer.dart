
import 'package:buzdy/core/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../custom_text_field.dart';

class ShimmerProfile extends StatelessWidget {
  const ShimmerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey,
      highlightColor: Colors.white,
      child: SizedBox(
        height: 525,
        child: Column(
          children: [
            CircleAvatar(radius: 45),
            CustomTextField(isRequired: true, hint: "Name", label: "Name"),
            UIHelper.verticalSpaceSm15,
            CustomTextField(isRequired: true, hint: "Phone", label: "Phone"),
            UIHelper.verticalSpaceSm15,
            CustomTextField(isRequired: true, hint: "Country", label: "Country"),
            UIHelper.verticalSpaceSm15,
            CustomTextField(isRequired: true, hint: "City", label: "City"),
            UIHelper.verticalSpaceSm15,
            CustomTextField(isRequired: true, hint: "Address", label: "Address"),
          ],
        ),
      ),
    );
  }
}
