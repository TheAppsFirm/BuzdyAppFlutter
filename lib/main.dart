import 'package:buzdy/screens/provider/UserViewModel.dart';
import 'package:buzdy/screens/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:provider/provider.dart';

void main() {
  configLoading();
  runApp(const MyApp());
}

void configLoading() {
  EasyLoading.instance
    ..maskType = EasyLoadingMaskType.black
    ..loadingStyle = EasyLoadingStyle.custom // Enable custom styling
    ..backgroundColor = Colors.transparent // Fully remove background
    ..maskColor = Colors.transparent // Remove mask overlay
    ..boxShadow = [] // Remove shadows
    ..indicatorColor = Colors.transparent // Remove default indicator color
    ..radius = 0 // Remove rounded corners
    ..textColor = Colors.transparent // ✅ Set a valid text color
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserViewModel>(create: (_) => UserViewModel()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        transitionDuration: Duration(seconds: 1),
        defaultTransition: Transition.fadeIn,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SplashScreen(),
        builder: EasyLoading.init(),
      ),
    );
  }
}
