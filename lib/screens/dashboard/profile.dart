import 'package:buzdy/screens/auth/login/login.dart';
import 'package:buzdy/screens/provider/UserViewModel.dart';
import 'package:buzdy/views/CustomButton.dart';
import 'package:buzdy/views/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:buzdy/views/colors.dart'; // Replace with your actual imports
import 'package:buzdy/views/customText.dart'; // Replace with your actual imports
import 'package:buzdy/views/ui_helpers.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Replace with your actual imports

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  String token = "";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchToken();
  }

  Future<void> fetchToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    token = pref.getString('token') ?? "";
    setState(() {});

    if (token.isNotEmpty) {
      fetchProfile();
    } else {
      loading = false;
    }
  }

  Future<void> fetchProfile() async {
    UserViewModel userViewModel =
        Provider.of<UserViewModel>(context, listen: false);

    final user = userViewModel.userModel; // Fetch user data

    if (user != null) {
      print(user.toJson().toString());
      _firstNameController.text = user.firstname ?? "";
      _lastNameController.text = user.lastname ?? "";
      _emailController.text = user.email ?? "";
      // _phoneController.text = user.phone ?? "";
      //  _cityController.text = user.city ?? "";
      //_countryController.text = user.country ?? "";
      //_salaryController.text = user.salary ?? "";
    } else {
      print("User is null");
    }

    setState(() {
      loading = false;
    });
  }

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
        actions: [
          if (token.isNotEmpty)
            InkWell(
              onTap: () {
                Get.offAll(LoginScreen());
                deleteToken();
              },
              child: Container(
                margin: EdgeInsets.only(right: 10),
                child: Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    decorationColor: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: token.isEmpty
                  ? Column(
                      children: [
                        UIHelper.verticalSpaceXL100,
                        InkWell(
                          onTap: () {
                            Get.offAll(LoginScreen());
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            child: Center(
                              child: Text(
                                "Login Required",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                  decorationColor: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildTextField("First Name", Icons.person_outline,
                            _firstNameController,
                            required: true),
                        buildTextField("Last Name", Icons.person_outline,
                            _lastNameController,
                            required: true),
                        buildTextField(
                            "Email", Icons.email_outlined, _emailController,
                            required: true),
                        buildTextField(
                            "Phone", Icons.phone_outlined, _phoneController,
                            required: true),
                        buildTextField("City", Icons.location_city_outlined,
                            _cityController),
                        buildTextField(
                            "Country", Icons.flag_outlined, _countryController),
                        buildTextField(
                            "Salary", Icons.money_outlined, _salaryController),
                        Center(
                          child: CustomButton(() {
                            // Save logic here
                          }, text: "Submit"),
                        ),
                      ],
                    ),
            ),
    );
  }

  Widget buildTextField(
      String label, IconData icon, TextEditingController controller,
      {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        kText(
          text: label,
          fSize: 16.0,
          tColor: mainBlackcolor,
          fWeight: FontWeight.w600,
        ),
        const SizedBox(height: 10),
        CustomTextField(
          prefix: Icon(icon),
          required: required,
          hint: "Enter $label",
          controllerr: controller,
        ),
        UIHelper.verticalSpaceSm20,
      ],
    );
  }

  deleteToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', "");
    print("Token deleted");
  }
}
