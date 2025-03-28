import 'package:buzdy/presentation/screens/splash/splash.dart';
import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

void main() {
  configLoading();
  runApp(const MyApp());
}

void configLoading() {
  EasyLoading.instance
    ..maskType = EasyLoadingMaskType.black
    ..loadingStyle = EasyLoadingStyle.custom
    ..backgroundColor = Colors.transparent
    ..maskColor = Colors.transparent
    ..boxShadow = []
    ..indicatorColor = Colors.transparent
    ..radius = 0
    ..textColor = Colors.transparent
    ..dismissOnTap = false
    ..indicatorWidget = Lottie.asset("images/buzdysplash.json", width: 150, height: 150);
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
