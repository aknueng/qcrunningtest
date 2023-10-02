import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qcrunningtest/main.dart';
import 'package:qcrunningtest/models/md_account.dart';
import 'package:qcrunningtest/models/md_running.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class QCHoldScreen extends StatefulWidget {
  const QCHoldScreen({super.key});

  @override
  State<QCHoldScreen> createState() => _QCHoldScreenState();
}

class _QCHoldScreenState extends State<QCHoldScreen> {
  int _selectedIndex = 0;
  String serialNo = "";
  String lineNo = "1";
  MAccount? oAccount;
  Future<List<MRunningTestInfo>>? oRunnings;
  List<DropdownMenuItem<String>> oLines = [
    const DropdownMenuItem<String>(value: '1', child: Text('Line 1')),
    const DropdownMenuItem<String>(value: '2', child: Text('Line 2')),
    const DropdownMenuItem<String>(value: '3', child: Text('Line 3')),
    const DropdownMenuItem<String>(value: '4', child: Text('Line 4')),
    const DropdownMenuItem<String>(value: '5', child: Text('Line 5')),
    const DropdownMenuItem<String>(value: '6', child: Text('Line 6')),
    const DropdownMenuItem<String>(value: '7', child: Text('Line 7')),
    const DropdownMenuItem<String>(value: '8', child: Text('Line 8')),
  ];

  @override
  void initState() {
    super.initState();

    getAccount().whenComplete(() {
      if (oAccount!.EmpCode == '' || oAccount!.EmpCode.isEmpty) {
        Get.offAndToNamed('/login');
      }
    });
  }

  Future getAccount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      oAccount = MAccount(
          EmpCode: prefs.getString('EmpCode') ?? '',
          EmpName: prefs.getString('EmpName') ?? '',
          EmpRole: prefs.getString('EmpRole') ?? '');
    });
  }

  Future bypassCompressor(String paramSerialNo, String paramLineNo) async {
    final response = await http.post(
        Uri.parse('http://scm.dci.daikin.co.jp/scmapi/api/Hold/holdbypass'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'empCode': oAccount!.EmpCode,
          'serial': paramSerialNo,
          'line': paramLineNo
        }));
    if (response.statusCode == 200 || response.statusCode == 201) {
      oRunnings = fetchDataRunningTest(paramSerialNo, paramLineNo);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Expanded(
                child: Text(
                    'ByPass $paramSerialNo, Line $paramLineNo เรียบร้อยแล้ว')),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(30),
          ),
        );
      }
    }
  }

  Future allowCompressor(String paramSerialNo, String paramLineNo) async {
    final response = await http.post(
        Uri.parse('http://scm.dci.daikin.co.jp/scmapi/api/Hold/holdallow'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'empCode': oAccount!.EmpCode,
          'serial': paramSerialNo,
          'line': paramLineNo
        }));
    if (response.statusCode == 200 || response.statusCode == 201) {
      oRunnings = fetchDataRunningTest(paramSerialNo, paramLineNo);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Expanded(
                child: Text(
                    'Hold Allow $paramSerialNo, Line $paramLineNo เรียบร้อยแล้ว')),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(30),
          ),
        );
      }
    }
  }

  Future<List<MRunningTestInfo>> fetchDataRunningTest(
      String paramSerialNo, String paramLineNo) async {
    final response = await http.post(
        Uri.parse('http://scm.dci.daikin.co.jp/scmapi/api/Hold/checkrunning'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'empCode': oAccount!.EmpCode,
          'serial': paramSerialNo,
          'line': paramLineNo,
        }));

    if (response.statusCode == 200) {
      // _selectOTJob = [];

      // on success, parse the JSON in the response body
      final parser = GetRunningTestParser(response.body);
      Future<List<MRunningTestInfo>> data = parser.parseInBackground();

      debugPrint(response.body);

      // data.then((value) {
      //   for (var i = 0; i < value.length; i++) {
      //     _selectOTJob!.add('');
      //   }
      // });

      return data;

      // return compute((message) => parseOTList(response.body), response.body);
      // final parsed = jsonDecode(response.body)['todos'].cast<Map<String, dynamic>>();
      // return parsed.map<Todos>((json) => Todos.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      if (context.mounted) {
        Navigator.pushNamed(context, '/login');
      }
      throw ('failed to load data');
    } else {
      // กรณี error
      throw Exception('Failed to load ot list');
    }
  }

  void logOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove('EmpCode');
    prefs.remove('EmpName');
    prefs.remove('EmpRole');
    setState(() {
      oAccount = MAccount(EmpCode: '', EmpName: '', EmpRole: '');
    });

    if (context.mounted) {
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inverseSurface,
        foregroundColor: theme.colorScheme.inversePrimary,
        title: const Text('RUNNING TEST'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextFormField(
                maxLength: 15,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'SCAN COMPRESSOR',
                  counterText: '',
                  labelText: 'SCAN COMPRESSOR',
                  fillColor: Colors.lime[50],
                  filled: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(FontAwesomeIcons.qrcode),
                  ),
                  suffixIcon: const Padding(
                    padding: EdgeInsets.only(left: 0, right: 25),
                    child: Icon(
                      FontAwesomeIcons.qrcode,
                      // size: 10,
                    ),
                  ),
                ),
                onFieldSubmitted: (value) {
                  setState(() {
                    serialNo = value;

                    fetchDataRunningTest(serialNo, lineNo);
                  });
                },
              ),
            ),
            const Divider(
              thickness: 10,
            ),
            Row(
              children: [
                const Text('Serial No :'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    ' $serialNo ',
                    style: const TextStyle(
                        backgroundColor: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text('LINE : '),
                DropdownButton(
                  // isExpanded: true,
                  items: oLines,
                  value: lineNo,
                  onChanged: (val) {
                    setState(() {
                      lineNo = val!;
                    });
                  },
                ),
              ],
            ),
            Text(_selectedIndex.toString()),
            Expanded(
                child: FutureBuilder<List<MRunningTestInfo>>(
              future: oRunnings,
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.done) {
                  return (snapshot.data!.isNotEmpty)
                      ? Text('count: ${snapshot.data!.length.toString()}')
                      : Text('no data');
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                        color: Colors.red,
                      ));
                } else {
                  return const SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                        color: Colors.greenAccent,
                      ));
                }
              },
            )),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.lockOpen, color: Colors.yellow),
              label: 'ALLOW HOLD'),
          BottomNavigationBarItem(
            icon: Container(
                child: Icon(FontAwesomeIcons.circleCheck, color: Colors.green)),
            label: 'BY-PASS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.exit_to_app, color: Colors.redAccent[700]),
            label: 'ออกระบบ',
          ),
        ],
        currentIndex: _selectedIndex,
        // selectedItemColor: Colors.amber[800],
        onTap: (int index) {
          setState(
            () {
              _selectedIndex = index;
            },
          );
          switch (index) {
            case 0:
              break;
            // only scroll to top when current index is selected.
            // if (_selectedIndex == index) {
            //   _homeController.animateTo(
            //     0.0,
            //     duration: const Duration(milliseconds: 500),
            //     curve: Curves.easeOut,
            //   );
            // }
            case 1:
              break;
            //showModal(context);
            case 2:
              logOut();
              break;
          }
        },
      ),
    );
  }
}

class GetRunningTestParser {
  // 1. pass the encoded json as a constructor argument
  GetRunningTestParser(this.encodedJson);
  final String encodedJson;

  // 2. public method that does the parsing in the background
  Future<List<MRunningTestInfo>> parseInBackground() async {
    // create a port
    final p = ReceivePort();
    // spawn the isolate and wait for it to complete
    await Isolate.spawn(_decodeAndParseJson, p.sendPort);
    // get and return the result data
    return await p.first;
  }

  // 3. json parsing
  Future<void> _decodeAndParseJson(SendPort p) async {
    // decode and parse the json
    final jsonData = jsonDecode(encodedJson);
    //final resultsJson = jsonData['results'] as List<dynamic>;
    final resultsJson = jsonData as List<dynamic>;
    final results =
        resultsJson.map((json) => MRunningTestInfo.fromJson(json)).toList();
    // return the result data via Isolate.exit()
    Isolate.exit(p, results);
  }
}
