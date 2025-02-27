import 'package:get/get.dart';
import 'package:buzdy/core/locale_string.dart';

class LocalizationService extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        //  'en_US': enUS, // lang/en_us.s
        'ar_SA': arSA, // lang/tr_tr.dart
      };
}
