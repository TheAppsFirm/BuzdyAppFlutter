import 'package:buzdy/presentation/screens/dashboard/banks/model/bankModel.dart';
import 'package:buzdy/presentation/widgets/appBar.dart';
import 'package:buzdy/core/text_styles.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:buzdy/core/colors.dart';
import 'package:buzdy/presentation/widgets/customText.dart';
import 'package:buzdy/core/ui_helpers.dart';

class DetailScreen extends StatelessWidget {
  final Bank? model; // Keep this for potential future use
  final String title;
  final List<String?> imageUrls; // Allow nullable strings in the list
  final String description;
  final String address;
  final String email;
  final String phone;
  final String operatingHours;
  final String offDays;

  DetailScreen({
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
        leadinBorderColor: appButtonColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carousel Slider
                imageUrls.isEmpty || imageUrls.every((url) => url == null)
                    ? Container(
                        height: 180.0,
                        width: double.infinity,
                        child: Center(child: Icon(Icons.image_not_supported, size: 50)),
                      )
                    : CarouselSlider(
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
                                ),
                                child: url != null
                                    ? Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Icon(Icons.error, size: 50),
                                      )
                                    : Icon(Icons.image_not_supported, size: 50),
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
                  text: description.isNotEmpty ? description : "No description available",
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
                  text: address.isNotEmpty ? address : "No address available",
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
                  text: email.isNotEmpty ? email : "No email available",
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
                  text: phone.isNotEmpty ? phone : "No phone number available",
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
                  text: operatingHours.isNotEmpty ? operatingHours : "Not specified",
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
                  text: offDays.isNotEmpty ? offDays : "Not specified",
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