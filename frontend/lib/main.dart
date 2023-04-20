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
        title: 'Chat AI',
        theme: ThemeData(
          primaryColor: AppColors.kPrimaryColor,
          scaffoldBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.kPrimaryColor,
              shape: const StadiumBorder(),
              maximumSize: const Size(double.infinity, 48),
              minimumSize: const Size(double.infinity, 48),
            ) 
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.kPrimaryLightColor,
            iconColor: AppColors.kPrimaryColor,
            prefixIconColor: AppColors.kPrimaryColor,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 15, vertical: 15),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide.none,
            ),
          )
        ),
        translations: Languages(),
        locale: Get.deviceLocale,
        fallbackLocale: const Locale('en', 'US'),
        initialRoute: '/',
        getPages: AppRoutes.pages);
  }
}
