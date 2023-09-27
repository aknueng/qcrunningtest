import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qcrunningtest/models/md_account.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _barcode = '';
  late Future<MAccount> oAccount;

  void checkLogin() {
    setState(() {
      oAccount = fetchData();

      oAccount.then((acc) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        if (acc.EmpCode != '' && acc.EmpCode.isNotEmpty) {
          prefs.setString('EmpCode', acc.EmpCode);
          prefs.setString('EmpName', acc.EmpName);
          prefs.setString('EmpRole', acc.EmpRole);

          //if (context.mounted) Navigator.pushNamed(context, '/');
          debugPrint('${acc.EmpCode}');

          Get.offAndToNamed('/qc');
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ไม่ผ่าน Login Faild'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(30),
              ),
            );
          }
        }
      });
    });
  }

  Future<MAccount> fetchData() async {
    final response = await http.post(
        Uri.parse('http://scm.dci.daikin.co.jp/scmapi/api/Hold/checklogin'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{"barcode": _barcode}));
    if (response.statusCode == 200) {
      return MAccount.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      return MAccount(EmpCode: '', EmpName: '', EmpRole: '');
    } else {
      throw Exception('fail load data.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('LOGIN'),
        centerTitle: false,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.surface,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Image(
            image: AssetImage('assets/qrcode.png'),
            width: 150,
            height: 150,
          ),
          const SizedBox(
            height: 10,
          ),
          Text('>>> $_barcode'),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue, width: 2, strokeAlign: 2))),
            style: const TextStyle(
              decorationColor: Colors.green,
              color: Colors.black,
            ),
            onFieldSubmitted: (value) {
              setState(() {
                _barcode = value;
              });
              checkLogin();
            },
          )
        ],
      ),
    );
  }
}
