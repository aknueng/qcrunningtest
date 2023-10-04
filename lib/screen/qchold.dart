import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
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
  FocusNode? focScanNode;
  Color? colrScan = Colors.red[100];
  TextEditingController scnCtrl = TextEditingController();

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
      } else {
        focScanNode = FocusNode();
        focScanNode!.requestFocus();
        focScanNode!.addListener(_onFocusChange);
      }
    });
  }

  @override
  void dispose() {
    scnCtrl.dispose();
    focScanNode!.dispose();
    focScanNode!.removeListener(_onFocusChange);

    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      // debugPrint('${focScanNode!.hasFocus.toString()} | ${focScanNode!.hasFocus.toString()}');
      colrScan =
          (focScanNode!.hasFocus) ? Colors.yellow[300]! : Colors.red[100]!;
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
      final jsonData = jsonDecode(response.body);
      if (jsonData['sts'].toString().toUpperCase() == 'TRUE') {
        refreshData(paramSerialNo, paramLineNo);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Wrap(children: [
                Text('ByPass $paramSerialNo, Line $paramLineNo เรียบร้อยแล้ว')
              ]),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(30),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Wrap(children: [
                Text('ไม่สามารถ ByPass $paramSerialNo, Line $paramLineNo ได้')
              ]),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(30),
            ),
          );
        }
      }

      // debugPrint(
      //     ' ${jsonData['sts'].toString()} | ${jsonData['msg'].toString()} ');
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Wrap(children: [
              Text('ไม่สามารถ ByPass $paramSerialNo, Line $paramLineNo ได้')
            ]),
            backgroundColor: Colors.red,
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
      final jsonData = jsonDecode(response.body);
      if (jsonData['sts'].toString().toUpperCase() == 'TRUE') {
        refreshData(paramSerialNo, paramLineNo);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Wrap(children: [
                Text(
                    'Hold Allow $paramSerialNo, Line $paramLineNo เรียบร้อยแล้ว')
              ]),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(30),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Wrap(children: [
                Text('ไม่สามารถปลด Hold $paramSerialNo, Line $paramLineNo ได้')
              ]),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(30),
            ),
          );
        }
      }

      // debugPrint(
      //     ' ${jsonData['sts'].toString()} | ${jsonData['msg'].toString()} ');
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Wrap(children: [
              Text('ไม่สามารถปลด Hold $paramSerialNo, Line $paramLineNo ได้')
            ]),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(30),
          ),
        );
      }
    }
  }

  void refreshData(String paramSerialNo, String paramLineNo) {
    setState(() {
      oRunnings = fetchDataRunningTest(paramSerialNo, paramLineNo);

      focScanNode!.requestFocus();
    });
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
      final parser = GetRunningTestParser(response.body);
      Future<List<MRunningTestInfo>> data = parser.parseInBackground();

      return data;
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

//============= LOG OUT ================
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
//============= LOG OUT ================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.inverseSurface,
          foregroundColor: theme.colorScheme.inversePrimary,
          title: const Text('RUNNING TEST'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('LINE : '),
                    DropdownButton(
                      // isExpanded: true,
                      items: oLines,
                      focusColor: Colors.blue[900],
                      dropdownColor: Colors.yellow[300],
                      value: lineNo,
                      onChanged: (val) {
                        setState(() {
                          lineNo = val!;
                          focScanNode!.requestFocus();
                        });
                      },
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: TextFormField(
                    maxLength: 15,
                    autofocus: true,
                    controller: scnCtrl,
                    focusNode: focScanNode,
                    decoration: InputDecoration(
                      hintText: 'SCAN COMPRESSOR',
                      counterText: '',
                      labelText: 'SCAN COMPRESSOR',
                      fillColor: colrScan,
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
                    onFieldSubmitted: (value) async {
                      setState(() {
                        serialNo = value;

                        oRunnings = fetchDataRunningTest(serialNo, lineNo);
                        scnCtrl.text = '';
                      });

                      // debugPrint('============ START ============');
                      refreshData(serialNo, lineNo);
                      // debugPrint('============  END  ============');
                    },
                  ),
                ),
                Row(
                  children: [
                    const Text('SerialNo:'),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        ' $serialNo ',
                        style: TextStyle(
                            backgroundColor: Colors.blue[200],
                            color: Colors.indigo[900],
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 5,
                ),
                FutureBuilder<List<MRunningTestInfo>>(
                  future: oRunnings,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.data!.isNotEmpty) {
                        List<String> header =
                            snapshot.data![0].header.split('|');

                        List<DataColumn> oHeader = header
                            .map((e) => DataColumn(label: Text(e)))
                            .toList();

                        List<DataRow> oRows = snapshot.data!.map((rw) {
                          List<String> rows = rw.detail.split('|');
                          var oRowCells = rows.map((str) {
                            return DataCell(
                              Text(
                                str,
                                style: TextStyle(
                                    color: (str == 'OK')
                                        ? Colors.green[900]
                                        : (str.length > 10)
                                            ? Colors.black
                                            : Colors.red[900]),
                              ),
                            );
                          }).toList();
                          return DataRow(cells: oRowCells);
                        }).toList();

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                              border: const TableBorder(
                                top:
                                    BorderSide(color: Colors.black, width: 0.5),
                                bottom:
                                    BorderSide(color: Colors.black, width: 0.5),
                                left:
                                    BorderSide(color: Colors.black, width: 0.5),
                                right:
                                    BorderSide(color: Colors.black, width: 0.5),
                                horizontalInside:
                                    BorderSide(color: Colors.black, width: 0.5),
                                verticalInside:
                                    BorderSide(color: Colors.black, width: 0.5),
                              ),
                              columnSpacing: 0,
                              horizontalMargin: 0,
                              headingRowColor:
                                  const MaterialStatePropertyAll(Colors.green),
                              headingRowHeight: 36,
                              headingTextStyle:
                                  const TextStyle(color: Colors.white),
                              columns: oHeader,
                              rows: oRows),
                        );
                      } else {
                        return const Text(
                          ' ไม่พบข้อมูล ',
                          style: TextStyle(color: Colors.red),
                        );
                      }
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
                      return const Text('');
                      // return const SizedBox(
                      //     height: 50,
                      //     width: 50,
                      //     child: CircularProgressIndicator(
                      //       color: Colors.greenAccent,
                      //     ));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.lockOpen, color: Colors.yellow),
                label: 'ALLOW HOLD'),
            const BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.circleCheck, color: Colors.green),
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
                allowCompressor(serialNo, lineNo);
                break;

              case 1:
                bypassCompressor(serialNo, lineNo);
                break;
              case 2:
                logOut();
                break;
            }
          },
        ),
      ),
      onWillPop: () async {
        Get.offAllNamed('/');
        return false;
      },
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
