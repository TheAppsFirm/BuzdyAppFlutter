import 'package:buzdy/presentation/screens/auth/login/login.dart';
import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
import 'package:buzdy/presentation/widgets/CustomButton.dart';
import 'package:buzdy/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:buzdy/core/colors.dart';
import 'package:buzdy/presentation/widgets/customText.dart';
import 'package:buzdy/core/ui_helpers.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controllers for profile fields
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? "";
    if (token.isNotEmpty) {
      await fetchProfile();
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> fetchProfile() async {
    UserViewModel userViewModel =
        Provider.of<UserViewModel>(context, listen: false);
    final user = userViewModel.userModel;
    if (user != null) {
      _firstNameController.text = user.firstname ?? "";
      _lastNameController.text  = user.lastname ?? "";
      _emailController.text     = user.email ?? "";
      // Optionally populate additional fields if available:
      // _phoneController.text   = user.phone ?? "";
      // _cityController.text    = user.city ?? "";
      // _countryController.text = user.country ?? "";
      // _salaryController.text  = user.salary ?? "";
    }
  }

  Future<void> deleteToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', "");
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    final user = userViewModel.userModel;
    // If token is empty or user is null, show a dummy profile UI.
    final bool showDummyProfile = token.isEmpty || user == null;

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
          if (!showDummyProfile)
            IconButton(
              onPressed: () {
                deleteToken();
                Get.offAll(const LoginScreen());
              },
              icon: const Icon(Icons.logout, color: Colors.blue),
            ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: showDummyProfile ? _buildDummyProfileUI() : _buildProfileUI(),
            ),
    );
  }

  // UI for dummy/guest profile when not logged in
  Widget _buildDummyProfileUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Dummy profile header
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, size: 40, color: Colors.white),
          ),
        ),
        UIHelper.verticalSpaceLarge,
        Center(
          child: kText(
            text: "Guest Profile",
            fSize: 22.0,
            fWeight: FontWeight.bold,
            tColor: mainBlackcolor,
          ),
        ),
        UIHelper.verticalSpaceMedium,
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildReadOnlyField("First Name", "Guest"),
                _buildReadOnlyField("Last Name", "User"),
                _buildReadOnlyField("Email", "guest@example.com"),
                _buildReadOnlyField("Phone", "N/A"),
                _buildReadOnlyField("City", "N/A"),
                _buildReadOnlyField("Country", "N/A"),
                _buildReadOnlyField("Salary", "N/A"),
              ],
            ),
          ),
        ),
        UIHelper.verticalSpaceLarge,
        Center(
          child: CustomButton(
            () {
              Get.offAll(const LoginScreen());
            },
            text: "Login",
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          kText(
            text: label,
            fSize: 16.0,
            tColor: mainBlackcolor,
            fWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // UI for the logged-in user's editable profile
  Widget _buildProfileUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Profile header with avatar and title
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, size: 40, color: Colors.white),
          ),
        ),
        UIHelper.verticalSpaceLarge,
        Center(
          child: kText(
            text: "My Profile",
            fSize: 22.0,
            fWeight: FontWeight.bold,
            tColor: mainBlackcolor,
          ),
        ),
        UIHelper.verticalSpaceMedium,
        // Card containing input fields for profile details
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                buildTextField("First Name", Icons.person_outline, _firstNameController, isRequired: true),
                buildTextField("Last Name", Icons.person_outline, _lastNameController, isRequired: true),
                buildTextField("Email", Icons.email_outlined, _emailController, isRequired: true),
                buildTextField("Phone", Icons.phone_outlined, _phoneController, isRequired: true),
                buildTextField("City", Icons.location_city_outlined, _cityController),
                buildTextField("Country", Icons.flag_outlined, _countryController),
                buildTextField("Salary", Icons.money_outlined, _salaryController),
              ],
            ),
          ),
        ),
        UIHelper.verticalSpaceLarge,
        Center(
          child: CustomButton(
            () {
              // Implement save logic here
            },
            text: "Submit",
          ),
        ),
      ],
    );
  }

  Widget buildTextField(String label, IconData icon, TextEditingController controller,
      {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          kText(
            text: label,
            fSize: 16.0,
            tColor: mainBlackcolor,
            fWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          CustomTextField(
            prefixIcon: Icon(icon, color: Colors.grey),
            isRequired: isRequired,
            hint: "Enter $label",
            controller: controller,
          ),
        ],
      ),
    );
  }
}
