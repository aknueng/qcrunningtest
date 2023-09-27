import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qcrunningtest/screen/login.dart';
import 'package:qcrunningtest/screen/qchold.dart';

void main() {
  runApp(GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.yellow, background: Colors.yellow[50])),
      // It is not mandatory to use named routes, but dynamic urls are interesting.
      initialRoute: '/login',
      defaultTransition: Transition.native,
      // translations: MyTranslations(),
      // locale: Locale('th', 'TH'),
      getPages: [
        //Simple GetPage
        GetPage(name: '/login', page: () => LoginScreen()),
        // GetPage with custom transitions and bindings
        // GetPage(
        //   name: '/second',
        //   page: () => Second(),
        //   customTransition: SizeTransitions(),
        //   binding: SampleBind(),
        // ),
        // GetPage with default transitions
        GetPage(
          name: '/qc',
          transition: Transition.cupertino,
          page: () => QCHoldScreen(),
        ),
      ]));
}




// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
