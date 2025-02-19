import 'package:buzdy/views/CustomButton.dart';
import 'package:buzdy/views/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:buzdy/views/colors.dart'; // Replace with your actual imports
import 'package:buzdy/views/customText.dart'; // Replace with your actual imports
import 'package:buzdy/views/ui_helpers.dart'; // Replace with your actual imports

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _fullNameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _cityController = TextEditingController();

  final TextEditingController _countryController = TextEditingController();

  final TextEditingController _salaryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: kText(
          text: "Profile",
          fWeight: FontWeight.bold,
          fSize: 20.0,
          tColor: mainBlackcolor,
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Name
            Row(
              children: [
                kText(
                  text: "Full Name",
                  fSize: 16.0,
                  tColor: mainBlackcolor,
                  fWeight: FontWeight.w600,
                ),
              ],
            ),
            const SizedBox(height: 10),
            CustomTextField(
              prefix: Icon(Icons.person_outline),
              required: true,
              hint: "John Doe",
              controllerr: _fullNameController,
            ),
            UIHelper.verticalSpaceSm20,

            // Email
            Row(
              children: [
                kText(
                  text: "Email",
                  fSize: 16.0,
                  tColor: mainBlackcolor,
                  fWeight: FontWeight.w600,
                ),
              ],
            ),
            const SizedBox(height: 10),
            CustomTextField(
              prefix: Icon(Icons.email_outlined),
              required: true,
              hint: "user@gmail.com",
              controllerr: _emailController,
            ),
            UIHelper.verticalSpaceSm20,

            // Phone
            Row(
              children: [
                kText(
                  text: "Phone",
                  fSize: 16.0,
                  tColor: mainBlackcolor,
                  fWeight: FontWeight.w600,
                ),
              ],
            ),
            const SizedBox(height: 10),
            CustomTextField(
              prefix: Icon(Icons.phone_outlined),
              required: true,
              hint: "+123456789",
              controllerr: _phoneController,
            ),
            UIHelper.verticalSpaceSm20,

            // City
            Row(
              children: [
                kText(
                  text: "City",
                  fSize: 16.0,
                  tColor: mainBlackcolor,
                  fWeight: FontWeight.w600,
                ),
              ],
            ),
            const SizedBox(height: 10),
            CustomTextField(
              prefix: Icon(Icons.location_city_outlined),
              required: false,
              hint: "New York",
              controllerr: _cityController,
            ),
            UIHelper.verticalSpaceSm20,

            // Country
            Row(
              children: [
                kText(
                  text: "Country",
                  fSize: 16.0,
                  tColor: mainBlackcolor,
                  fWeight: FontWeight.w600,
                ),
              ],
            ),
            const SizedBox(height: 10),
            CustomTextField(
              prefix: Icon(Icons.flag_outlined),
              required: false,
              hint: "USA",
              controllerr: _countryController,
            ),
            UIHelper.verticalSpaceSm20,

            // Salary
            Row(
              children: [
                kText(
                  text: "Salary",
                  fSize: 16.0,
                  tColor: mainBlackcolor,
                  fWeight: FontWeight.w600,
                ),
              ],
            ),
            const SizedBox(height: 10),
            CustomTextField(
              prefix: Icon(Icons.money_outlined),
              required: false,
              hint: "\$100,000",
              controllerr: _salaryController,
            ),
            UIHelper.verticalSpaceSm20,

            // Save Button
            Center(
              child: CustomButton(
                () {
                  // Add your save logic here
                  // Get.snackbar(
                  //     "Profile Updated", "Your profile has been saved.",
                  //     snackPosition: SnackPosition.BOTTOM);
                },
                text: "Submit",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
