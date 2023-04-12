import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:project/general/route.dart';
import 'package:project/general/themes.dart';
import 'package:project/localization/localization.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  setPathUrlStrategy();
  await dotenv.load(fileName: "environment/.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: AppColors.white),
        translations: Languages(),
        locale: Get.deviceLocale,
        fallbackLocale: const Locale('en', 'US'),
        initialRoute: '/',
        getPages: AppRoutes.pages);
  }
}
