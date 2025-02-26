import 'dart:io';
import 'package:buzdy/screens/provider/UserViewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buzdy/screens/auth/authbackground.dart';
import 'package:buzdy/views/CustomButton.dart';
import 'package:buzdy/views/colors.dart';
import 'package:buzdy/views/customText.dart';
import 'package:buzdy/views/custom_text_field.dart';
import 'package:buzdy/views/text_styles.dart';
import 'package:buzdy/views/ui_helpers.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final bool _isChecked = false;
  bool hidePassword = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        print(_image);
      });
    }
  }

  Future<void> _signup() async {
    var uri = Uri.parse('https://api.buzdy.com/users/signup');

    var request = http.MultipartRequest('POST', uri);

    // ✅ Add necessary headers
    request.headers.addAll({
      'Accept': 'application/json',
      'Content-Type':
          'multipart/form-data', // Ensures proper boundary formatting
    });

    // ✅ Add form fields (Ensure no null values)
    request.fields['firstname'] = _firstNameController.text.trim();
    request.fields['lastname'] = _lastNameController.text.trim();
    request.fields['email'] = _emailController.text.trim();
    request.fields['password'] = _passwordController.text.trim();
    request.fields['user_id'] = _emailController.text.split('@').first;
    request.fields['phone'] = '39598437589';
    request.fields['phone_country_code'] = 'string';

    try {
      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Signup successful');
        Get.snackbar("Success", "Signup successful!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        print('❌ Signup failed with status: ${response.statusCode}');
        Get.snackbar("Error", "Signup failed: ${response.reasonPhrase}",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('❌ Error: $e');
      Get.snackbar("Error", "Something went wrong: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      skip: true,
      mainWidget: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Consumer<UserViewModel>(builder: (context, pr, c) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UIHelper.verticalSpaceMd40,
                kText(
                  text: "Join Us: Set Up Your Account",
                  fSize: 24.0,
                  tColor: appblueColor,
                  fWeight: fontWeightExtraBold,
                ),
                UIHelper.verticalSpaceSm15,
                kText(
                  text: "We only need some extra information.",
                  tColor: appblueColor2,
                  fSize: 16.0,
                  textalign: TextAlign.start,
                  height: 1.5,
                ),
                UIHelper.verticalSpaceMd35,
                kText(
                  text: "First Name",
                  fSize: 16.0,
                  tColor: mainBlackcolor,
                  fWeight: fontWeightSemiBold,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                    prefix: Icon(Icons.person_2_outlined),
                    required: false,
                    hint: "First Name",
                    controllerr: _firstNameController),
                UIHelper.verticalSpaceSm20,
                kText(
                  text: "Last Name",
                  fSize: 16.0,
                  tColor: mainBlackcolor,
                  fWeight: fontWeightSemiBold,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                    prefix: Icon(Icons.person_2_outlined),
                    required: false,
                    hint: "Last Name",
                    controllerr: _lastNameController),
                UIHelper.verticalSpaceSm20,
                kText(
                  text: "Email",
                  fSize: 16.0,
                  tColor: mainBlackcolor,
                  fWeight: fontWeightSemiBold,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  prefix: Icon(Icons.email_outlined),
                  required: false,
                  hint: "user@gmail.com",
                  controllerr: _emailController,
                ),
                UIHelper.verticalSpaceSm20,
                kText(
                  text: "Password",
                  fSize: 16.0,
                  tColor: mainBlackcolor,
                  fWeight: fontWeightSemiBold,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  prefix: Icon(Icons.lock_outline_rounded),
                  required: false,
                  hint: "*********",
                  isHide: hidePassword,
                  controllerr: _passwordController,
                  suffixIcon: InkWell(
                    onTap: () {
                      hidePassword = !hidePassword;
                      setState(() {});
                    },
                    child: Icon(
                      hidePassword
                          ? Icons.visibility_off
                          : Icons.remove_red_eye,
                    ),
                  ),
                ),
                UIHelper.verticalSpaceSm20,
                // GestureDetector(
                //   onTap: _pickImage,
                //   child: _image != null
                //       ? Image.file(_image!, height: 100, width: 100)
                //       : Container(
                //           height: 100,
                //           width: 100,
                //           decoration: BoxDecoration(
                //             color: Colors.grey[200],
                //             borderRadius: BorderRadius.circular(10),
                //           ),
                //           child: Icon(Icons.camera_alt,
                //               size: 50, color: Colors.grey),
                //         ),
                // ),
                // UIHelper.verticalSpaceSm20,

                CustomButton(
                  () async {
                    if (_formKey.currentState!.validate()) {
                      var payload = {
                        "firstname": _firstNameController.text,
                        "lastname": _lastNameController.text,
                        "email": _emailController.text,
                        "password": _passwordController.text,
                        "user_id": _emailController.text.split('@').first,
                        "phone": "",
                        "phone_country_code": "",
                      };
                      pr.register(payload: payload);
                    }
                  },
                  text: "Submit",
                ),
                UIHelper.verticalSpaceSm15,
              ],
            );
          }),
        ),
      ),
    );
  }
}
