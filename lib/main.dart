import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qcrunningtest/component/scanqrcode.dart';
import 'package:qcrunningtest/screen/login.dart';
import 'package:qcrunningtest/screen/qchold.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await checkAccount();
  runApp(const MyApp());
}

String initPage = '/qc';
Future checkAccount() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String chkLogin = prefs.getString('EmpCode') ?? '';
  if (chkLogin == '' || chkLogin.isEmpty) {
    initPage = '/login';
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: ThemeData.from(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.yellow, background: Colors.yellow[50])),
        // It is not mandatory to use named routes, but dynamic urls are interesting.
        initialRoute: initPage,
        // defaultTransition: Transition.native,
        // translations: MyTranslations(),
        // locale: Locale('th', 'TH'),
        getPages: [
          //Simple GetPage
          GetPage(
              name: '/login',
              transition: Transition.fade,
              page: () => const LoginScreen()),
          GetPage(
            name: '/scan',
            transition: Transition.circularReveal,
            page: () => const QrcodeScanner(),
          ),
          GetPage(
            name: '/qc',
            transition: Transition.cupertino,
            page: () => const QCHoldScreen(),
          ),
        ]);
  }
}
