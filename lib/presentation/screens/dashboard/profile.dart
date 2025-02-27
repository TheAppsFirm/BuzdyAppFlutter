import 'package:buzdy/presentation/screens/auth/login/login.dart';
import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
import 'package:buzdy/presentation/widgets/CustomButton.dart';
import 'package:buzdy/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:buzdy/core/colors.dart'; // Update import if needed
import 'package:buzdy/presentation/widgets/customText.dart'; // Update import if needed
import 'package:buzdy/core/ui_helpers.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController  = TextEditingController();
  final TextEditingController _emailController     = TextEditingController();
  final TextEditingController _phoneController     = TextEditingController();
  final TextEditingController _cityController      = TextEditingController();
  final TextEditingController _countryController   = TextEditingController();
  final TextEditingController _salaryController    = TextEditingController();

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
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> fetchProfile() async {
    UserViewModel userViewModel =
        Provider.of<UserViewModel>(context, listen: false);

    final user = userViewModel.userModel; // Fetch user data

    if (user != null) {
      print(user.toJson().toString());
      _firstNameController.text = user.firstname ?? "";
      _lastNameController.text  = user.lastname ?? "";
      _emailController.text     = user.email ?? "";
      // Uncomment and update the following lines if your user model contains these fields:
      // _phoneController.text   = user.phone ?? "";
      // _cityController.text    = user.city ?? "";
      // _countryController.text = user.country ?? "";
      // _salaryController.text  = user.salary ?? "";
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
                margin: const EdgeInsets.only(right: 10),
                child: const Text(
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
          ? const Center(child: CircularProgressIndicator())
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
                            margin: const EdgeInsets.only(right: 10),
                            child: const Center(
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
                        buildTextField("First Name", Icons.person_outline, _firstNameController, isRequired: true),
                        buildTextField("Last Name", Icons.person_outline, _lastNameController, isRequired: true),
                        buildTextField("Email", Icons.email_outlined, _emailController, isRequired: true),
                        buildTextField("Phone", Icons.phone_outlined, _phoneController, isRequired: true),
                        buildTextField("City", Icons.location_city_outlined, _cityController),
                        buildTextField("Country", Icons.flag_outlined, _countryController),
                        buildTextField("Salary", Icons.money_outlined, _salaryController),
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

  Widget buildTextField(String label, IconData icon, TextEditingController controller,
      {bool isRequired = false}) {
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
          prefixIcon: Icon(icon),
          isRequired: isRequired,
          hint: "Enter $label",
          controller: controller,
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
