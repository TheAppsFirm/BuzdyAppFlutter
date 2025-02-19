import 'package:buzdy/mainresponse/loginresponcedata.dart';
import 'package:buzdy/repository/auth_api/auth_http_api_repository.dart';
import 'package:buzdy/response/api_response.dart';
import 'package:buzdy/response/status.dart';
import 'package:buzdy/screens/dashboard.dart';
import 'package:buzdy/screens/dashboard/home/model/bankModel.dart';
import 'package:buzdy/views/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserViewModel extends ChangeNotifier {
  UserViewModel() {
    getAllBanks(pageNumber: 1);
  }
  // auth
  Future login({payload}) async {
    AuthHttpApiRepository repository = AuthHttpApiRepository();
    easyLoadingStart();
    ApiResponse res = await repository.loginApi(payload);
    Responses ress = res.data;

    if (ress.status == 1) {
      print("RESPOSNE----------- ${ress.data}");
      easyLoadingStop();
      UIHelper.showMySnak(
          title: "Buzdy", message: "Login successfully", isError: false);
      await savetoken(token: ress.data['token'].toString());
      // await savePhone(phone: payload['phoneNumber']);
      Get.offAll(DashBorad(index: 0));
      //  await getApiToken();
    } else {
      easyLoadingStop();
      UIHelper.showMySnak(
          title: "ERROR", message: ress.message.toString(), isError: true);
    }
  }

//register
  Future register({payload}) async {
    AuthHttpApiRepository repository = AuthHttpApiRepository();
    easyLoadingStart();
    ApiResponse res = await repository.registerApi(payload);
    Responses ress = res.data;

    if (ress.status == 1) {
      print("RESPOSNE----------- ${ress.data}");
      easyLoadingStop();
      UIHelper.showMySnak(
          title: "Buzdy", message: "Register successfully", isError: false);
      await savetoken(token: ress.data['token'].toString());
      // await savePhone(phone: payload['phoneNumber']);
      Get.offAll(DashBorad(index: 0));
      //  await getApiToken();
    } else {
      easyLoadingStop();
      UIHelper.showMySnak(
          title: "ERROR", message: ress.message.toString(), isError: true);
    }
  }

  // banks
  List<Bank> bankList = [];
  Future getAllBanks({pageNumber}) async {
    AuthHttpApiRepository repository = AuthHttpApiRepository();
    ApiResponse res = await repository.getAllBanks(PageNumber: pageNumber);
    if (res.status == Status.completed) {
      Responses ress = res.data;

      if (ress.status == 1) {
        // Properly converting the response data
        BankModel model = BankModel.fromJson({
          "status": ress.status,
          "message": ress.message,
          "banks": ress.data, // Ensure it's passed as a list
          "pagination": ress.pagination
        });
        bankList = model.banks;
        notifyListeners();
      } else {
        print("ERR.....p:   ${ress.status}");
      }
    } else {
      UIHelper.showMySnak(
          title: "ERROR", message: res.message.toString(), isError: true);
    }
  }

  easyLoadingStart({status}) {
    EasyLoading.show(
      indicator:
          Lottie.asset("images/buzdysplash.json", width: 150, height: 150),
    );
    notifyListeners();
  }

  easyLoadingStop() {
    EasyLoading.dismiss();
    notifyListeners();
  }

  savetoken({token}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', token);
    print("token saved successfully: $token");
  }
}
