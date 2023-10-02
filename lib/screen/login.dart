import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qcrunningtest/models/md_account.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner/qr_code_scanner.dart';
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
          // debugPrint('${acc.EmpCode}');

          setState(() {
            myController.text = '';
          });

          Get.offAndToNamed('/qc');
        } else {
          if (context.mounted) {
            setState(() {
              myController.text = '';
              myFocusNode.requestFocus();
            });
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

  final formKey = GlobalKey<FormState>();
  final myController = TextEditingController();
  late FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LOGIN'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.surface,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          const Image(
            image: AssetImage('assets/qrcode.png'),
            width: 100,
            height: 100,
          ),
          const SizedBox(
            height: 10,
          ),
          // Text('>>> $_barcode'),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Form(
              key: formKey,
              child: Container(
                padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: TextFormField(
                  controller: myController,
                  autofocus: true,
                  focusNode: myFocusNode,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.blue, width: 2, strokeAlign: 2)),
                      suffixIcon: IconButton(
                          onPressed: () async {
                            // final qrCode = await Navigator.pushNamed(context, "/scan");
                            final qrcode = await Get.toNamed('/scan');
                            // debugPrint('***************************************');
                            // debugPrint(qrcode);
                            myController.text = qrcode;
                            // debugPrint('***************************************');

                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              setState(() {
                                _barcode = qrcode;
                              });

                              checkLogin();
                            }
                          },
                          icon: const Icon(FontAwesomeIcons.qrcode))),
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
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
