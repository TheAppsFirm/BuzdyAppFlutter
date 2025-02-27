import 'package:buzdy/presentation/screens/dashboard/banks/model/merchnatModel.dart';
import 'package:buzdy/presentation/widgets/appBar.dart';
import 'package:buzdy/core/text_styles.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:buzdy/core/colors.dart';
import 'package:buzdy/presentation/widgets/customText.dart';
import 'package:buzdy/core/ui_helpers.dart';

class MerchnatDetailScreen extends StatelessWidget {
  MerchantModelData? model;
  final String title;
  final List<String> imageUrls; // List of image URLs for the carousel
  final String description;
  final String address;
  final String email;
  final String phone;
  final String operatingHours;
  final String offDays;

  MerchnatDetailScreen({
    super.key,
    this.model,
    required this.title,
    required this.imageUrls,
    required this.description,
    required this.address,
    required this.email,
    required this.phone,
    required this.operatingHours,
    required this.offDays,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: appBarrWitoutAction(
          title: title,
          leadinIconColor: appButtonColor,
          leadinBorderColor: appButtonColor),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carousel Slider
                CarouselSlider(
                  options: CarouselOptions(
                    height: 180.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.7,
                  ),
                  items: imageUrls.map((url) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                              image: NetworkImage(url),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                UIHelper.verticalSpaceSm20,

                // Description
                kText(
                  text: "Overview",
                  fWeight: fontWeightBold,
                  fSize: 18.0,
                ),
                UIHelper.verticalSpaceSm5,
                kText(
                  text: description + description,
                  fWeight: fontWeightRegular,
                  fSize: 14.0,
                  height: 1.2,
                  tColor: Colors.grey[700],
                ),
                UIHelper.verticalSpaceSm20,

                // Address
                kText(
                  text: "Address",
                  fWeight: fontWeightBold,
                  fSize: 18.0,
                ),
                UIHelper.verticalSpaceSm5,
                kText(
                  text: model!.address,
                  fWeight: fontWeightRegular,
                  height: 1.2,
                  fSize: 14.0,
                  tColor: Colors.grey[700],
                ),
                UIHelper.verticalSpaceSm20,

                // Email
                kText(
                  text: "Email",
                  fWeight: fontWeightBold,
                  fSize: 18.0,
                ),
                UIHelper.verticalSpaceSm5,
                kText(
                  text: model!.email,
                  fWeight: fontWeightRegular,
                  fSize: 14.0,
                  tColor: Colors.grey[700],
                ),
                UIHelper.verticalSpaceSm20,

                // Phone
                kText(
                  text: "Phone",
                  fWeight: fontWeightBold,
                  fSize: 18.0,
                ),
                UIHelper.verticalSpaceSm5,
                kText(
                  text: model!.phone,
                  fWeight: fontWeightRegular,
                  fSize: 14.0,
                  tColor: Colors.grey[700],
                ),
                UIHelper.verticalSpaceSm20,

                // Operating Hours
                kText(
                  text: "Operating Hours",
                  fWeight: fontWeightBold,
                  fSize: 18.0,
                ),
                UIHelper.verticalSpaceSm5,
                kText(
                  text: operatingHours,
                  fWeight: fontWeightRegular,
                  fSize: 14.0,
                  tColor: Colors.grey[700],
                ),
                UIHelper.verticalSpaceSm20,

                // Off Days
                kText(
                  text: "Off Days",
                  fWeight: fontWeightBold,
                  fSize: 18.0,
                ),
                UIHelper.verticalSpaceSm10,
                kText(
                  text: offDays,
                  fWeight: fontWeightRegular,
                  fSize: 14.0,
                  tColor: Colors.grey[700],
                ),
                UIHelper.verticalSpaceSm20,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
