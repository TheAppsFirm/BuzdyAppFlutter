import 'dart:io';
import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buzdy/presentation/screens/auth/authbackground.dart';
import 'package:buzdy/presentation/widgets/CustomButton.dart';
import 'package:buzdy/core/colors.dart';
import 'package:buzdy/presentation/widgets/customText.dart';
import 'package:buzdy/presentation/widgets/custom_text_field.dart';
import 'package:buzdy/core/text_styles.dart';
import 'package:buzdy/core/ui_helpers.dart';
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
  final TextEditingController _lastNameController  = TextEditingController();
  final TextEditingController _emailController     = TextEditingController();
  final TextEditingController _passwordController  = TextEditingController();
  
  // Remove _isChecked if not used
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

    // Add necessary headers
    request.headers.addAll({
      'Accept': 'application/json',
      'Content-Type': 'multipart/form-data',
    });

    // Add form fields
    request.fields['firstname'] = _firstNameController.text.trim();
    request.fields['lastname']  = _lastNameController.text.trim();
    request.fields['email']     = _emailController.text.trim();
    request.fields['password']  = _passwordController.text.trim();
    request.fields['user_id']   = _emailController.text.split('@').first;
    request.fields['phone']     = '';
    request.fields['phone_country_code'] = '';

    try {
      var response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Signup successful');
        Get.snackbar("Success", "Signup successful!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        print('Signup failed with status: ${response.statusCode}');
        Get.snackbar("Error", "Signup failed: ${response.reasonPhrase}",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('Error: $e');
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
          child: Consumer<UserViewModel>(
            builder: (context, pr, c) {
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
                    prefixIcon: Icon(Icons.person_2_outlined),
                    hint: "First Name",
                    isObscure: false,
                    controller: _firstNameController,
                  ),
                  UIHelper.verticalSpaceSm20,
                  kText(
                    text: "Last Name",
                    fSize: 16.0,
                    tColor: mainBlackcolor,
                    fWeight: fontWeightSemiBold,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    prefixIcon: Icon(Icons.person_2_outlined),
                    hint: "Last Name",
                    isObscure: false,
                    controller: _lastNameController,
                  ),
                  UIHelper.verticalSpaceSm20,
                  kText(
                    text: "Email",
                    fSize: 16.0,
                    tColor: mainBlackcolor,
                    fWeight: fontWeightSemiBold,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    prefixIcon: Icon(Icons.email_outlined),
                    hint: "user@gmail.com",
                    isObscure: false,
                    controller: _emailController,
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
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                    hint: "*********",
                    isObscure: hidePassword,
                    controller: _passwordController,
                    suffixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      child: Icon(
                        hidePassword ? Icons.visibility_off : Icons.remove_red_eye,
                      ),
                    ),
                  ),
                  UIHelper.verticalSpaceSm20,
                  // Optionally, add image picker widget here
                  CustomButton(() async {
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
                  }, text: "Submit"),
                  UIHelper.verticalSpaceSm15,
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}
